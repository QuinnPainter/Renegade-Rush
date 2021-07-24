include "hardware.inc/hardware.inc"
include "spriteallocation.inc"
include "macros.inc"
include "collision.inc"

PLAYER_MIN_Y EQU $50 ; Cap minimum Y to $50 ($10 is top of the screen)
PLAYER_MAX_Y EQU $80 ; Cap maximum Y to $80 ($89 is bottom of the screen)
BASE_KNOCKBACK_FRAMES EQU 5
KNOCKBACK_SPEED_CHANGE EQU $00D0 ; How much each knockback changes the road speed by. 8.8 fixed point

SECTION "PlayerVariables", WRAM0
PlayerX:: DS 2 ; Coordinates of the top-left of the player. 8.8 fixed point.
PlayerY:: DS 2
PlayerXSpeed:: DS 2 ; Speed of the player moving around on the screen in pixels per frame. 8.8 fixed point.
PlayerYSpeed:: DS 2
PlayerMaxRoadSpeed:: DS 2 ; Max and min speeds of the car, in terms of road scroll speed. 8.8 fixed point.
PlayerMinRoadSpeed:: DS 2
PlayerAcceleration:: DS 2 ; Player's road scroll acceleration - pixels per frame per frame. 8.8 fixed point.
CurrentRoadScrollSpeed:: DS 2 ; Speed of road scroll, in pixels per frame. 8.8 fixed-point.
RemainingKnockbackFrames: DS 1 ; Number of frames left in the knockback animation.
CurrentKnockbackSpeedX: DS 2 ; Speed of the current knockback effect, in pixels per frame. 8.8 fixed point.
CurrentKnockbackSpeedY: DS 2

SECTION "PlayerCode", ROM0

initPlayer::
    ld a, $50
    ld [PlayerX], a
    ld a, $70
    ld [PlayerY], a
    ld a, $1
    ld [PlayerXSpeed], a
    ld a, $2
    ld [CurrentRoadScrollSpeed], a
    ld a, $CC
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
    ld a, $05
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
    ld [RemainingKnockbackFrames], a
    ld [CurrentKnockbackSpeedX], a
    ld [CurrentKnockbackSpeedX + 1], a
    ld [CurrentKnockbackSpeedY], a
    ld [CurrentKnockbackSpeedY + 1], a
    jp EntryPoint.doneInitPlayer

updatePlayer::
    ld c, 0 ; C holds the movement state: 0 = not turning, -1 = turning left, 1 = turning right
    ld a, [CurrentRoadScrollSpeed]
    ld d, a ; D is the movement state used in collision detection

    ld a, [RemainingKnockbackFrames]
    and a
    jr z, .noKnockback
    dec a
    ld [RemainingKnockbackFrames], a
    add_16 CurrentKnockbackSpeedX, PlayerX, PlayerX
    add_16 CurrentKnockbackSpeedY, PlayerY, PlayerY
    jp .controlsDisabled
.noKnockback:

    ld a, [curButtons]
    ld b, a ; save curButtons into b
    and PADF_UP
    jr z, .upNotPressed
    set 5, d ; set moving down bit
    ; Subtract PlayerYSpeed from Player Y
    sub_16 PlayerY, PlayerYSpeed, PlayerY
    add_16 CurrentRoadScrollSpeed, PlayerAcceleration, CurrentRoadScrollSpeed
.upNotPressed:

    ld a, b
    and PADF_DOWN
    jr z, .downNotPressed
    set 4, d ; set moving up bit
    ; Add PlayerYSpeed to Player Y
    add_16 PlayerY, PlayerYSpeed, PlayerY
    sub_16 CurrentRoadScrollSpeed, PlayerAcceleration, CurrentRoadScrollSpeed
.downNotPressed:

    ld a, b
    and PADF_LEFT
    jr z, .leftNotPressed
    set 7, d ; set moving left bit
    dec c ; movement state = turning left
    ; Subtract PlayerXSpeed from Player X
    sub_16 PlayerX, PlayerXSpeed, PlayerX
