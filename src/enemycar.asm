include "hardware.inc/hardware.inc"
include "spriteallocation.inc"
include "macros.inc"
include "collision.inc"

BASE_KNOCKBACK_FRAMES EQU 10

RSRESET
DEF EnemyCarX RB 2 ; Coordinates of the top-left of the car. 8.8 fixed point.
DEF EnemyCarY RB 2
DEF EnemyCarXSpeed RB 2 ; Speed of the car moving left and right on the screen in pixels per frame. 8.8 fixed point.
DEF EnemyCarRoadSpeed RB 2 ; Speed of the car, in terms of road scroll speed. 8.8 fixed point.
DEF EnemyCarAcceleration RB 2 ; Car's road scroll acceleration - pixels per frame per frame. 8.8 fixed point.
DEF EnemyCarAnimationTimer RB 1 ; Incremented every frame. Used to update animations.
DEF EnemyCarAnimationState RB 1 ; Current state of the animation. 0 = state 1, FF = state 2
DEF RemainingKnockbackFrames RB 1 ; Number of frames left in the knockback animation.
DEF CurrentKnockbackSpeedX RB 2 ; Speed of the current knockback effect, in pixels per frame. 8.8 fixed point.
DEF CurrentKnockbackSpeedY RB 2
DEF sizeof_EnemyCarVars RB 0

MACRO init_enemy_car
DEF CAR_STATE_BASE_ADDR\@ EQUS "\1"
    call genRandom
    and %01111111 ; gen number between 0 and 127
    add (160 / 2) - 64 ; add that to the X of the middle of the screen - 64, to get a possible range of 16 to 143
    ld [CAR_STATE_BASE_ADDR\@ + EnemyCarX], a
    xor a
    ld [CAR_STATE_BASE_ADDR\@ + EnemyCarX + 1], a
    ld a, $70
    ld [CAR_STATE_BASE_ADDR\@ + EnemyCarY], a
    xor a
    ld [CAR_STATE_BASE_ADDR\@ + EnemyCarY + 1], a
    ld a, $2
    ld [CAR_STATE_BASE_ADDR\@ + EnemyCarXSpeed], a
    xor a
    ld [CAR_STATE_BASE_ADDR\@ + EnemyCarXSpeed + 1], a
    ld a, $2
    ld [CAR_STATE_BASE_ADDR\@ + EnemyCarRoadSpeed], a
    ld a, $CC
    ld [CAR_STATE_BASE_ADDR\@ + EnemyCarRoadSpeed + 1], a
    xor a
    ld [CAR_STATE_BASE_ADDR\@ + EnemyCarAcceleration], a
    ld a, $05
    ld [CAR_STATE_BASE_ADDR\@ + EnemyCarAcceleration + 1], a
    xor a
    ld [CAR_STATE_BASE_ADDR\@ + EnemyCarAnimationTimer], a
    ld [CAR_STATE_BASE_ADDR\@ + EnemyCarAnimationState], a
    ld [CAR_STATE_BASE_ADDR\@ + RemainingKnockbackFrames], a
    ld [CAR_STATE_BASE_ADDR\@ + CurrentKnockbackSpeedX], a
    ld [CAR_STATE_BASE_ADDR\@ + CurrentKnockbackSpeedX + 1], a
    ld [CAR_STATE_BASE_ADDR\@ + CurrentKnockbackSpeedY], a
    ld [CAR_STATE_BASE_ADDR\@ + CurrentKnockbackSpeedY + 1], a
PURGE CAR_STATE_BASE_ADDR\@
ENDM

; Set the tiles and attributes from PoliceCarTilemap and PoliceCarAttrmap
; Input - \1 = Which sprite to write to
; Input - C = Offset into tilemap (number of tiles)
; Sets - A to garbage
; Sets - B to 0
MACRO set_car_tiles
    ld b, 0

    rom_bank_switch BANK("PoliceCarTilemap")
    ld hl, PoliceCarTilemap ; Set tiles
    add hl, bc
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (\1 + 0)) + OAMA_TILEID], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (\1 + 1)) + OAMA_TILEID], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (\1 + 2)) + OAMA_TILEID], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (\1 + 3)) + OAMA_TILEID], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (\1 + 4)) + OAMA_TILEID], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (\1 + 5)) + OAMA_TILEID], a

    rom_bank_switch BANK("PoliceCarAttrmap")
    ld hl, PoliceCarAttrmap ; Set sprite attributes
    add hl, bc
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (\1 + 0)) + OAMA_FLAGS], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (\1 + 1)) + OAMA_FLAGS], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (\1 + 2)) + OAMA_FLAGS], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (\1 + 3)) + OAMA_FLAGS], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (\1 + 4)) + OAMA_FLAGS], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (\1 + 5)) + OAMA_FLAGS], a
ENDM

