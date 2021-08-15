include "hardware.inc/hardware.inc"
include "spriteallocation.inc"
include "macros.inc"
include "collision.inc"

DEF PLAYER_MIN_Y EQU $4D ; Cap minimum Y ($10 is top of the screen)
DEF PLAYER_MAX_Y EQU $79 ; Cap maximum Y ($89 is bottom of the screen)
DEF KNOCKBACK_SPEED_CHANGE EQU $0090 ; How much each knockback changes the road speed by. 8.8 fixed point
DEF BASE_KNOCKBACK_SLOWDOWN EQU 30

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
MoneyAmount:: DS 2 ; Your current money value. 2 byte BCD (little endian)
SpecialChargeValue:: DS 1 ; Current special ability charge. Each bit represents a bar, so the bottom 6 bits.
MissileChargeValue:: DS 1 ; Current missile charge.
LivesValue:: DS 1 ; The player's current lives. 0 to 4.

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
    ld a, 4
    ld [LivesValue], a
    ret

updatePlayer::
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

    ld a, [newButtons] ; TEMP - for testing charge bars
    and PADF_A
    jr z, .asd
    ;ld a, [LivesValue]
    ;dec a
    ;ld [LivesValue], a
    ld hl, MissileChargeValue
    ld a, [hl]
    scf
    rla
    ld [hl], a
.asd:

    ld a, [newButtons]
    and PADF_B
    jr z, .ads
    ld hl, SpecialChargeValue
    ld a, [hl]
    scf
    rla
    ld [hl], a
.ads:

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

    road_edge_collision PlayerX, PlayerY

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
    ld [hl], a ; movement info

    ld a, PLAYER_COLLISION
    call objCollisionCheck
    and a
    jp z, .noCol ; collision happened - now apply knockback
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

    ; Move the 6 player car sprites to (PlayerX, PlayerY)
    ld a, [PlayerX]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 0)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 2)) + OAMA_X], a
    add 8
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 1)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 3)) + OAMA_X], a
    ld a, [PlayerY]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 0)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 1)) + OAMA_Y], a
    add 16
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 2)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (PLAYER_SPRITE + 3)) + OAMA_Y], a

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