include "hardware.inc/hardware.inc"

; Change PlayerX or PlayerY by a given amount.
; \1 = PlayerX or PlayerY
; \2 = Amount to change by (memory address). Usually PlayerXSpeed or PlayerYSpeed
; \3 = 0 for subtract, 1 for add
; Sets - H L A to garbage
MACRO PlayerMove
    ld hl, \2
    ld a, [hli]
    ld l, [hl]
    ld h, a
    ld a, [\1 + 1]
IF \3 == 0 
    sub l
ELSE
    add l
ENDC
    ld [\1 + 1], a
    ld a, [\1]
IF \3 == 0
    sbc h
ELSE
    adc h
ENDC
    ld [\1], a
ENDM

; Set the player tiles and attributes from PlayerTilemap and PlayerAttrmap
; \1 = Offset into tilemap (number of tiles)
; Sets - A to garbage
MACRO SetPlayerTilesAndAttributes
    ld hl, PlayerTilemap + \1 ; Set player tiles
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 0) + OAMA_TILEID], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 1) + OAMA_TILEID], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 2) + OAMA_TILEID], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 3) + OAMA_TILEID], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 4) + OAMA_TILEID], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 5) + OAMA_TILEID], a

    ld hl, PlayerAttrmap + \1 ; Set player sprite attributes
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 0) + OAMA_FLAGS], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 1) + OAMA_FLAGS], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 2) + OAMA_FLAGS], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 3) + OAMA_FLAGS], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 4) + OAMA_FLAGS], a
    ld a, [hli]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 5) + OAMA_FLAGS], a
ENDM

SECTION "PlayerVariables", WRAM0
PlayerX:: DS 2 ; Coordinates of the top-left of the player. 8.8 fixed point.
PlayerY:: DS 2
PlayerXSpeed:: DS 2 ; Speed of the player in pixels per frame. 8.8 fixed point.
PlayerYSpeed:: DS 2

SECTION "PlayerCode", ROM0

initPlayer::
    ld a, $50
    ld [PlayerX], a
    ld a, $70
    ld [PlayerY], a
    ld a, $2
    ld [PlayerXSpeed], a
    ld [PlayerYSpeed], a
    xor a
    ld [PlayerX + 1], a
    ld [PlayerY + 1], a
    ld [PlayerXSpeed + 1], a
    ld [PlayerYSpeed + 1], a
    jp EntryPoint.doneInitPlayer

updatePlayer::
    ld c, 0 ; C holds the movement state: 0 = not turning, 1 = turning left, 2 = turning right

    ld a, [curButtons]
    ld b, a ; save curButtons into b
    and PADF_UP
    jr z, .upNotPressed
    ; Subtract PlayerYSpeed from Player Y
    PlayerMove PlayerY, PlayerYSpeed, 0
.upNotPressed:

    ld a, b
    and PADF_DOWN
    jr z, .downNotPressed
    ; Add PlayerYSpeed to Player Y
    PlayerMove PlayerY, PlayerYSpeed, 1
.downNotPressed:

    ld a, b
    and PADF_LEFT
    jr z, .leftNotPressed
    ld c, 1 ; movement state = turning left
    ; Subtract PlayerXSpeed from Player X
    PlayerMove PlayerX, PlayerXSpeed, 0
.leftNotPressed:

    ld a, b
    and PADF_RIGHT
    jr z, .rightNotPressed
    ld c, 2 ; movement state = turning right
    ; Add PlayerXSpeed to Player X
    PlayerMove PlayerX, PlayerXSpeed, 1
.rightNotPressed:

    ld a, c
    and a ; get flags
    jr z, .ForwardSprite
    cp 1
    jr z, .LeftSprite
    SetPlayerTilesAndAttributes 12 ; right sprite
    jr .DoneSetSprite
.LeftSprite:
    SetPlayerTilesAndAttributes 6
    jr .DoneSetSprite
.ForwardSprite:
    SetPlayerTilesAndAttributes 0
.DoneSetSprite:

    ld a, [PlayerY]
    cp $10 ; Cap minimum Y to $10 (top of the screen)
    jr nc, .aboveMinY
    ld a, $10
    ld [PlayerY], a
.aboveMinY:

    ld a, [PlayerY]
    cp $89 ; Cap maximum Y to $89 (bottom of the screen)
    jr c, .belowMaxY
    ld a, $89
    ld [PlayerY], a
.belowMaxY:

    ; Move the 6 player car sprites to (PlayerX, PlayerY)
    ld a, [PlayerX]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 0) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 2) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 4) + OAMA_X], a
    add 8
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 1) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 3) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 5) + OAMA_X], a
    ld a, [PlayerY]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 0) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 1) + OAMA_Y], a
    add 8
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 2) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 3) + OAMA_Y], a
    add 8
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 4) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * 5) + OAMA_Y], a
    jp GameLoop.doneUpdatePlayer