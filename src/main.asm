INCLUDE "hardware.inc"
INCLUDE "macros.inc"

SECTION "GameVars", WRAM0
ShadowScrollX:: DS 1
IsGamePaused:: DS 1 ; 0 = unpaused, nonzero = paused
IsGameOver:: DS 1 ; 0 = in play, nonzero = game over

SECTION "MainGameCode", ROM0

StartGame::
    call disableLCD

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

    ; Initialise variables
    call initCollision
    call initGameUI
    call initRoadGen
    call initPlayer
    call initEnemyCars

    xor a
    ld [IsGamePaused], a
    ld [IsGameOver], a
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

    ; Init VBlank vector
    ld hl, VblankVectorRAM
    ld a, LOW(InGameVBlank)
    ld [hli], a
    ld a, HIGH(InGameVBlank)
    ld [hl], a

    ; Enable screen and initialise screen settings
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINOFF | LCDCF_BG8800 \
        | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJON | LCDCF_BGON
    ldh [rLCDC], a

    ; Enable LY=LYC as LCD STAT interrupt source
    ld a, STATF_LYC
    ldh [rSTAT], a
    ; Make sure no erroneous LYC interrupts happen before it's set up
    ld a, $FF
    ldh [rLYC], a

    ; Disable all interrupts except VBlank and LCD
	ld a, IEF_VBLANK | IEF_STAT
	ldh [rIE], a
    xor a
    ldh [rIF], a ; Discard all pending interrupts (there would normally be a VBlank pending)
	ei
GameLoop:
    call readInput

    ld a, [IsGamePaused]
    ld b, a
    ld a, [IsGameOver]
    or b
    jr z, .notPaused
    call updateMenuBar
    jr .paused
.notPaused:

    ld a, [newButtons] ; Pause if start button is pressed
    and PADF_START
    jr z, .pauseNotPressed
    ld a, $FF
    ld [IsGamePaused], a
    xor a ; open pause menu
    call startMenuBarAnim
    play_sound_effect FX_Pause
.pauseNotPressed:

    call updateRoad
    call updatePlayer
    call updateEnemyCars
    call updateStatusBar
.paused:
    call updateAudio
.doneGameLoop:
    call waitVblank
    jr GameLoop

; Update road scroll, and generate new line of road if needed
updateRoad:
    ld a, [CurrentRoadScrollSpeed + 1] ; Load subpixel portion of road speed
    ld b, a ; put that into B
    ld hl, CurrentRoadScrollPos + 1
    ld a, [hl] ; Load current subpixel into A
    sub b ; Apply subpixel speed to current subpixel position
    ld [hl], a ; Save back current subpixel pos
    ld a, [CurrentRoadScrollSpeed] ; Load pixel portion of road speed
    adc 0 ; If subpixels overflowed, apply a full pixel to road speed
    ld b, a ; ; A and B now contains the number of pixels to scroll this frame
    ld hl, CurrentRoadScrollPos
    ld a, [hl]          ; \
	sub b               ; | Update the road scroll pixel
	ld [hl], a          ; /
    ; Update RoadScrollCtr, and generate new road line if needed
    ld hl, RoadScrollCtr
    ld a, [hl]
    add b ; B is still the number of lines scrolled this frame
    ld [hl], a
    cp 8 - 1 ; 8 pixels per line, minus 1 so carry can be used as <
    ret nc ; if RoadScrollCtr <= 7 (i.e. < 8), no new line is needed
    sub 8
    ld [hl], a ; hl = RoadScrollCtr
    call GenRoadRow
    ret

InGameVBlank:
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
    ld b, a
    ld a, [IsGameOver]
    or b
    jr nz, .menuBarActive
    call setupStatusBarInterrupt ; If menu bar isn't present, go straight to status bar
    jr .doneLCDIntSetup
.menuBarActive:
    call setupMenuBarInterrupt ; If game is paused, setup menu bar interrupt instead of status bar
.doneLCDIntSetup:
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