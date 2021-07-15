include "hardware.inc/hardware.inc"
include "spriteallocation.inc"

; Set the tiles and attributes from PoliceCarTilemap and PoliceCarAttrmap
; \1 = Offset into tilemap (number of tiles)
; Sets - A to garbage
MACRO SetCarTilesAndAttributes
    ld hl, PoliceCarTilemap + \1 ; Set tiles
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 0)) + OAMA_TILEID], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 1)) + OAMA_TILEID], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 2)) + OAMA_TILEID], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 3)) + OAMA_TILEID], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 4)) + OAMA_TILEID], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 5)) + OAMA_TILEID], a

    ld hl, PoliceCarAttrmap + \1 ; Set sprite attributes
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 0)) + OAMA_FLAGS], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 1)) + OAMA_FLAGS], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 2)) + OAMA_FLAGS], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 3)) + OAMA_FLAGS], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 4)) + OAMA_FLAGS], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 5)) + OAMA_FLAGS], a
ENDM

SECTION "EnemyCarVariables", WRAM0
EnemyCarX:: DS 2 ; Coordinates of the top-left of the car. 8.8 fixed point.
EnemyCarY:: DS 2
EnemyCarXSpeed:: DS 2 ; Speed of the car moving left and right on the screen in pixels per frame. 8.8 fixed point.
EnemyCarRoadSpeed:: DS 2 ; Speed of the car, in terms of road scroll speed. 8.8 fixed point.
EnemyCarAcceleration:: DS 2 ; Car's road scroll acceleration - pixels per frame per frame. 8.8 fixed point.

SECTION "EnemyCarCode", ROM0

initEnemyCar::
    call genRandom
    and %10111111 ; gen number between -65 and 63
    add (160 / 2) ; add that to the X of the middle of the screen, to get a possible range of 15 to 143
    ld [EnemyCarX], a
    xor a
    ld [EnemyCarX + 1], a
    ld a, $70
    ld [EnemyCarY], a
    xor a
    ld [EnemyCarY + 1], a
    ld a, $2
    ld [EnemyCarXSpeed], a
    xor a
    ld [EnemyCarXSpeed + 1], a
    ld a, $2
    ld [EnemyCarRoadSpeed], a
    ld a, $CC
    ld [EnemyCarRoadSpeed + 1], a
    xor a
    ld [EnemyCarAcceleration], a
    ld a, $05
    ld [EnemyCarAcceleration + 1], a
    ret

updateEnemyCar::
    SetCarTilesAndAttributes 0
    ret