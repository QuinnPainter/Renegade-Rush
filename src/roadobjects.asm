INCLUDE "hardware.inc"
INCLUDE "macros.inc"
INCLUDE "spriteallocation.inc"

DEF WARNING_TILE_OFFSET EQUS "((WarningTilesVRAM - $8000) / 16)"
DEF BOULDER_TILE_OFFSET EQUS "((BoulderTilesVRAM - $9000) / 16)"

DEF ROAD_OBJ_TICK_RATE EQU 6 * 4 ; Frequency that the warning flashes in. Should match the tempo of the song * 4
DEF WARNING_Y_POS EQU 20

SECTION "Road Object Vars", WRAM0
RoadObjSpawnChance:: DS 2 ; little endian
RoadObjState:: DS 1 ; 0 = Inactive, 1 = Warning Flashing, 2 = Active
RoadObjTickCtr: DS 1
WarningFlashCtr: DS 1
RoadObjTileX: DS 1 ; X position in tiles, relative to the start of the line in VRAM.
RoadObjSpriteX: DS 1 ; X position in sprite terms, used for the warning sign + object collision box.

SECTION "Road Object Code", ROM0

; Initialise road object variables
initRoadObject::
    xor a
    ld [RoadObjState], a
    ld a, ROAD_OBJ_TICK_RATE
    ld [RoadObjTickCtr], a
    xor a ; Set sprite attributes
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (WARNING_SPRITE + 0)) + OAMA_FLAGS], a
    ld a, OAMF_XFLIP
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (WARNING_SPRITE + 1)) + OAMA_FLAGS], a
    ld a, WARNING_TILE_OFFSET ; Set sprite tiles
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (WARNING_SPRITE + 0)) + OAMA_TILEID], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (WARNING_SPRITE + 1)) + OAMA_TILEID], a
    xor a ; Put sprites offscreen
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (WARNING_SPRITE + 0)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (WARNING_SPRITE + 1)) + OAMA_Y], a
    ret

; Update road object every frame
updateRoadObject::
    ld hl, RoadObjTickCtr
    dec [hl]
    jr nz, .noResetTickCtr
    ld a, ROAD_OBJ_TICK_RATE
    ld [hl], a
.noResetTickCtr:

    ld a, [RoadObjState]
    and a
    jr z, .stateInactive
    dec a
    jr z, .stateWarning
    ; Active State
    xor a ;todo
    ld [RoadObjState], a
    ret

.stateWarning:
    ld a, [RoadObjTickCtr]
    cp ROAD_OBJ_TICK_RATE
    jr nz, .doneChangeWarningFlash
    ld hl, WarningFlashCtr
    inc [hl]
    bit 0, [hl]
    jr nz, .warningFlashVisible
    xor a ; Put sprites offscreen
    jr .setWarningFlash
.warningFlashVisible:
    play_sound_effect FX_WarningBeep
    ld a, WARNING_Y_POS
.setWarningFlash:
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (WARNING_SPRITE + 0)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (WARNING_SPRITE + 1)) + OAMA_Y], a
.doneChangeWarningFlash:

    ld a, [WarningFlashCtr]
    cp 6
    ret nz ; warning is done - time to place the object
    ld a, 2 ; set state to Active
    ld [RoadObjState], a
    ld hl, RoadTileWriteAddr ; draw boulder
    ld a, [hli]
    ld l, [hl]
    ld h, a
    call nextVRAMLine
    ld a, [RoadObjTileX]
    add l
    ld l, a
    ld b, BOULDER_TILE_OFFSET
    call drawObjectTile
    inc b
    inc l
    call drawObjectTile
    call nextVRAMLine
    ld a, [RoadObjTileX]
    add l
    ld l, a
    inc b
    call drawObjectTile
    inc b
    inc l
    call drawObjectTile
    ret

.stateInactive:
    call genRandom
    ld a, [RoadObjSpawnChance]
    sub l
    ld a, [RoadObjSpawnChance + 1]
    sbc h
    ret c

    ld a, 1 ; change state to Warning
    ld [RoadObjState], a
    xor a
    ld [WarningFlashCtr], a

    call genRandom
    and $F ; get number from 0 to 15
    add 4 ; get number from 4 to 19
    ld [RoadObjTileX], a
    add a ; multiply by 8
    add a
    add a
    sub 8 ; shift sprite X to line up with tile X
    ld [RoadObjSpriteX], a

    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (WARNING_SPRITE + 0)) + OAMA_X], a ; set warning sprite X
    add 8
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (WARNING_SPRITE + 1)) + OAMA_X], a
    ret

; Finds the address of the beginning of the next line in the $9800 tilemap in VRAM
; Input - HL = Address in VRAM
; Sets - HL = Next Line Address
; Sets - A to garbage
nextVRAMLine:
    ld a, l
    and $E0 ; return to the beginning of the line
    add 32
    ld l, a
    ret nc
    inc h
    ld a, h
    cp $9C
    ret nz ; if we're above 9C00 (end of tilemap)
    ld hl, $9800 ; we have to reset to the start of the tilemap ($9800)
    ret

; Waits for VRAM and draws 1 tile
; Input - HL = Address to write to
; Input - B = Tile index
; Sets - A to garbage
drawObjectTile:
    ldh a, [rSTAT]          ; \
    and STATF_BUSY          ; | Wait for VRAM to be ready
    jr nz, drawObjectTile   ; /
    ld [hl], b
    ret