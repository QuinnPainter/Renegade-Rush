INCLUDE "hardware.inc"
INCLUDE "macros.inc"
INCLUDE "spriteallocation.inc"

DEF WARNING_TILE_OFFSET EQUS "((WarningTilesVRAM - $8000) / 16)"

DEF ROAD_OBJ_TICK_RATE EQU 6 * 4 ; Frequency that the warning flashes in. Should match the tempo of the song * 4

SECTION "Road Object Vars", WRAM0
RoadObjSpawnChance:: DS 2 ; little endian
RoadObjState:: DS 1 ; 0 = Inactive, 1 = Warning Flashing, 2 = Active
RoadObjTickCtr: DS 1
WarningFlashCtr: DS 1

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
    ld a, 40 ; temp - set x
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (WARNING_SPRITE + 0)) + OAMA_X], a
    add 8
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (WARNING_SPRITE + 1)) + OAMA_X], a
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
    ld a, 16
.setWarningFlash:
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (WARNING_SPRITE + 0)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (WARNING_SPRITE + 1)) + OAMA_Y], a
.doneChangeWarningFlash:


    ld a, [WarningFlashCtr]
    cp 6
    ret nz
    xor a
    ld [RoadObjState], a
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
    ret