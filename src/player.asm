include "hardware.inc"
include "spriteallocation.inc"
include "macros.inc"
include "collision.inc"

DEF EXPLOSION_TILE_OFFSET EQUS "((Explosion1TilesVRAM - $8000) / 16)"

DEF EXPLOSION_NUM_FRAMES EQU 5 ; Number of animation frames in the explosion animation.
DEF EXPLOSION_ANIM_SPEED EQU 4 ; Number of game frames between each frame of animation.

DEF RESPAWN_TIME EQU 120 ; Number of frames before the player respawns.
DEF RESPAWN_INVINCIBILITY_FRAMES EQU 90 ; Number of invincibility frames given after respawning.
DEF GAME_OVER_TIME EQU 150 ; Number of frames after losing last life that the game over screen is opened.

DEF PLAYER_MIN_Y EQU $4D ; Cap minimum Y ($10 is top of the screen)
DEF PLAYER_MAX_Y EQU $79 ; Cap maximum Y ($89 is bottom of the screen)
DEF KNOCKBACK_SPEED_CHANGE EQU $0090 ; How much each knockback changes the road speed by. 8.8 fixed point
DEF BASE_KNOCKBACK_SLOWDOWN EQU 30

DEF STARTING_ROAD_SPEED EQU $2CC ; Road speed when game starts or player respawns.

SECTION "PlayerVariables", WRAM0
PlayerX:: DS 2 ; Coordinates of the top-left of the player. 8.8 fixed point.
PlayerY:: DS 2
PlayerXSpeed:: DS 2 ; Speed of the player moving around on the screen in pixels per frame. 8.8 fixed point.
PlayerYSpeed:: DS 2
PlayerMaxRoadSpeed:: DS 2 ; Max and min speeds of the car, in terms of road scroll speed. 8.8 fixed point.
PlayerMinRoadSpeed:: DS 2
PlayerAcceleration:: DS 2 ; Player's road scroll acceleration - pixels per frame per frame. 8.8 fixed point.
CurrentRoadScrollSpeed:: DS 2 ; Speed of road scroll, in pixels per frame. 8.8 fixed-point.
CurrentKnockbackSpeedX: DS 2 ; Speed of the current knockback effect, in pixels per frame. 8.8 fixed point.
CurrentKnockbackSpeedY: DS 2
KnockbackThisFrame: DS 1 ; Was there any car knockback applied this frame? (0 or 1) Used to determine if car should explode when hitting a wall
MoneyAmount:: DS 2 ; Your current money value. 2 byte BCD (little endian)
SpecialChargeValue:: DS 1 ; Current special ability charge. Each bit represents a bar, so the bottom 6 bits.
MissileChargeValue:: DS 1 ; Current missile charge.
SpecialChargeSpeed: DS 1 ; Number of frames it takes for the bar to increase by 1.
MissileChargeSpeed: DS 1
SpecialChargeFrameCtr: DS 1 ; Number of frames left before bar increments.
MissileChargeFrameCtr: DS 1
LivesValue:: DS 1 ; The player's current lives. 0 to 4.
PlayerState: DS 1 ; 0 = Waiting to respawn, 1 = Active, 2 = Exploding, 3 = Waiting to game over
ExplosionAnimFrame: DS 1 ; Current frame of the explosion animation
ExplosionAnimTimer: DS 1 ; Frame counter for the explosion animation
PlayerStateTimer: DS 1 ; Used to count the time before respawning, number of invincibility frames, and time after death before game overing

SECTION "PlayerCode", ROM0

