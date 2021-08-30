include "hardware.inc"
include "spriteallocation.inc"
include "macros.inc"
include "collision.inc"

DEF EXPLOSION_TILE_OFFSET EQUS "((Explosion1TilesVRAM - $8000) / 16)"

DEF DESTROYED_MONEY_GIVEN EQU $0020 ; Money given to the player when the enemy is destroyed. 16 bit BCD

; Car tries to have a speed within:
; CurrentRoadScrollSpeed - PLAYER_SPEED_WINDOW and CurrentRoadScrollSpeed + PLAYER_SPEED_WINDOW. 8 bit integer.
DEF PLAYER_SPEED_WINDOW EQU 1

DEF BASE_KNOCKBACK_SLOWDOWN EQU 10 ; How fast the car slows down after being hit, in 255s of a pixel per frame per frame
DEF CAR_SPAWN_CHANCE EQU 127 ; Chance of the car spawning each frame, out of 65535
; So, if you calculate 1 / (CAR_SPAWN_CHANCE / 65535), you get the avg number of frames for it to spawn
; so 520 frames, or 8 seconds
DEF EXPLOSION_NUM_FRAMES EQU 5 ; Number of animation frames in the explosion animation.
DEF EXPLOSION_ANIM_SPEED EQU 4 ; Number of game frames between each frame of animation.

RSRESET
DEF EnemyCarX RB 2 ; Coordinates of the top-left of the car. 8.8 fixed point.
DEF EnemyCarY RB 2
DEF EnemyCarXSpeed RB 2 ; Speed of the car moving left and right on the screen in pixels per frame. 8.8 fixed point.
DEF EnemyCarRoadSpeed RB 2 ; Speed of the car, in terms of road scroll speed. 8.8 fixed point.
DEF EnemyCarMaxRoadSpeed RB 2 ; Max and min speeds of the car, in terms of road scroll speed. 8.8 fixed point.
DEF EnemyCarMinRoadSpeed RB 2
DEF EnemyCarAcceleration RB 2 ; Car's road scroll acceleration - pixels per frame per frame. 8.8 fixed point.
DEF ExplosionAnimTimer RB 0 ; Frame counter for the explosion animation (shares RAM with EnemyCarAnimationTimer)
DEF EnemyCarAnimationTimer RB 1 ; Incremented every frame. Used to update animations.
DEF ExplosionAnimFrame RB 0 ; Current frame of the explosion animation (shares RAM with EnemyCarAnimationState)
DEF EnemyCarAnimationState RB 1 ; Current state of the animation. 0 = state 1, FF = state 2
DEF CurrentKnockbackSpeedX RB 2 ; Speed of the current knockback effect, in pixels per frame. 8.8 fixed point.
DEF CurrentKnockbackSpeedY RB 2
DEF EnemyCarActive RB 1 ; 0 = Inactive, 1 = Active, 2 = Exploding
DEF KnockbackThisFrame RB 1 ; Was there any car knockback applied this frame? (0 or 1) Used to determine if car should explode when hitting a wall
DEF sizeof_EnemyCarVars RB 0

; Init variables that only need to be initialised once, at the game start.
; Input - \1 = Car State Offset
MACRO init_enemy_car
    ld a, $2
    ld [\1 + EnemyCarXSpeed], a
    xor a
    ld [\1 + EnemyCarXSpeed + 1], a
    xor a
    ld [\1 + EnemyCarAcceleration], a
    ld a, $05
    ld [\1 + EnemyCarAcceleration + 1], a
    xor a
    ld [\1 + EnemyCarActive], a
    ld a, $1
    ld [\1 + EnemyCarMinRoadSpeed], a
    xor a
    ld [\1 + EnemyCarMinRoadSpeed + 1], a
    ld a, $6
    ld [\1 + EnemyCarMaxRoadSpeed], a
    xor a
    ld [\1 + EnemyCarMaxRoadSpeed + 1], a
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
ENDM

; \1 = Car State Offset
; \2 = Sprite Offset
; \3 = Collision Array Offset
MACRO update_enemy_car
DEF CAR_SPRITE\@ EQUS "\2"
DEF CAR_OBJ_COLLISION\@ EQUS "\3"
    ld a, [\1 + EnemyCarActive]
    and a
    jp z, .carInactive\@
    dec a
    jp z, .carActive\@
.carExploding\@:
    ; Move sprite down as if speed is 0
    add_16 CurrentRoadScrollSpeed, \1 + EnemyCarY, \1 + EnemyCarY
    ld a, [\1 + EnemyCarY]  ; \
    cp 150                  ; | If explosion goes off screen, end it immediately to prevent wraparound
    jr nc, .explosionOver\@ ; /
    ; Update explosion animation state
    ld hl, \1 + ExplosionAnimTimer
    inc [hl]
    ld a, [hl]
    cp EXPLOSION_ANIM_SPEED
    jr nz, .noExplosionTimerOverflow\@
    xor a      ; \ reset ExplosionAnimTimer to 0
    ld [hl], a ; /
    ld hl, \1 + ExplosionAnimFrame
    inc [hl]
    ld a, [hl]
    cp EXPLOSION_NUM_FRAMES
    jr nz, .noExplosionTimerOverflow\@
    ; Explosion is over, set car to inactive and disable sprites
