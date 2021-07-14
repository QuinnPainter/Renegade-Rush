INCLUDE "hardware.inc/hardware.inc"

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
	ld hl, SpriteBuffer
	ld c, SpriteBufferEnd - SpriteBuffer
	ld d, 0
	rst memsetFast

    ; Copy tileset into VRAM
    ld hl, RoadTilesVRAM
    ld de, Tiles
    ld bc, TilesEnd - Tiles
    rst memcpy
    ld hl, PlayerTilesVRAM
    ld de, PlayerTiles
    ld bc, PlayerTilesEnd - PlayerTiles
    rst memcpy
    ld hl, PoliceCarTilesVRAM
    ld de, PoliceCarTiles
    ld bc, PoliceCarTilesEnd - PoliceCarTiles
    rst memcpy

    ; TEMP : seed random
    ld hl, $9574;$38
    call seedRandom

    ; Copies the OAM DMA routine into HRAM
    ld hl, DMARoutineHRAM
    ld de, DMARoutine
    ld c, 14
    rst memcpyFast

    ; Initialise variables
    jp InitRoadGen
.doneInitRoad::
    jp initPlayer
.doneInitPlayer::

    ; Generate enough road for the whole screen, plus 1 extra line
    REPT 19 ; could make this into a regular loop instead of REPT, if needed
    call GenRoadRow
    call CopyRoadBuffer
    ENDR

    ; Init display registers
	ld a, %11100100 ; Init background palette
	ldh [rBGP], a
    ld [rOBP0], a ; Init sprite palettes
	ld [rOBP1], a
    xor a ; Init scroll registers
	ldh [rSCY], a
    ld a, 16
	ldh [rSCX], a

    ; Shut sound down
    xor a
    ldh [rNR52], a

    ; Enable screen and initialise screen settings
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINOFF | LCDCF_BG8800 \
        | LCDCF_BG9800 | LCDCF_OBJ8 | LCDCF_OBJON | LCDCF_BGON
    ldh [rLCDC], a

    ; Disable all interrupts except VBlank
	ld a, IEF_VBLANK
	ldh [rIE], a
    xor a
    ldh [rIF], a ; Discard all pending interrupts (there would normally be a VBlank pending)
	ei
GameLoop:
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

    call readInput

    jp updatePlayer
.doneUpdatePlayer::


    halt
    jp GameLoop


VBlank::
    push af
    push bc
    push de

    ; Copy new road line onto the background tilemap if one is ready
    ld a, [RoadLineReady]
    and a ; update zero flag
    call nz, CopyRoadBuffer

    ; Update Scroll Y
    ld a, [CurrentRoadScrollPos]
    ldh [rSCY], a

    ; Copy sprite buffer into OAM
    call DMARoutineHRAM

    pop de
    pop bc
    pop af
    reti