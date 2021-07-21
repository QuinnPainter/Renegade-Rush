include "hardware.inc/hardware.inc"
include "spriteallocation.inc"
include "macros.inc"
include "collision.inc"

BASE_KNOCKBACK_FRAMES EQU 30
BASE_KNOCKBACK_SPEED EQU $00FF

; Set the tiles and attributes from PoliceCarTilemap and PoliceCarAttrmap
; C = Offset into tilemap (number of tiles)
; Sets - A to garbage
MACRO set_car_tiles
    ld b, 0

    ld hl, PoliceCarTilemap ; Set tiles
    add hl, bc
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

    ld hl, PoliceCarAttrmap ; Set sprite attributes
    add hl, bc
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
EnemyCarX: DS 2 ; Coordinates of the top-left of the car. 8.8 fixed point.
EnemyCarY: DS 2
EnemyCarXSpeed: DS 2 ; Speed of the car moving left and right on the screen in pixels per frame. 8.8 fixed point.
EnemyCarRoadSpeed: DS 2 ; Speed of the car, in terms of road scroll speed. 8.8 fixed point.
EnemyCarAcceleration: DS 2 ; Car's road scroll acceleration - pixels per frame per frame. 8.8 fixed point.
EnemyCarAnimationTimer: DS 1 ; Incremented every frame. Used to update animations.
EnemyCarAnimationState: DS 1 ; Current state of the animation. 0 = state 1, FF = state 2
RemainingKnockbackFrames: DS 1 ; Number of frames left in the knockback animation.
CurrentKnockbackSpeedX: DS 2 ; Speed of the current knockback effect, in pixels per frame. 8.8 fixed point.
CurrentKnockbackSpeedY: DS 2

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
    xor a
    ld [EnemyCarAnimationTimer], a
    ld [EnemyCarAnimationState], a
    ld [RemainingKnockbackFrames], a
    ld [CurrentKnockbackSpeedX], a
    ld [CurrentKnockbackSpeedX + 1], a
    ld [CurrentKnockbackSpeedY], a
    ld [CurrentKnockbackSpeedY + 1], a
    ret

updateEnemyCar::
    ; Update animation state
    ld a, [EnemyCarAnimationTimer]
    inc a
    ld [EnemyCarAnimationTimer], a
    and %00001111 ; every 16 frames
    jr nz, .noUpdateAnimation
    ld a, [EnemyCarAnimationState]
    cpl
    ld [EnemyCarAnimationState], a
.noUpdateAnimation:

    ld a, [RemainingKnockbackFrames]
    and a
    jr z, .noKnockback
    dec a
    ld [RemainingKnockbackFrames], a
    add_16 CurrentKnockbackSpeedX, EnemyCarX, EnemyCarX
    add_16 CurrentKnockbackSpeedY, EnemyCarY, EnemyCarY
.noKnockback:

    ; Take car speed from road speed to get the Y offset
    sub_16 CurrentRoadScrollSpeed, EnemyCarRoadSpeed, Scratchpad
    ; Add Y offset to Y coordinate
    add_16 Scratchpad, EnemyCarY, EnemyCarY

    ld c, 0
    ld a, [EnemyCarAnimationState]
    and a
    jr z, .animState1
    ld a, 18
    add c
    ld c, a
.animState1:
    set_car_tiles

    RoadEdgeCollision EnemyCarX, EnemyCarY

    ; Update entry in object collision array
    ld hl, ObjCollisionArray + ENEMYCAR_COLLISION_1
    ld a, %00000001 ; Collision Layer Flags
    ld [hli], a
    ld a, [EnemyCarY] ; Top Y
    ld [hli], a
    add 24 ; Bottom Y - car is 24 px tall
    ld [hli], a
    ld a, [EnemyCarX] ; Left X
    ld [hli], a
    add 16 ; Right X - car is 16 px wide
    ld [hl], a

    ld a, ENEMYCAR_COLLISION_1
    call objCollisionCheck
    and a
    jr z, .noCol
    ; collision happened - now apply knockback
    ld a, e ; move movement info to A
    and $07 ; isolate the last 3 bits of speed value. (bug - speeds above 7 will be treated as 0. does this matter? 7 is crazy fast)
    srl a ; shift right once. now A is in the range 0-3
    ld c, a
    ld b, BASE_KNOCKBACK_FRAMES
    call shiftLeft ; shift the base knockback by the modified speed value. multiplies by 0, 1, 2 or 4
    ld a, b
    ld [RemainingKnockbackFrames], a ; save new knockback frames
.noCol:

    ; Move the 6 car sprites to (EnemyCarX, EnemyCarY)
    ld a, [EnemyCarX]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 0)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 2)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 4)) + OAMA_X], a
    add 8
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 1)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 3)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 5)) + OAMA_X], a
    ld a, [EnemyCarY]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 0)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 1)) + OAMA_Y], a
    add 8
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 2)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 3)) + OAMA_Y], a
    add 8
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 4)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (ENEMYCAR_SPRITE_1 + 5)) + OAMA_Y], a
    ret