include "hardware.inc"
include "spriteallocation.inc"
include "macros.inc"
include "collision.inc"

DEF EXPLOSION_TILE_OFFSET EQUS "((Explosion1TilesVRAM - $8000) / 16)"

DEF DESTROYED_MONEY_GIVEN EQU $0020 ; Money given to the player when the enemy is destroyed. 16 bit BCD

DEF Y_BORDER_POS EQU 207 ; The maximum and minimum Y position, which roughly makes the area off the top and off the bottom equal

DEF EXPLOSION_NUM_FRAMES EQU 5 ; Number of animation frames in the explosion animation.
DEF EXPLOSION_ANIM_SPEED EQU 4 ; Number of game frames between each frame of animation.

; Car tries to have a speed within:
; CurrentRoadScrollSpeed - PLAYER_SPEED_WINDOW and CurrentRoadScrollSpeed + PLAYER_SPEED_WINDOW. 8 bit integer.
DEF PLAYER_SPEED_WINDOW EQU 2
DEF IDLE_PLAYER_Y_WINDOW_IN EQU 55 ; In Idle state, the enemy will stay this far away from the player on the Y axis. 8 bit integer.
DEF IDLE_PLAYER_Y_WINDOW_OUT EQU 65

DEF ATTACK_CHANCE EQU 40 ; Chance the enemy will start attacking if there's no other car attacking. Out of 255.

RSRESET
DEF EnemyCarX RB 2 ; Coordinates of the top-left of the car. 8.8 fixed point.
DEF EnemyCarY RB 2
DEF PrevFrameCarY RB 1 ; High byte of the car's Y last frame. Used to determine if the car has crossed a min/max boundary
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
DEF ObjectLastTouched RB 1 ; Which thing touched the car last? (0 = other enemy car, 1 = player)
DEF EnemyCarActive RB 1 ; 0 = Inactive, 1 = Active, 2 = Exploding
DEF KnockbackThisFrame RB 1 ; Was there any car knockback applied this frame? (0 or 1) Used to determine if car should explode when hitting a wall
DEF PlayerKnockbackSlowdown RB 1 ; How fast the car slows down after being hit by the player, in 255s of a pixel per frame per frame. (0.8 fixed)
DEF OtherKnockbackSlowdown RB 1 ; How fast the car slows down after being hit by some other object. (0.8 fixed)

DEF LastMovementIntention RB 1 ; AI movement intention on the last frame
DEF AIFrameCtr RB 1
DEF AIState RB 1 ; 0 = Idle, 1 = Attacking
DEF sizeof_EnemyCarVars RB 0

; Init variables that only need to be initialised once, at the game start.
; Input - \1 = Car State Offset
; Input - \2 = Sprite Offset
MACRO init_enemy_car
    ld a, $1
    ld [\1 + EnemyCarXSpeed], a
    ld a, $20
    ld [\1 + EnemyCarXSpeed + 1], a
    xor a
    ld [\1 + EnemyCarAcceleration], a
    ld a, $0F
    ld [\1 + EnemyCarAcceleration + 1], a
    xor a
    ld [\1 + EnemyCarActive], a
    ld [\1 + EnemyCarMinRoadSpeed], a
    ld a, $BB
    ld [\1 + EnemyCarMinRoadSpeed + 1], a
    ld a, $7
    ld [\1 + EnemyCarMaxRoadSpeed], a
    xor a
    ld [\1 + EnemyCarMaxRoadSpeed + 1], a
    ld a, 10
    ld [\1 + PlayerKnockbackSlowdown], a
    ld a, 40
    ld [\1 + OtherKnockbackSlowdown], a
    xor a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (\2 + 0)) + OAMA_Y], a ; make sure car is offscreen
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (\2 + 1)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (\2 + 2)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (\2 + 3)) + OAMA_Y], a

    ld [\1 + AIFrameCtr], a
    ld [\1 + LastMovementIntention], a
    ld [\1 + AIState], a
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
    ; Car is exploding (EnemyCarActive == 2)
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
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 0)) + OAMA_TILEID], a
    add a, 2
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 1)) + OAMA_TILEID], a

    ; Set attributes (no flip)
    xor a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 0)) + OAMA_FLAGS], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (CAR_SPRITE\@ + 1)) + OAMA_FLAGS], a

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
    ld a, [EnemyCarSpawnChance]
    sub l
    ld a, [EnemyCarSpawnChance + 1]
    sbc h
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
    ld [\1 + PrevFrameCarY], a

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
    ld a, [\1 + EnemyCarY]
    ld [\1 + PrevFrameCarY], a

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
    jp z, .noKnockback\@
    ld a, 1
    ld [\1 + KnockbackThisFrame], a
    update_knockback \1 + EnemyCarX, \1 + EnemyCarY, \1 + CurrentKnockbackSpeedX, \1 + CurrentKnockbackSpeedY, \1 + OtherKnockbackSlowdown, \1 + PlayerKnockbackSlowdown, \1 + ObjectLastTouched
    ld c, 0 ; set sprite to straight one
    jp .skipAI\@ ; if in knockback state, car shouldn't move around
