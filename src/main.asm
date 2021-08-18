INCLUDE "hardware.inc"
INCLUDE "macros.inc"

SECTION "GameVars", WRAM0
ShadowScrollX:: DS 1
IsGamePaused:: DS 1 ; 0 = unpaused, nonzero = paused

SECTION "MainGameCode", ROM0

EntryPoint:: ; At this point, interrupts are already disabled from the header code

    ld sp, $E000 ; Set the stack pointer to the top of RAM to free up HRAM

    ; Turn off the LCD
.waitVBlank
	ld a, [rLY]
	cp 144 ; Check if the LCD is past VBlank
	jr c, .waitVBlank
	xor a ; turn off the LCD
	ld [rLCDC], a

    ; Initialize VRAM to 0
	ld hl, $8000
	ld bc, $A000 - $8000
	ld d, 0
	rst memset
    ; Initialize sprite buffer to 0
	ld hl, STARTOF("SpriteBuffer")
	ld c, SIZEOF("SpriteBuffer")
	ld d, 0
	rst memsetFast
    ; Copy the OAM DMA routine into HRAM
    ld hl, DMARoutineHRAM
    ld de, DMARoutine
    ld c, 14
    rst memcpyFast
    ; Copy the empty sprite buffer into OAM
    call DMARoutineHRAM

    ; Copy tileset into VRAM
    rom_bank_switch BANK("RoadTiles")
    ld hl, RoadTilesVRAM
    ld de, STARTOF("RoadTiles")
    ld bc, SIZEOF("RoadTiles")
    rst memcpy
    rom_bank_switch BANK("PlayerTiles")
    ld hl, PlayerTilesVRAM
    ld de, STARTOF("PlayerTiles")
    ld bc, SIZEOF("PlayerTiles")
    rst memcpy
    rom_bank_switch BANK("PoliceCarTiles")
    ld hl, PoliceCarTilesVRAM
    ld de, STARTOF("PoliceCarTiles")
    ld bc, SIZEOF("PoliceCarTiles")
    rst memcpy
    rom_bank_switch BANK("Explosion1Tiles")
    ld hl, Explosion1TilesVRAM
    ld de, STARTOF("Explosion1Tiles")
    ld bc, SIZEOF("Explosion1Tiles")
    rst memcpy
    rom_bank_switch BANK("StatusBar")
    ld hl, StatusBarVRAM
    ld de, STARTOF("StatusBar")
    ld bc, SIZEOF("StatusBar")
    rst memcpy
    rom_bank_switch BANK("MenuBarTiles")
    ld hl, MenuBarTilesVRAM
    ld de, STARTOF("MenuBarTiles")
    ld bc, SIZEOF("MenuBarTiles")
    rst memcpy

    ; Init menu bar tilemaps
    call genMenuBarTilemaps

    ; Init input
    xor a
    ld [curButtons], a
    ld [newButtons], a

    ; TEMP : seed random
    ld hl, $9574;$38
    call seedRandom

    ; Initialise variables
    call initCollision
    call initGameUI
    jp InitRoadGen
.doneInitRoad::
    call initPlayer
    call initEnemyCars

    xor a
    ld [IsGamePaused], a
    ld a, 16 ; Init X scroll
	ld [ShadowScrollX], a

    ;ld a, 19 ; Generate enough road for the whole screen, plus 1 extra line
    ld a, 24 ; Generate enough road for the whole screen, plus several extra lines
.pregenRoadLp:
    push af
    call GenRoadRow
    call CopyRoadBuffer
    pop af
    dec a
    jr nz, .pregenRoadLp

    ; Init display registers
	ld a, %11100100 ; Init background palette
	ldh [rBGP], a
    ld [rOBP0], a ; Init sprite palettes
	ld [rOBP1], a

    ; Init VBlank vector
    ld hl, VblankVectorRAM
    ld a, LOW(VBlank)
    ld [hli], a
    ld a, HIGH(VBlank)
    ld [hl], a

    ; No, vblank has not happened yet
    xor a
    ld [HasVblankHappened], a

    ; Shut sound down
    xor a
    ldh [rNR52], a

    ; Enable screen and initialise screen settings
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINOFF | LCDCF_BG8800 \
        | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJON | LCDCF_BGON
    ldh [rLCDC], a

    ; Enable LY=LYC as LCD STAT interrupt source
    ld a, STATF_LYC
    ldh [rSTAT], a

    ; Disable all interrupts except VBlank and LCD
	ld a, IEF_VBLANK | IEF_STAT
	ldh [rIE], a
    xor a
    ldh [rIF], a ; Discard all pending interrupts (there would normally be a VBlank pending)
	ei
