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

    ; Copy tileset into VRAM
    ld hl, $8000
    ld de, Tiles
    ld bc, TilesEnd - Tiles
    rst memcpy

    ; TEMP : seed random
    ld hl, $38
    call seedRandom

    ; Initialise variables
    ld a, $9A
    ld [RoadTileWriteAddr], a
    ld a, $20
    ld [RoadTileWriteAddr + 1], a
    ld a, 2
    ld [CurrentRoadScrollSpeed], a
    ld a, $44
    ld [CurrentRoadScrollSpeed + 1], a
    xor a
    ld [CurrentRoadScrollSubpixel], a
    ld [RoadScrollCtr], a
    ld [NeedMoreRoad], a
    ld [CurRoadLeft], a
    ld [CurRoadRight], a
    ld [TarRoadLeft], a
    ld [TarRoadRight], a

    ; Init display registers
	ld a, %11100100 ; Init background palette
	ld [rBGP], a
    xor a ; Init scroll registers
	ld [rSCY], a
    ld a, 16
	ld [rSCX], a

    ; Shut sound down
    xor a
    ld [rNR52], a

    ; Enable screen and initialise screen settings
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINOFF | LCDCF_BG8000 \
        | LCDCF_BG9800 | LCDCF_OBJ8 | LCDCF_OBJOFF | LCDCF_BGON
    ld [rLCDC], a

    ; Disable all interrupts except VBlank
	ld a, IEF_VBLANK
	ld [rIE], a
	ei
GameLoop:
    ; Generate more road if needed
    ld a, [NeedMoreRoad]
    and a
    jr z, .skipRoadGen
    call GenRoadRow
    xor a
    ld [NeedMoreRoad], a
.skipRoadGen:

    halt
    jp GameLoop


VBlank::
    ld a, [CurrentRoadScrollSpeed + 1] ; Load subpixel portion of road speed
    ld b, a ; put that into B
    ld a, [CurrentRoadScrollSubpixel] ; Load current subpixel into A
    sub b ; Apply subpixel speed to current subpixel position
    ld [CurrentRoadScrollSubpixel], a ; Save back current subpixel pos
    ld a, [CurrentRoadScrollSpeed] ; Load pixel portion of road speed
    jr nc, .noSubpixelOverflow
    add 1 ; If subpixels overflowed, apply a full pixel to road speed
.noSubpixelOverflow: ; A now contains the number of pixels to scroll this frame
    ld b, a ; move it to B
    ; Update the road scroll
    ld a, [rSCY]
	sub b
	ld [rSCY], a
    ; Update RoadScrollCtr, and copy new road line if needed
    ld a, [RoadScrollCtr]
    add b ; B is still the number of lines scrolled this frame
    ld [RoadScrollCtr], a
    cp 8 - 1 ; 8 pixels per line, minus 1 so carry can be used as <
    jr nc, .noNewLine ; if RoadScrollCtr <= 7 (i.e. < 8), no new line is needed
    sub 8
    ld [RoadScrollCtr], a
    call CopyRoadBuffer
.noNewLine:

    reti

; Generates a new line of road, and puts it into RoadGenBuffer
GenRoadRow:
    ; Check if we've reached the target left position
    ld a, [TarRoadLeft]
    ld b, a
    ld a, [CurRoadLeft]
    and %00011111 ; remove status bits so CP works
    cp b ; C Set if CurRoadLeft < TarRoadLeft
    jr z, .genNewTarLeft
    jr c, .curLeftIncrement
    ; RoadLeft > TarRoadLeft, turning left
    dec a
    and %11011111 ; disable "turning right" bit
    ld [CurRoadLeft], a
    jr .doneChangeLeft
.curLeftIncrement: ; Turning right
    inc a
    or %00100000 ; enable "turning right" bit
    ld [CurRoadLeft], a
    jr .doneChangeLeft
.genNewTarLeft:
    call genRandom
    ld b, %00011100
    and b
    ld [TarRoadLeft], a
.doneChangeLeft:


    ; Check if we've reached the target right position
    /*ld a, [TarRoadRight]
    ld b, a
    ld a, [CurRoadRight]
    cp b
    jr nz, .dontRenewRight
    call genRandom
    ld [TarRoadRight], a
.dontRenewRight:*/

    ld a, [CurRoadLeft]
    ld l, a
    xor a
    ld h, a ; hl = left
    add hl, hl ; hl = left * 2
    add hl, hl ; hl = left * 4
    ld d, h
    ld e, l ; de = left * 4
    add hl, hl ; hl = left * 8
    add hl, de ; hl = left * 8 + left * 4 = left * 12

    ld de, Tilemap
    add hl, de ; hl = left * 12 + Tilemap

    ld d, h ; Move HL into DE for Memcpy
    ld e, l
    ld hl, RoadGenBuffer
    ld a, 12 ; Half road is 12 tiles wide = 12 bytes
    ld c, a
    rst memcpyFast


    ret

; Copies the road buffer into VRAM
; Sets - A C D E H L to garbage
CopyRoadBuffer:
    ld a, [RoadTileWriteAddr]
    ld h, a
    ld a, [RoadTileWriteAddr + 1]
    ld l, a
    ld de, RoadGenBuffer
    ld c, 24
    rst memcpyFast

    ld a, [RoadTileWriteAddr]
    ld h, a
    ld a, [RoadTileWriteAddr + 1]
    ld l, a
    ld de, -32 ; $FFE0
    add hl, de
    ; if we're below 9800 (start of tilemap)
    ; we have to reset to the end of the tilemap ($9BE0)
    ld a, h
    cp $97
    jr nz, .noReset
    ld hl, $9BE0
.noReset:
    ld a, h
    ld [RoadTileWriteAddr], a
    ld a, l
    ld [RoadTileWriteAddr + 1], a
    ld a, 1
    ld [NeedMoreRoad], a
    ret