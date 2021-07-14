INCLUDE "hardware.inc/hardware.inc"
INCLUDE "gameconstants.inc"

MinRoadWidth EQU 6
MaxRoadOffset EQU (14 - MinRoadWidth)

; Generates one side of the road.
; \1 = 0 for left side, 1 for right side
; Sets - A B C D E H L to garbage
MACRO GenRoadSide
IF \1 == 0
DEF TarRoad EQUS "TarRoadLeft"
DEF TarOtherSide EQUS "TarRoadRight"
DEF CurRoad EQUS "CurRoadLeft"
DEF RoadCollisionTableX EQUS "RoadCollisionTableLeftX"
DEF RoadCollisionTableFlags EQUS "RoadCollisionTableLeftFlags"
DEF RoadCollisionWriteIndex EQUS "RoadCollisionWriteIndexLeft"
DEF RoadGenBufferOffset EQU 0
ELSE
DEF TarRoad EQUS "TarRoadRight"
DEF TarOtherSide EQUS "TarRoadLeft"
DEF CurRoad EQUS "CurRoadRight"
DEF RoadCollisionTableX EQUS "RoadCollisionTableRightX"
DEF RoadCollisionTableFlags EQUS "RoadCollisionTableRightFlags"
DEF RoadCollisionWriteIndex EQUS "RoadCollisionWriteIndexRight"
DEF RoadGenBufferOffset EQU 12
ENDC
    ; Check if we've reached the target position
    ld a, [TarRoad]
    ld b, a
    ld a, [CurRoad]
    and %00011111 ; remove status bits so CP works
    cp b ; C Set if CurRoad < TarRoad
    jr z, .genNewTar\@
    jr c, .curIncrement\@
    ; CurRoad > TarRoad, turning inward
    dec a
    and %11011111 ; disable "turning right" bit
    ld [CurRoad], a
    jr .doneChange\@
.curIncrement\@: ; Turning outward
    inc a
    or %00100000 ; enable "turning right" bit
    ld [CurRoad], a
    jr .doneChange\@
.genNewTar\@:
    call genRandom
    and %11100000 ; check that 3 bits are all 0 = 1 in 8
    jr nz, .doneChange\@ ; 1 in 8: gen new turn, 7 in 8: stay straight
    ld a, l
    and %00011100
    ld [TarRoad], a

    sra a ; needs to be shifted right to discard subtile position
    sra a
    ld b, a ; b = TarRoad
    ld a, [TarOtherSide]
    sra a
    sra a
    add b ; a = TarOtherSide + TarRoad
    sub MaxRoadOffset ; a = (TarOtherSide + TarRoad) - MaxRoadOffset
    jr c, .doneChange\@ ; Current offset is within limits, carry on
    ld c, a ; c = (TarOtherSide + TarRoad) - MaxRoadOffset
    ld a, b ; a = TarRoad
    sub c ; Take away from TarRoad so it becomes within MaxRoadOffset
    add a ; same as "sla a"
    add a
    ld [TarRoad], a

.doneChange\@:

    ld a, [CurRoad]
IF \1 == 1
    or %01000000 ; enable "right side of road" bit
ENDC
    ld l, a
    xor a
    ld h, a ; hl = index
    add hl, hl ; hl = index * 2
    add hl, hl ; hl = index * 4
    ld d, h
    ld e, l ; de = index * 4
    add hl, hl ; hl = index * 8
    push hl ; save HL (index * 8) for indexing into collision array
    add hl, de ; hl = index * 8 + index * 4 = index * 12

    ld de, Tilemap
    add hl, de ; hl = index * 12 + Tilemap

    ld d, h ; Move HL into DE for Memcpy
    ld e, l
    ld hl, RoadGenBuffer + RoadGenBufferOffset
    ld a, 12 ; Half road is 12 tiles wide = 12 bytes
    ld c, a
    rst memcpyFast

    ld de, RoadCollisionROM
    pop hl ; hl = index * 8
    add hl, hl ; hl = index * 16
    add hl, de ; hl = addr in RoadCollisionROM

    ld a, [RoadCollisionWriteIndex] ; \
    ld e, a                         ; | DE = Addr into RoadCollisionTableX
    ld d, RoadCollisionTableX >> 8  ; /

    ld c, a                             ; \ BC = Addr into RoadCollisionTableFlags
    ld b, RoadCollisionTableFlags >> 8  ; /