.explosionOver\@:
    xor a
    ld [\1 + EnemyCarActive], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 0)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 1)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 2)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 3)) + OAMA_Y], a
    jp .doneUpdateCar\@
.noExplosionTimerOverflow\@:
    ; Set explosion sprite tiles
    ld a, [\1 + ExplosionAnimFrame]
    rlca ; Shift ExplosionAnimFrame left twice = multiply by 4 to get the starting tile index
    rlca
    add EXPLOSION_TILE_OFFSET
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (\2 + 0)) + OAMA_TILEID], a
    add a, 2
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (\2 + 1)) + OAMA_TILEID], a

    ; Set attributes (no flip)
    xor a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (\2 + 0)) + OAMA_FLAGS], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (\2 + 1)) + OAMA_FLAGS], a

    ; Move the 4 explosion sprites to (EnemyCarX, EnemyCarY)
    ld a, [\1 + EnemyCarX]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 0)) + OAMA_X], a
    add 8
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 1)) + OAMA_X], a
    ld a, [\1 + EnemyCarY]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 0)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 1)) + OAMA_Y], a
    xor a ; move the 2 unused car sprites offscreen
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 2)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 3)) + OAMA_Y], a

    jp .doneUpdateCar\@

.carInactive\@:
    call genRandom
    ld bc, CAR_SPAWN_CHANCE
    cp_16r bc, hl
    jp c, .doneUpdateCar\@

    ld a, 1
    ld [\1 + EnemyCarActive], a
    call genRandom ; random check passed, now initialise the car's position
    and %01111111 ; gen number between 0 and 127
    add (160 / 2) - 64 ; add that to the X of the middle of the screen - 64, to get a possible range of 16 to 143
    ld [\1 + EnemyCarX], a
    xor a
    ld [\1 + EnemyCarX + 1], a
    ld [\1 + EnemyCarY + 1], a
    ld a, 150 ; spawn off the bottom of the screen
    ld [\1 + EnemyCarY], a

    ; car just spawned, so initialise some variables
    ld a, $2
    ld [\1 + EnemyCarRoadSpeed], a
    ld a, $CC
    ld [\1 + EnemyCarRoadSpeed + 1], a
    xor a
    ld [\1 + EnemyCarAnimationTimer], a
    ld [\1 + EnemyCarAnimationState], a
    ld [\1 + CurrentKnockbackSpeedX], a
    ld [\1 + CurrentKnockbackSpeedX + 1], a
    ld [\1 + CurrentKnockbackSpeedY], a
    ld [\1 + CurrentKnockbackSpeedY + 1], a
    ; car is now active, so just fall into the "active" section

.carActive\@:
    ; Update animation state
    ld hl, \1 + EnemyCarAnimationTimer
    inc [hl]
    ld a, [hl]
    and %00001111 ; every 16 frames
    jr nz, .noUpdateAnimation\@
    ld hl, \1 + EnemyCarAnimationState
    ld a, [hl]
    cpl
    ld [hl], a
.noUpdateAnimation\@:

    xor a
    ld [\1 + KnockbackThisFrame], a
    ; Apply knockback
    ld hl, \1 + CurrentKnockbackSpeedX
    xor a ; Check if all knockback values are 0
    or [hl] ; X byte 1
    inc hl
    or [hl] ; X byte 2
    inc hl
    or [hl] ; Y byte 1
    inc hl
    or [hl] ; Y byte 2
    jr z, .noKnockback\@
    ld a, 1
    ld [\1 + KnockbackThisFrame], a
    update_knockback \1 + EnemyCarX, \1 + EnemyCarY, \1 + CurrentKnockbackSpeedX, \1 + CurrentKnockbackSpeedY, BASE_KNOCKBACK_SLOWDOWN
    jp .skipAI\@ ; if in knockback state, car shouldn't move around
.noKnockback\@:

    ; ----- Enemy Car AI -----
    ; E register = Movement Intention
    ld e, 0
    ; Bit 0 = Want to slow down
    ; Bit 1 = Want to speed up
    ; Bit 2 = Want to turn left
    ; Bit 3 = Want to turn right
    ld hl, CurrentRoadScrollSpeed
    ld a, [hli]
    ld c, [hl]
    add PLAYER_SPEED_WINDOW
    ld b, a ; BC = CurrentRoadScrollSpeed + PLAYER_SPEED_WINDOW
    ld hl, \1 + EnemyCarRoadSpeed
    ld a, [hli]
    ld l, [hl]
    ld h, a ; HL = EnemyCarRoadSpeed
    cp_16r bc, hl ; C set if BC < HL
    jr nc, :+
    set 0, e ; Car speed is significantly higher than player's speed - so slow down