.noKnockback\@:

    ; ----- Enemy Car AI -----
    ; E register = Movement Intention
    ld e, 0
    ; Bit 0 = Want to slow down
    ; Bit 1 = Want to speed up
    ; Bit 2 = Want to turn left
    ; Bit 3 = Want to turn right

    ; jeez, this AI part sure is a mess
    ; need to reorganise this at some point

    ; X AI is same regardless of attacking or idle
    ld hl, \1 + AIFrameCtr
    inc [hl]
    ld a, %00001111 ; run X AI once every 16 frames
    and [hl]
    jr z, .doXAI\@
    ld a, [\1 + LastMovementIntention]
    and %1100
    ld e, a
    jp .doneProcessXMovement\@
.doXAI\@:
    ; --- X Movement ---
    call genRandom
    cp 100
    jr c, .randomXState\@
    cp 200
    jr c, .keepCurrentXIntention\@

    ld hl, PlayerX
    ld a, [\1 + EnemyCarX]
    cp [hl] ; c set if EnemyX < PlayerX
    jr z, .doneWantChangeX\@
    jr c, .wantMoveRight\@
    set 2, e
    jr .doneWantChangeX\@
.wantMoveRight\@:
    set 3, e
.doneWantChangeX\@:
    jr .doneProcessXMovement\@

.keepCurrentXIntention\@
    ld a, [\1 + LastMovementIntention]
    and %1100
    ld e, a
    jr .doneProcessXMovement\@

.randomXState\@:
    ld a, h
    and %1100
    cp %1100 ; can't move both right and left at the same time
    jr nz, :+
    xor a
:   ld e, a

.doneProcessXMovement\@:

    ld a, [\1 + AIState]
    and a
    jr z, .aiIdle\@
    
    ; --- Attacking AI ---
    ld hl, PlayerY ; Try to match player's Y position
    ld a, [\1 + EnemyCarY]
    cp Y_BORDER_POS         ; offscreen in the above-screen zone = slow down
    jr nc, .wantSlowDown\@  ;
    cp [hl] ; c set if EnemyY < PlayerY (enemy is higher on the screen)
    jr z, .doneWantChangeSpeed\@
    jr c, .wantSlowDown\@
    set 1, e
    jr .doneWantChangeSpeed\@
.wantSlowDown\@:
    set 0, e
.doneWantChangeSpeed\@:

    jp .doneProcessAI\@
.aiIdle\@:  ; --- Idle AI ---
    ld a, [IsCarAttacking]  ; \
    and a                   ; | don't attack if there's already a car doing that
    jr nz, .noAttack\@      ; /
    call genRandom          ;
    cp ATTACK_CHANCE        ;
    jr nc, .noAttack\@      ; check if we should start attacking or not
    ld a, 1                 ;
    ld [\1 + AIState], a    ;
    ld [IsCarAttacking], a  ;
.noAttack\@:

    ; First, see if we need to try and match player's speed
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
    jr .doneProcessYMovement\@
:   ld a, b
    sub PLAYER_SPEED_WINDOW * 2 ; it was CurrentRoadScrollSpeed + PLAYER_SPEED_WINDOW before, now it's RoadScroll - P_S_W
    ld b, a
    cp_16r hl, bc ; C set if HL < BC
    jr nc, :+
    set 1, e ; Car speed is significantly lower than player's speed - so speed up
    jr .doneProcessYMovement\@