.leftNotPressed:

    ld a, b
    and PADF_RIGHT
    jr z, .rightNotPressed
    set 6, d ; set moving right bit
    inc c ; movement state = turning right
    ; Add PlayerXSpeed to Player X
    add_16 PlayerX, PlayerXSpeed, PlayerX
.rightNotPressed:
.controlsDisabled:

    ; Enforce minimum road speed
    ld a, [PlayerMinRoadSpeed]
    ld b, a
    ld a, [CurrentRoadScrollSpeed]
    cp b ; C: Set if (CurrentRoadScrollSpeed < PlayerMinRoadSpeed)
    jr nc, .scrollSpeedAboveMin
    jr nz, .scrollSpeedBelowMin
    ld a, [PlayerMinRoadSpeed + 1]
    ld b, a
    ld a, [CurrentRoadScrollSpeed + 1]
    cp b
    jr nc, .scrollSpeedAboveMin
.scrollSpeedBelowMin:
    ld a, [PlayerMinRoadSpeed]
    ld [CurrentRoadScrollSpeed], a
    ld a, [PlayerMinRoadSpeed + 1]
    ld [CurrentRoadScrollSpeed + 1], a
.scrollSpeedAboveMin:

    ; Enforce maximum road speed (comment this out to engage hyperspeed!)
    ld a, [PlayerMaxRoadSpeed]
    ld b, a
    ld a, [CurrentRoadScrollSpeed]
    cp b ; C: Set if (CurrentRoadScrollSpeed < PlayerMaxRoadSpeed)
    jr c, .scrollSpeedBelowMax
    jr nz, .scrollSpeedAboveMax
    ld a, [PlayerMaxRoadSpeed + 1]
    ld b, a
    ld a, [CurrentRoadScrollSpeed + 1]
    cp b
    jr c, .scrollSpeedBelowMax
.scrollSpeedAboveMax:
    ld a, [PlayerMaxRoadSpeed]
    ld [CurrentRoadScrollSpeed], a
    ld a, [PlayerMaxRoadSpeed + 1]
    ld [CurrentRoadScrollSpeed + 1], a
.scrollSpeedBelowMax:

    ld a, c
    and a ; get flags
    jr z, .ForwardSprite
    cp -1
    jr z, .LeftSprite
    ld c, 12 ; right sprite
    call setPlayerTiles
    jr .DoneSetSprite
.LeftSprite:
    ld c, 6
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

    ;road_edge_collision PlayerX, PlayerY

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
    ld [hl], d ; movement info

    ld a, PLAYER_COLLISION
    call objCollisionCheck
    and a
    jp z, .noCol ; collision happened - now apply knockback
    rom_bank_switch BANK("PoliceCarCollision")
    process_knockback BASE_KNOCKBACK_FRAMES, RemainingKnockbackFrames, PlayerX, PlayerY, PoliceCarCollision, CurrentKnockbackSpeedX, CurrentKnockbackSpeedY
    ld a, [CurrentKnockbackSpeedY] ; change car speed based on KnockbackY
    bit 7, a
    jr z, .knockYPositive
    ; knock was negative = car is moving upwards = speed up
    ld hl, CurrentRoadScrollSpeed ; \
    ld a, [hli]                   ; | load 16 bit value in CurrentRoadScrollSpeed into HL
    ld l, [hl]                    ; |
    ld h, a                       ; /
    ld bc, KNOCKBACK_SPEED_CHANGE
    add hl, bc
    ld a, h
    ld [CurrentRoadScrollSpeed], a
    ld a, l
    ld [CurrentRoadScrollSpeed + 1], a
    jr .doneApplyKnockback
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

    ; Move the 6 player car sprites to (PlayerX, PlayerY)
    ld a, [PlayerX]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 0)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 2)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 4)) + OAMA_X], a
    add 8
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 1)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 3)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 5)) + OAMA_X], a
    ld a, [PlayerY]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 0)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 1)) + OAMA_Y], a
    add 8
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 2)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 3)) + OAMA_Y], a
    add 8
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 4)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 5)) + OAMA_Y], a

    jp GameLoop.doneUpdatePlayer

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
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 4)) + OAMA_TILEID], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 5)) + OAMA_TILEID], a

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
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 4)) + OAMA_FLAGS], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 5)) + OAMA_FLAGS], a
    ret