:   ld a, b
    sub PLAYER_SPEED_WINDOW * 2 ; it was CurrentRoadScrollSpeed + PLAYER_SPEED_WINDOW before, now it's RoadScroll - P_S_W
    ld b, a
    cp_16r hl, bc ; C set if HL < BC
    jr nc, :+
    set 1, e ; Car speed is significantly lower than player's speed - so speed up
:
    ; Process movement intentions
    bit 0, e ; Want to slow down
    jr z, :+
    sub_16 \1 + EnemyCarRoadSpeed, \1 + EnemyCarAcceleration, \1 + EnemyCarRoadSpeed
:   bit 1, e ; Want to speed up
    jr z, :+
    add_16 \1 + EnemyCarRoadSpeed, \1 + EnemyCarAcceleration, \1 + EnemyCarRoadSpeed
:

    ; Enforce minimum road speed
    ld hl, \1 + EnemyCarMinRoadSpeed
    ld a, [\1 + EnemyCarRoadSpeed]
    cp [hl] ; C: Set if (EnemyCarRoadSpeed < EnemyCarMinRoadSpeed)
    inc hl
    jr nc, .speedAboveMin\@
    jr nz, .speedBelowMin\@
    ld a, [\1 + EnemyCarRoadSpeed + 1]
    cp [hl]
    jr nc, .speedAboveMin\@
.speedBelowMin\@:
    ld a, [hld]
    ld [\1 + EnemyCarRoadSpeed + 1], a
    ld a, [hl]
    ld [\1 + EnemyCarRoadSpeed], a
.speedAboveMin\@:

    ; Enforce maximum road speed
    ld hl, \1 + EnemyCarMaxRoadSpeed
    ld a, [\1 + EnemyCarRoadSpeed]
    cp [hl] ; C: Set if (EnemyCarRoadSpeed < EnemyCarMaxRoadSpeed)
    inc hl
    jr c, .speedBelowMax\@
    jr nz, .speedAboveMax\@
    ld a, [\1 + EnemyCarRoadSpeed + 1]
    cp [hl]
    jr c, .speedBelowMax\@
.speedAboveMax\@:
    ld a, [hld]
    ld [\1 + EnemyCarRoadSpeed + 1], a
    ld a, [hl]
    ld [\1 + EnemyCarRoadSpeed], a
.speedBelowMax\@:

.skipAI\@

    ; Take car speed from road speed to get the Y offset
    sub_16 CurrentRoadScrollSpeed, \1 + EnemyCarRoadSpeed, Scratchpad
    ; Add Y offset to Y coordinate
    add_16 Scratchpad, \1 + EnemyCarY, \1 + EnemyCarY

    ld c, 0
    ld a, [\1 + EnemyCarAnimationState]
    and a
    jr z, .animState1\@
    ld a, 12
    add c
    ld c, a
.animState1\@:
    set_car_tiles CAR_SPRITE\@

    road_edge_collision \1 + EnemyCarX, \1 + EnemyCarY
    ld a, [\1 + KnockbackThisFrame]
    and b ; if car is in knockback state AND car hit a wall, car should explode
    jr z, .noStartExplode\@
    ld a, 2
    ld [\1 + EnemyCarActive], a ; set car state to "Exploding"
    xor a
    ld [\1 + ExplosionAnimFrame], a
    ld [\1 + ExplosionAnimTimer], a
    ld [ObjCollisionArray + CAR_OBJ_COLLISION\@], a ; Disable collision array entry
    ld bc, DESTROYED_MONEY_GIVEN
    call addMoney
    play_sound_effect FX_CarExplode ; play explode sound effect
    jp .doneUpdateCar\@
.noStartExplode\@:

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

    ld a, [\1 + EnemyCarY] ; \ no entity collision when car is offscreen
    cp 144 + 16 - 15       ; | height of screen + sprite Y offset - status bar height
    jp nc, .noCol\@        ; /
    ld a, CAR_OBJ_COLLISION\@
    call objCollisionCheck
    and a
    jp z, .noCol\@ ; collision happened - now apply knockback
    play_sound_effect FX_ShortCrash ; play crash sound effect
    rom_bank_switch BANK("PoliceCarCollision")
    process_knockback \1 + EnemyCarX, \1 + EnemyCarY, PoliceCarCollision, \1 + CurrentKnockbackSpeedX, \1 + CurrentKnockbackSpeedY
.noCol\@:

    ; Move the 6 car sprites to (EnemyCarX, EnemyCarY)
    ld a, [\1 + EnemyCarX]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 0)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 2)) + OAMA_X], a
    add 8
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 1)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 3)) + OAMA_X], a
    ld a, [\1 + EnemyCarY]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 0)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 1)) + OAMA_Y], a
    add 16
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 2)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 3)) + OAMA_Y], a
.doneUpdateCar\@:
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