initPlayer::
    ld a, $50
    ld [PlayerX], a
    ld a, $70
    ld [PlayerY], a
    ld a, $1
    ld [PlayerXSpeed], a
    ld a, HIGH(STARTING_ROAD_SPEED)
    ld [CurrentRoadScrollSpeed], a
    ld a, LOW(STARTING_ROAD_SPEED)
    ld [CurrentRoadScrollSpeed + 1], a
    ld a, $1
    ld [PlayerMinRoadSpeed], a
    xor a
    ld [PlayerMinRoadSpeed + 1], a
    ld a, $6
    ld [PlayerMaxRoadSpeed], a
    xor a
    ld [PlayerMaxRoadSpeed + 1], a
    xor a
    ld [PlayerAcceleration], a
    ld a, $07
    ld [PlayerAcceleration + 1], a
    ld a, $55
    ld [PlayerYSpeed + 1], a
    xor a
    ld [PlayerYSpeed], a
    ld [PlayerX + 1], a
    ld [PlayerY + 1], a
    ld a, $7F
    ld [PlayerXSpeed + 1], a
    xor a
    ld [CurrentKnockbackSpeedX], a
    ld [CurrentKnockbackSpeedX + 1], a
    ld [CurrentKnockbackSpeedY], a
    ld [CurrentKnockbackSpeedY + 1], a
    ld [MoneyAmount], a
    ld [MoneyAmount + 1], a
    ld [SpecialChargeValue], a
    ld [MissileChargeValue], a
    ld [PlayerStateTimer], a
    ld a, 20
    ld [SpecialChargeSpeed], a
    ld [SpecialChargeFrameCtr], a
    ld [MissileChargeSpeed], a
    ld [MissileChargeFrameCtr], a
    ld a, 4
    ld [LivesValue], a
    ld a, 1
    ld [PlayerState], a
    ret

updatePlayer::
    ; Check state
    ld a, [PlayerState]
    and a
    jp z, .carInactive
    dec a
    jp z, .carActive
    dec a
    jr z, .carExploding
    ; Car is in time before game over (PlayerState == 3)
    ld hl, PlayerStateTimer
    dec [hl]
    jp z, setupGameOver
    ret
.carExploding:
    ; Update explosion animation state
    ld hl, ExplosionAnimTimer
    inc [hl]
    ld a, [hl]
    cp EXPLOSION_ANIM_SPEED
    jr nz, .noExplosionTimerOverflow
    xor a      ; \ reset ExplosionAnimTimer to 0
    ld [hl], a ; /
    ld hl, ExplosionAnimFrame
    inc [hl]
    ld a, [hl]
    cp EXPLOSION_NUM_FRAMES
    jr nz, .noExplosionTimerOverflow
    ; Explosion is over, set car to inactive and disable sprites
    ld a, [LivesValue]          ; \
    and a                       ; | ...unless player has no lives
    jr nz, .explodeNormally     ; | then player should go into "Time before game over" state
    ld a, 3                     ; |
    ld [PlayerState], a         ; |
    ld a, GAME_OVER_TIME        ; |
    ld [PlayerStateTimer], a    ; |
    xor a                       ; |
    jr :+                       ; /
.explodeNormally:
    xor a
    ld [PlayerState], a
:   ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 0)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 1)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 2)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 3)) + OAMA_Y], a
    ret
.noExplosionTimerOverflow:
    ; Set explosion sprite tiles
    ld a, [ExplosionAnimFrame]
    rlca ; Shift ExplosionAnimFrame left twice = multiply by 4 to get the starting tile index
    rlca
    add EXPLOSION_TILE_OFFSET
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 0)) + OAMA_TILEID], a
    add a, 2
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 1)) + OAMA_TILEID], a

    ; Set attributes (no flip)
    xor a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 0)) + OAMA_FLAGS], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 1)) + OAMA_FLAGS], a

    ; Move the 4 explosion sprites to (PlayerX, PlayerY)
    ld a, [PlayerX]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 0)) + OAMA_X], a
    add 8
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 1)) + OAMA_X], a
    ld a, [PlayerY]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 0)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 1)) + OAMA_Y], a
    xor a ; move the 2 unused car sprites offscreen
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 2)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 3)) + OAMA_Y], a

    ret