GameLoop:
    call readInput

    ld a, [IsGamePaused]
    and a
    jr z, .notPaused
    call updateMenuBar
    jr .doneGameLoop
.notPaused:

    ld a, [newButtons] ; Pause if start button is pressed
    and PADF_START
    jr z, .pauseNotPressed
    ld a, $FF
    ld [IsGamePaused], a
    xor a ; open pause menu
    call startMenuBarAnim
.pauseNotPressed:

    ; Update road scroll, and generate new line of road if needed
    ld a, [CurrentRoadScrollSpeed + 1] ; Load subpixel portion of road speed
    ld b, a ; put that into B
    ld a, [CurrentRoadScrollPos + 1] ; Load current subpixel into A
    sub b ; Apply subpixel speed to current subpixel position
    ld [CurrentRoadScrollPos + 1], a ; Save back current subpixel pos
    ld a, [CurrentRoadScrollSpeed] ; Load pixel portion of road speed
    adc 0 ; If subpixels overflowed, apply a full pixel to road speed
    ld b, a ; ; A and B now contains the number of pixels to scroll this frame
    ld a, [CurrentRoadScrollPos] ; \
	sub b                        ; | Update the road scroll pixel
	ld [CurrentRoadScrollPos], a ; /
    ; Update RoadScrollCtr, and generate new road line if needed
    ld a, [RoadScrollCtr]
    add b ; B is still the number of lines scrolled this frame
    ld [RoadScrollCtr], a
    cp 8 - 1 ; 8 pixels per line, minus 1 so carry can be used as <
    jr nc, .noNewLine ; if RoadScrollCtr <= 7 (i.e. < 8), no new line is needed
    sub 8
    ld [RoadScrollCtr], a
    call GenRoadRow
.noNewLine:

    call updatePlayer
    call updateEnemyCars
    call updateStatusBar

.doneGameLoop:
    call waitVblank
    jr GameLoop


VBlank::
    ; Copy new road line onto the background tilemap if one is ready
    ld a, [RoadLineReady]
    and a ; update zero flag
    call nz, CopyRoadBuffer

    ; Copy status bar tilemap
    call copyStatusBarBuffer

    ; Update Scroll
    ld a, [CurrentRoadScrollPos]
    ldh [rSCY], a
    ld a, [ShadowScrollX]
    ldh [rSCX], a

    ldh a, [rLCDC]
    or LCDCF_OBJON ; Enable sprites (status bar / ui disables them)
    and ~LCDCF_BG9C00 ; Switch background tilemap
    ldh [rLCDC], a

    ; Copy sprite buffer into OAM
    call DMARoutineHRAM

    ld a, [IsGamePaused]
    and a
    jr nz, .menuBarActive
    call setupStatusBarInterrupt ; If menu bar isn't present, go straight to status bar
    jr .doneLCDIntSetup
.menuBarActive:
    call setupMenuBarInterrupt ; If game is paused, setup menu bar interrupt instead of status bar
.doneLCDIntSetup:

    ld a, 1
    ld [HasVblankHappened], a

    jp VblankEnd

; Setup LY interrupt for top of status bar
setupStatusBarInterrupt::
    ld hl, LCDIntVectorRAM
    ld a, LOW(statusBarTopLine)
    ld [hli], a
    ld a, HIGH(statusBarTopLine)
    ld [hl], a
    ld a, 129 - 1 ; runs on line before
    ld [rLYC], a
    ret