:

    ld hl, PlayerY
    ld a, [\1 + EnemyCarY]
    cp Y_BORDER_POS             ; offscreen in the above-screen zone = above player
    jr nc, .idleMoveDown\@      ;
    cp [hl] ; c set if EnemyY < PlayerY (enemy is higher on the screen)
    jr c, .idleYAbovePlayer\@
    sub IDLE_PLAYER_Y_WINDOW_IN ; EnemyY > PlayerY (enemy is below player)
    cp [hl] ; c set if EnemyY - IDLE_PLAYER_Y_WINDOW_IN < PlayerY
    jr c, .idleMoveDown\@
    sub (IDLE_PLAYER_Y_WINDOW_OUT - IDLE_PLAYER_Y_WINDOW_IN)
    cp [hl] ; c set if EnemyY - IDLE_PLAYER_Y_WINDOW_OUT < PlayerY
    jr nc, .idleMoveUp\@
    jr .idleMatchPlayerSpeed\@
.idleYAbovePlayer\@:
    ld a, [\1 + EnemyCarY]
    add IDLE_PLAYER_Y_WINDOW_OUT
    cp [hl] ; c set if EnemyY + IDLE_PLAYER_Y_WINDOW_OUT < PlayerY
    jr c, .idleMoveDown\@
    sub (IDLE_PLAYER_Y_WINDOW_OUT - IDLE_PLAYER_Y_WINDOW_IN)
    cp [hl] ; c set if EnemyY + IDLE_PLAYER_Y_WINDOW_IN < PlayerY
    jr nc, .idleMoveUp\@
.idleMatchPlayerSpeed\@: ; We're in an appropriate "window" from the player, now hold that position by matching player speed
    cp_16 CurrentRoadScrollSpeed, \1 + EnemyCarRoadSpeed ; c set if CurrentRoadScrollSpeed < EnemyCarRoadSpeed (enemy is faster)
    jr c, .idleMoveDown\@
    ;jr .idleMoveUp\@

.idleMoveUp\@:
    set 1, e
    jr .doneCheckIdleY\@
.idleMoveDown\@:
    set 0, e
.doneCheckIdleY\@:
.doneProcessYMovement\@:
.doneProcessAI\@:

    ; Process movement intentions
    ld c, 0 ; Determines which sprite is used. 0 = straight, 4 = turning left, 8 = turning right
    bit 0, e ; Want to slow down
    jr z, :+
    sub_16 \1 + EnemyCarRoadSpeed, \1 + EnemyCarAcceleration, \1 + EnemyCarRoadSpeed
:   bit 1, e ; Want to speed up
    jr z, :+
    add_16 \1 + EnemyCarRoadSpeed, \1 + EnemyCarAcceleration, \1 + EnemyCarRoadSpeed
:   bit 2, e ; Want to turn left
    jr z, :+
    ld c, 4
    sub_16 \1 + EnemyCarX, \1 + EnemyCarXSpeed, \1 + EnemyCarX
:   bit 3, e ; Want to turn right
    jr z, :+
    ld c, 8
    add_16 \1 + EnemyCarX, \1 + EnemyCarXSpeed, \1 + EnemyCarX
:

    ld a, e
    ld [\1 + LastMovementIntention], a

    ; Enforce minimum road speed
    cp_16 \1 + EnemyCarMinRoadSpeed, \1 + EnemyCarRoadSpeed
    jr c, .speedAboveMin\@
    ld a, [\1 + EnemyCarMinRoadSpeed]
    ld [hli], a ; HL = EnemyCarRoadSpeed from cp_16
    ld a, [\1 + EnemyCarMinRoadSpeed + 1]
    ld [hl], a
.speedAboveMin\@:

    ; Enforce maximum road speed
    cp_16 \1 + EnemyCarMaxRoadSpeed, \1 + EnemyCarRoadSpeed
    jr nc, .speedBelowMax\@
    ld a, [\1 + EnemyCarMaxRoadSpeed]
    ld [hli], a ; HL = EnemyCarRoadSpeed from cp_16
    ld a, [\1 + EnemyCarMaxRoadSpeed + 1]
    ld [hl], a
.speedBelowMax\@:

.skipAI\@:

    ; Take car speed from road speed to get the Y offset
    sub_16 CurrentRoadScrollSpeed, \1 + EnemyCarRoadSpeed, Scratchpad
    ; Add Y offset to Y coordinate
    add_16 Scratchpad, \1 + EnemyCarY, \1 + EnemyCarY

    ; Enforce minimum and maximum Y coordinates
    ld a, [\1 + PrevFrameCarY]  ; \
    sub Y_BORDER_POS            ; | setup previous frame Y into B
    ld b, a                     ; /
    ld a, [\1 + EnemyCarY]
    sub Y_BORDER_POS ; Subtracting Y Border means we can use the sign to determine which "side" of the border we're on
    call difference         ; if the 2 numbers differ by a lot, then we wrapped around the border
    cp 64                   ; if they don't differ by much, then they must have crossed from 127 to 128
    jr c, .noEnforceYPos\@
    ld a, b                 ; Change Y pos to what it was before
    add Y_BORDER_POS        ;
    ld [\1 + EnemyCarY], a  ;
.noEnforceYPos\@:
    
    ; C is set earlier - determines straight / turning sprite
    ld a, [\1 + EnemyCarAnimationState]
    and a
    jr z, .animState1\@
    ld a, 12
    add c
    ld c, a
.animState1\@:
    set_car_tiles CAR_SPRITE\@

    ; Update entry in object collision array
    ld hl, ObjCollisionArray + CAR_OBJ_COLLISION\@
    ld a, %00010001 ; Collision Layer Flags
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
    jp z, .noCol\@ ; collision happened
    ld a, e
    and $F0
    cp 2 << 4 ; check if collision was with road object
    jp z, .checkExplode\@
    ld a, [\1 + EnemyCarY]      ; \ no crash sounds when car is offscreen
    cp 144 + 16 - 15            ; | height of screen + sprite Y offset - status bar height
    jp nc, :+                   ; /
    play_sound_effect FX_ShortCrash ; play crash sound effect
:   rom_bank_switch BANK("PoliceCarCollision")
    process_knockback \1 + EnemyCarX, \1 + EnemyCarY, PoliceCarCollision, \1 + CurrentKnockbackSpeedX, \1 + CurrentKnockbackSpeedY, \1 + ObjectLastTouched
.noCol\@:

    ld a, [\1 + EnemyCarY]  ; \
    ld b, a                 ; | setup inputs for roadEdgeCollision
    ld de, \1 + EnemyCarX   ; /
    call roadEdgeCollision
    ld a, [\1 + KnockbackThisFrame]
    and b ; if car is in knockback state AND car hit a wall, car should explode
    jr z, .noStartExplode\@
.checkExplode\@:
    ld a, [\1 + EnemyCarY]      ; \ no exploding when car is offscreen
    cp 144 + 16 - 15            ; | height of screen + sprite Y offset - status bar height
    jp nc, .noStartExplode\@    ; /
    ld a, 2
    ld [\1 + EnemyCarActive], a ; set car state to "Exploding"
    xor a
    ld [\1 + ExplosionAnimFrame], a
    ld [\1 + ExplosionAnimTimer], a
    ld [ObjCollisionArray + CAR_OBJ_COLLISION\@], a ; Disable collision array entry
    ld bc, DESTROYED_MONEY_GIVEN
    call addMoney
    ld a, [\1 + AIState]    ; \
    and a                   ; |
    jr z, :+                ; | reset IsCarAttacking if the attacking car is being exploded
    xor a                   ; |
    ld [IsCarAttacking], a  ; /
:   play_sound_effect FX_CarExplode ; play explode sound effect
    jp .doneUpdateCar\@
.noStartExplode\@:

    ; Move the 4 car sprites to (EnemyCarX, EnemyCarY)
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

SECTION "SharedEnemyCarVars", WRAM0
EnemyCarSpawnChance:: DS 2 ; little endian
IsCarAttacking: DS 1

SECTION "EnemyCarCode", ROM0

initEnemyCars::
    xor a
    ld [IsCarAttacking], a
    init_enemy_car EnemyCarState1, ENEMYCAR_SPRITE_1
    init_enemy_car EnemyCarState2, ENEMYCAR_SPRITE_2
    init_enemy_car EnemyCarState3, ENEMYCAR_SPRITE_3
    ret

updateEnemyCars::
    update_enemy_car EnemyCarState1, ENEMYCAR_SPRITE_1, ENEMYCAR_COLLISION_1
    update_enemy_car EnemyCarState2, ENEMYCAR_SPRITE_2, ENEMYCAR_COLLISION_2
    update_enemy_car EnemyCarState3, ENEMYCAR_SPRITE_3, ENEMYCAR_COLLISION_3
    ret