.carInactive:
    ld a, [IsGameOver]
    and a
    ret nz ; game is over, player shouldn't respawn
    ld hl, PlayerStateTimer
    dec [hl]
    ret nz ; player is still waiting to respawn
    ; player should respawn now
    ld a, RESPAWN_INVINCIBILITY_FRAMES ; give player invincibility frames after respawning
    ld [hl], a                         ;
    ld a, 1                 ; set player state to Active
    ld [PlayerState], a     ; 
    ld a, $50               ; \
    ld [PlayerX], a         ; | put player in appropriate position
    ld a, $70               ; | (middle near bottom of screen)
    ld [PlayerY], a         ; /
    xor a                                   ; \
    ld hl, CurrentKnockbackSpeedX           ; |
    ld [hli], a ;CurrentKnockbackSpeedX     ; | reset player knockback
    ld [hli], a ;CurrentKnockbackSpeedX + 1 ; |
    ld [hli], a ;CurrentKnockbackSpeedY     ; |
    ld [hl], a  ;CurrentKnockbackSpeedY + 1 ; /
    ld a, HIGH(STARTING_ROAD_SPEED)
    ld [CurrentRoadScrollSpeed], a
    ld a, LOW(STARTING_ROAD_SPEED)
    ld [CurrentRoadScrollSpeed + 1], a

.carActive:
    ; Decrement invincibility timer if necessary
    ld a, [PlayerStateTimer]
    and a
    jr z, .noInvincibility
    dec a
    ld [PlayerStateTimer], a
.noInvincibility:

    ; Handle charge bar increasing
    ld hl, MissileChargeFrameCtr ; Charge missile bar
    dec [hl]
    jr nz, .noIncreaseMissileCharge
    ld a, [MissileChargeSpeed]  ; Reset counter
    ld [hl], a                  ;
    ld hl, MissileChargeValue
    scf
    rl [hl]
.noIncreaseMissileCharge:
    ld hl, SpecialChargeFrameCtr ; Charge special bar
    dec [hl]
    jr nz, .noIncreaseSpecialCharge
    ld a, [SpecialChargeSpeed]  ; Reset counter
    ld [hl], a                  ;
    ld hl, SpecialChargeValue
    scf
    rl [hl]
.noIncreaseSpecialCharge:

    xor a
    ld [KnockbackThisFrame], a
    ; Apply knockback
    ld hl, CurrentKnockbackSpeedX
    xor a ; Check if all knockback values are 0
    or [hl] ; X byte 1
    inc hl
    or [hl] ; X byte 2
    inc hl
    or [hl] ; Y byte 1
    inc hl
    or [hl] ; Y byte 2
    jr z, .noKnockback
    ld a, 1
    ld [KnockbackThisFrame], a
    update_knockback PlayerX, PlayerY, CurrentKnockbackSpeedX, CurrentKnockbackSpeedY, BASE_KNOCKBACK_SLOWDOWN
    ld c, 0 ; movement state = straight
    jp .controlsDisabled
.noKnockback:
    ld c, 0 ; C holds the movement state: 0 = not turning, -1 = turning left, 1 = turning right

    ld a, [curButtons]
    ld b, a ; save curButtons into b
    and PADF_UP
    jr z, .upNotPressed
    ; Subtract PlayerYSpeed from Player Y
    sub_16 PlayerY, PlayerYSpeed, PlayerY
    add_16 CurrentRoadScrollSpeed, PlayerAcceleration, CurrentRoadScrollSpeed
.upNotPressed:

    ld a, b
    and PADF_DOWN
    jr z, .downNotPressed
    ; Add PlayerYSpeed to Player Y
    add_16 PlayerY, PlayerYSpeed, PlayerY
    sub_16 CurrentRoadScrollSpeed, PlayerAcceleration, CurrentRoadScrollSpeed
.downNotPressed:

    ld a, b
    and PADF_LEFT
    jr z, .leftNotPressed
    dec c ; movement state = turning left
    ; Subtract PlayerXSpeed from Player X
    sub_16 PlayerX, PlayerXSpeed, PlayerX
.leftNotPressed:

    ld a, b
    and PADF_RIGHT
    jr z, .rightNotPressed
    inc c ; movement state = turning right
    ; Add PlayerXSpeed to Player X
    add_16 PlayerX, PlayerXSpeed, PlayerX
.rightNotPressed:
.controlsDisabled:

    ; Enforce minimum road speed
    cp_16 PlayerMinRoadSpeed, CurrentRoadScrollSpeed
    jr c, .speedAboveMin
    ld a, [PlayerMinRoadSpeed]
    ld [hli], a ; HL = CurrentRoadScrollSpeed from cp_16
    ld a, [PlayerMinRoadSpeed + 1]
    ld [hl], a