; \1 = Car State Offset
; \2 = Sprite Offset
; \3 = Collision Array Offset
MACRO update_enemy_car
DEF CAR_SPRITE\@ EQUS "\2"
DEF CAR_OBJ_COLLISION\@ EQUS "\3"
    ; Update animation state
    ld a, [\1 + EnemyCarAnimationTimer]
    inc a
    ld [\1 + EnemyCarAnimationTimer], a
    and %00001111 ; every 16 frames
    jr nz, .noUpdateAnimation\@
    ld a, [\1 + EnemyCarAnimationState]
    cpl
    ld [\1 + EnemyCarAnimationState], a
.noUpdateAnimation\@:

    ld a, [\1 + RemainingKnockbackFrames]
    and a
    jr z, .noKnockback\@
    dec a
    ld [\1 + RemainingKnockbackFrames], a
    add_16 \1 + CurrentKnockbackSpeedX, \1 + EnemyCarX, \1 + EnemyCarX
    add_16 \1 + CurrentKnockbackSpeedY, \1 + EnemyCarY, \1 + EnemyCarY
.noKnockback\@:

    ; Take car speed from road speed to get the Y offset
    sub_16 CurrentRoadScrollSpeed, \1 + EnemyCarRoadSpeed, Scratchpad
    ; Add Y offset to Y coordinate
    add_16 Scratchpad, \1 + EnemyCarY, \1 + EnemyCarY

    ld c, 0
    ld a, [\1 + EnemyCarAnimationState]
    and a
    jr z, .animState1\@
    ld a, 18
    add c
    ld c, a
.animState1\@:
    set_car_tiles CAR_SPRITE\@

    ;road_edge_collision \1 + EnemyCarX, \1 + EnemyCarY

    ; Update entry in object collision array
    ld hl, ObjCollisionArray + CAR_OBJ_COLLISION\@
    ld a, %00000001 ; Collision Layer Flags
    ld [hli], a
    ld a, [\1 + EnemyCarY] ; Top Y
    ld [hli], a
    add 24 ; Bottom Y - car is 24 px tall
    ld [hli], a
    ld a, [\1 + EnemyCarX] ; Left X
    ld [hli], a
    add 16 ; Right X - car is 16 px wide
    ld [hli], a
    ld a, [\1 + EnemyCarRoadSpeed]
    ld [hl], a

    ld a, CAR_OBJ_COLLISION\@
    call objCollisionCheck
    and a
    jp z, .noCol\@ ; collision happened - now apply knockback
    rom_bank_switch BANK("PoliceCarCollision")
    process_knockback BASE_KNOCKBACK_FRAMES, \1 + RemainingKnockbackFrames, \1 + EnemyCarX, \
        \1 + EnemyCarY, PoliceCarCollision, \1 + CurrentKnockbackSpeedX, \1 + CurrentKnockbackSpeedY
.noCol\@:

    ; Move the 6 car sprites to (EnemyCarX, EnemyCarY)
    ld a, [\1 + EnemyCarX]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 0)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 2)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 4)) + OAMA_X], a
    add 8
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 1)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 3)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 5)) + OAMA_X], a
    ld a, [\1 + EnemyCarY]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 0)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 1)) + OAMA_Y], a
    add 8
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 2)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 3)) + OAMA_Y], a
    add 8
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 4)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 5)) + OAMA_Y], a
PURGE CAR_SPRITE\@
PURGE CAR_OBJ_COLLISION\@
ENDM

SECTION "EnemyCarStates", WRAM0
EnemyCarState1: DS sizeof_EnemyCarVars
EnemyCarState2: DS sizeof_EnemyCarVars
EnemyCarState3: DS sizeof_EnemyCarVars

SECTION "EnemyCarCode", ROM0

initEnemyCars::
    init_enemy_car EnemyCarState1
    init_enemy_car EnemyCarState2
    init_enemy_car EnemyCarState3
    ret

updateEnemyCars::
    update_enemy_car EnemyCarState1, ENEMYCAR_SPRITE_1, ENEMYCAR_COLLISION_1
    update_enemy_car EnemyCarState2, ENEMYCAR_SPRITE_2, ENEMYCAR_COLLISION_2
    update_enemy_car EnemyCarState3, ENEMYCAR_SPRITE_3, ENEMYCAR_COLLISION_3
    ret