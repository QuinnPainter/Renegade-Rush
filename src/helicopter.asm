INCLUDE "hardware.inc"
INCLUDE "macros.inc"
INCLUDE "spriteallocation.inc"

DEF HELI_TILE_OFFSET EQUS "((HelicopterTilesVRAM - $8000) / 16)"

DEF HELI_ANIM_SPEED EQU 3 ; Number of frames between each animation cel.
DEF HELI_NUM_ANIM_CELS EQU 8 ; Number of animation cels.

SECTION "HelicopterVars", WRAM0
HelicopterX: DS 2 ; Coordinates of the top-left of the heli. 8.8 fixed point.
HelicopterY: DS 2
HeliAnimationFrameCtr: DS 1
HeliAnimationCel: DS 1

SECTION "HelicopterCode", ROM0

initHelicopter::
    xor a ; Set sprite attributes - no flip and no BG over OBJ
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 0)) + OAMA_FLAGS], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 1)) + OAMA_FLAGS], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 2)) + OAMA_FLAGS], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 3)) + OAMA_FLAGS], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 4)) + OAMA_FLAGS], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 5)) + OAMA_FLAGS], a
    ld a, 1
    ld [HeliAnimationCel], a
    ld [HeliAnimationFrameCtr], a
    ld a, 32
    ld [HelicopterX], a
    ld [HelicopterY], a
    ret

updateHelicopter::
    ; Update animation
    ld hl, HeliAnimationFrameCtr
    dec [hl]
    jr nz, .noUpdateAnim
    ld a, HELI_ANIM_SPEED
    ld [hl], a
    ld hl, HeliAnimationCel
    dec [hl]
    jr nz, .noResetCel
    ld a, HELI_NUM_ANIM_CELS
    ld [hl], a
.noResetCel:
    ld a, [hl]  ; HeliAnimation Cel is 1-8, but there are only 3 actual frames of animation
    bit 0, a    ; use noRotorCel frame if HeliAnimationCel is an even number
    jr z, .noRotorCel
    cp 5        ; use rotorCel1 frame if HeliAnimationCel is 1 to 4
    jr c, .rotorCel1
    ld a, 2     ; use rotorCel2 frame if HeliAnimationCel is 5 to 8
    jr .doneFindCel
.noRotorCel:
    ld a, 1
    jr .doneFindCel
.rotorCel1:
    xor a
.doneFindCel:
    sla a ; a = AnimationCel * 2
    ld b, a
    sla a ; a = AnimationCel * 4
    add b ; a = AnimationCel * 6
    add HELI_TILE_OFFSET ; a = HELI_TILE_OFFSET + (AnimationCel * 6)
    ld b, 2
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 0)) + OAMA_TILEID], a
    add b
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 1)) + OAMA_TILEID], a
    add b
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 2)) + OAMA_TILEID], a
    add 14
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 3)) + OAMA_TILEID], a
    add b
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 4)) + OAMA_TILEID], a
    add b
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 5)) + OAMA_TILEID], a
.noUpdateAnim:

    ; Update sprite positions
    ld a, [HelicopterX]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 0)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 3)) + OAMA_X], a
    add 8
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 1)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 4)) + OAMA_X], a
    add 8
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 2)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 5)) + OAMA_X], a
    ld a, [HelicopterY]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 0)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 1)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 2)) + OAMA_Y], a
    add 16
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 3)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 4)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 5)) + OAMA_Y], a
    ret