.speedAboveMin:

    ; Enforce maximum road speed (comment this out to engage hyperspeed!)
    cp_16 PlayerMaxRoadSpeed, CurrentRoadScrollSpeed
    jr nc, .speedBelowMax
    ld a, [PlayerMaxRoadSpeed]
    ld [hli], a ; HL = CurrentRoadScrollSpeed from cp_16
    ld a, [PlayerMaxRoadSpeed + 1]
    ld [hl], a
.speedBelowMax:

    ld a, c
    and a ; get flags
    jr z, .ForwardSprite
    cp -1
    jr z, .LeftSprite
    ld c, 8 ; right sprite
    call setPlayerTiles
    jr .DoneSetSprite
.LeftSprite:
    ld c, 4
    call setPlayerTiles
    jr .DoneSetSprite
.ForwardSprite:
    ld c, 0
    call setPlayerTiles
.DoneSetSprite:

    ld a, [PlayerY]
    cp PLAYER_MIN_Y ; Cap minimum Y
    jr nc, .aboveMinY
    ld a, PLAYER_MIN_Y
    ld [PlayerY], a
.aboveMinY:

    ld a, [PlayerY]
    cp PLAYER_MAX_Y ; Cap maximum Y
    jr c, .belowMaxY
    ld a, PLAYER_MAX_Y
    ld [PlayerY], a
.belowMaxY:

    ld a, [PlayerY]         ; \
    ld b, a                 ; | setup inputs for roadEdgeCollision
    ld de, PlayerX          ; /
    call roadEdgeCollision
    ld a, [KnockbackThisFrame]
    and b ; if car is in knockback state AND car hit a wall, car should explode
    jr z, .noStartExplode
    ld a, [PlayerStateTimer]    ; \
    and a                       ; | UNLESS player is currently invincible
    jr nz, .noStartExplode      ; /
.explodePlayer:
    ld a, 2
    ld [PlayerState], a ; set car state to "Exploding"
    xor a
    ld [ExplosionAnimFrame], a
    ld [ExplosionAnimTimer], a
    ld [ObjCollisionArray + PLAYER_COLLISION], a ; Disable collision array entry
    ld [CurrentRoadScrollSpeed], a      ; Set speed to 0
    ld [CurrentRoadScrollSpeed + 1], a  ;
    play_sound_effect FX_CarExplode     ; play explode sound effect
    ld a, RESPAWN_TIME                  ; Setup respawn timer
    ld [PlayerStateTimer], a            ;
    ld hl, LivesValue                   ; decrement lives
    dec [hl]                            ;
    ret
.noStartExplode:

    ; Update entry in object collision array
    ld hl, ObjCollisionArray + PLAYER_COLLISION
    ld a, %00000011 ; Collision Layer Flags
    ld [hli], a
    ld a, [PlayerY] ; Top Y
    ld [hli], a
    add 24 ; Bottom Y - player is 24 px tall
    ld [hli], a
    ld a, [PlayerX] ; Left X
    ld [hli], a
    add 16 ; Right X - player is 16 px wide
    ld [hli], a
    ld a, [CurrentRoadScrollSpeed]
    set 4, a ; car type = player
    ld [hl], a ; movement info

    ld a, PLAYER_COLLISION
    call objCollisionCheck
    and a
    jp z, .noCol ; collision happened - now apply knockback
    bit 1, b ; check if collision was with enemy missile or car
    jr z, .doKnockback
    ld a, [PlayerStateTimer]    ; \
    and a                       ; | don't explode if currently invincible
    jp nz, .noCol               ; /
    jr .explodePlayer