REPT 8 ; Since all regs are used in this loop, a normal loop is tricky. This will do.
    ld a, [hli] ; Load X
    ld [de], a
    ld a, [hli] ; Load Flags
    ld [bc], a
    dec c ; Since the tables are page-aligned, only need to change last byte of address
    dec e
ENDR
    ld a, e
    ld [RoadCollisionWriteIndex], a
PURGE TarRoad
PURGE CurRoad
PURGE RoadGenBufferOffset
PURGE TarOtherSide
PURGE RoadCollisionTableX
PURGE RoadCollisionTableFlags
PURGE RoadCollisionWriteIndex
ENDM

SECTION "RoadVariables", WRAM0
CurrentRoadScrollPos:: DS 2 ; 8.8 fixed-point number. Top byte is copied into rSCY every frame.
RoadScrollCtr:: DB ; Increases by 1 for each pixel scrolled, so a new road line is made every 8 pixels
RoadGenBuffer:: DS 24 ; Cache of the road tiles which are then copied to VRAM during Vblank
RoadTileWriteAddr:: DS 2 ; The next VRAM address to write a road tile to.
RoadCollisionWriteIndexLeft:: DB ; The next RoadCollisionTable index to write to.
RoadCollisionWriteIndexRight:: DB
RoadLineReady:: DB ; Whether there is a line of road generated and ready to copy into VRAM (0 - false, nonzero - true)

; Road positions are the following format:
; First 3 bits - not stored in RAM, but are used in road gen
;    bit 1 = unused
;    bit 2 = 0 - left side of road, 1 - right side
;    bit 3 = 0 - turning left, 1 - turning right
; Next 3 bits - tile number (0 - 7)
; Last 2 bits - subtile number (0 - 3)
; 3.2 fixed-point, essentially
CurRoadLeft:: DB ; X position of the left of the road.
CurRoadRight:: DB ; X position of the right of the road.
TarRoadLeft:: DB ; Target X position of the left. Road generation will try to lead the road here.
TarRoadRight:: DB ; Target X position of the right. Road generation will try to lead the road here.

SECTION "RoadCollisionTable", WRAM0, ALIGN[8]
; Stores the collision information for the whole road
; 8 * 32 because 8 pixels per line * 32 lines in VRAM
; Flags is currently just:
; 0 = Slope / Wall (pushes car out if hit)
; 1 = Hard stop (explodes car if hit)
RoadCollisionTableLeftX:: DS 8 * 32
RoadCollisionTableRightX:: DS 8 * 32
RoadCollisionTableLeftFlags:: DS 8 * 32
RoadCollisionTableRightFlags:: DS 8 * 32

SECTION "RoadGenCode", ROM0

InitRoadGen::
    ld a, $9A
    ld [RoadTileWriteAddr], a
    ld a, $20
    ld [RoadTileWriteAddr + 1], a
    ld a, 17 * 8
    ld [RoadCollisionWriteIndexLeft], a
    ld [RoadCollisionWriteIndexRight], a
    xor a
    ld [CurrentRoadScrollPos], a
    ld [CurrentRoadScrollPos + 1], a
    ld [RoadScrollCtr], a
    ld [CurRoadLeft], a
    ld [CurRoadRight], a
    ld [TarRoadLeft], a
    ld [TarRoadRight], a
    ld [RoadLineReady], a
    jp EntryPoint.doneInitRoad

; Generates a new line of road, and puts it into RoadGenBuffer
; could split right + left side and run them on alternate frames?
GenRoadRow::
    GenRoadSide 0 ; left side
    GenRoadSide 1 ; right side

    ld a, 1
    ld [RoadLineReady], a
    ret

; Copies the road buffer into VRAM
; Sets - A C D E H L to garbage
CopyRoadBuffer::
    ld a, [RoadTileWriteAddr]
    ld h, a
    ld a, [RoadTileWriteAddr + 1]
    ld l, a
    ld de, RoadGenBuffer
    ld c, 24
    rst memcpyFast

    ld a, [RoadTileWriteAddr + 1]
    sub 32
    ld c, a
    jr nc, .noCarry
    ld a, [RoadTileWriteAddr]
    dec a
    cp $97
    jr nz, .noReset
    ld c, $E0 ; if we're below 9800 (start of tilemap)
    ld a, $9B ; we have to reset to the end of the tilemap ($9BE0)
.noReset:
    ld [RoadTileWriteAddr], a
    ld a, c
.noCarry:
    ld [RoadTileWriteAddr + 1], a
    
    xor a
    ld [RoadLineReady], a
    ret