.doKnockback:
    rom_bank_switch BANK("PoliceCarCollision")
    process_knockback PlayerX, PlayerY, PoliceCarCollision, CurrentKnockbackSpeedX, CurrentKnockbackSpeedY
    ld a, [CurrentKnockbackSpeedY] ; change car speed based on KnockbackY
    bit 7, a
    jr nz, .doneApplyKnockback
    ;jr z, .knockYPositive
    ; knock was negative = car is moving upwards = speed up
    ;ld hl, CurrentRoadScrollSpeed ; \
    ;ld a, [hli]                   ; | load 16 bit value in CurrentRoadScrollSpeed into HL
    ;ld l, [hl]                    ; |
    ;ld h, a                       ; /
    ;ld bc, KNOCKBACK_SPEED_CHANGE
    ;add hl, bc
    ;ld a, h
    ;ld [CurrentRoadScrollSpeed], a
    ;ld a, l
    ;ld [CurrentRoadScrollSpeed + 1], a
    ;jr .doneApplyKnockback
.knockYPositive: ; knock was positive = car is moving down = slow down
    ld hl, CurrentRoadScrollSpeed ; \
    ld a, [hli]                   ; | load 16 bit value in CurrentRoadScrollSpeed into HL
    ld l, [hl]                    ; |
    ld h, a                       ; /
    ld bc, -KNOCKBACK_SPEED_CHANGE
    add hl, bc
    ld a, h
    ld [CurrentRoadScrollSpeed], a
    ld a, l
    ld [CurrentRoadScrollSpeed + 1], a
.doneApplyKnockback:
.noCol:

    ; Flash the car every other frame if currently invincible
    ld a, [PlayerStateTimer]
    and 1 ; determine if time number is even or odd
    ld a, [PlayerY]
    jr z, .notInvisible ; if even, draw car as normal
    ld a, 200 ; if odd, put player Y off the screen so car is invisible
.notInvisible:

    ; Move the 6 player car sprites to (PlayerX, A)
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 0)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 1)) + OAMA_Y], a
    add 16
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 2)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 3)) + OAMA_Y], a
    ld a, [PlayerX]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 0)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 2)) + OAMA_X], a
    add 8
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 1)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 3)) + OAMA_X], a

    ; Handle A or B inputs activating missile / special
    ld a, [newButtons]
    and PADF_A
    jr z, .aNotPressed
    ld hl, MissileChargeValue   ; \
    bit 5, [hl]                 ; | only fire if bar is fully charged
    jr z, .aNotPressed          ; /
    xor a                       ; reset bar to empty
    ld [hl], a                  ;
    call firePlayerMissile
    play_sound_effect FX_PlayerMissile
.aNotPressed:

    ld a, [newButtons]
    and PADF_B
    jr z, .bNotPressed
    ; todo : special
.bNotPressed:

    ret

; Set the player tiles and attributes from PlayerTilemap and PlayerAttrmap
; Input - C = Offset into tilemap (number of tiles)
; Sets - A to garbage
; Sets - B to 0
setPlayerTiles:
    ld b, 0
    rom_bank_switch BANK("PlayerTilemap")
    ld hl, PlayerTilemap ; Set player tiles
    add hl, bc
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 0)) + OAMA_TILEID], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 1)) + OAMA_TILEID], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 2)) + OAMA_TILEID], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 3)) + OAMA_TILEID], a

    rom_bank_switch BANK("PlayerAttrmap")
    ld hl, PlayerAttrmap ; Set player sprite attributes
    add hl, bc
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 0)) + OAMA_FLAGS], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 1)) + OAMA_FLAGS], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 2)) + OAMA_FLAGS], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 3)) + OAMA_FLAGS], a
    ret

; Give the player some money
; Could turn this into a generic "4 digit BCD add", if needed?
; Input - BC = 4 digit BCD amount of money to add
; Sets - A H L to garbage
addMoney::
    ; Lower 2 digits
    ld hl, MoneyAmount
    ld a, [hl]
    add c
    daa
    ld [hli], a
    ; Upper 2 digits
    ld a, [hl]
    adc b
    daa
    ld [hl], a
    ret nc
    ; Money has overflowed past 9999, so just cap it at 9999
    ld a, $99
    ld [hld], a
    ld [hl], a
    ret

; player just ran out of lives, time to setup game over stuff
setupGameOver:
    ld a, 1
    ld [IsGameOver], a
    call startMenuBarAnim ; open game over menu (A is still 1 = game over screen)
    ret