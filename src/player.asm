include "hardware.inc/hardware.inc"
include "spriteallocation.inc"

PLAYER_MIN_Y EQU $50 ; Cap minimum Y to $50 ($10 is top of the screen)
PLAYER_MAX_Y EQU $80 ; Cap maximum Y to $80 ($89 is bottom of the screen)

; Add / Subtract two 16 bit numbers in RAM
; \1 = Number 1 - result is saved back to here
; \2 = Number 2
; \3 = 0 for subtract, 1 for add
; Sets - H L A to garbage
MACRO AddSub16
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

    ld hl, PlayerAttrmap + \1 ; Set player sprite attributes
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
ENDM

SECTION "PlayerVariables", WRAM0
PlayerX:: DS 2 ; Coordinates of the top-left of the player. 8.8 fixed point.
PlayerY:: DS 2
PlayerXSpeed:: DS 2 ; Speed of the player moving around on the screen in pixels per frame. 8.8 fixed point.
PlayerYSpeed:: DS 2
PlayerMaxRoadSpeed:: DS 2 ; Max and min speeds of the car, in terms of road scroll speed. 8.8 fixed point.
PlayerMinRoadSpeed:: DS 2
PlayerAcceleration:: DS 2 ; Player's road scroll acceleration - pixels per frame per frame. 8.8 fixed point.
CurrentRoadScrollSpeed:: DS 2 ; Speed of road scroll, in pixels per frame. 8.8 fixed-point.

SECTION "PlayerCode", ROM0

initPlayer::
    ld a, $50
    ld [PlayerX], a
    ld a, $70
    ld [PlayerY], a
    ld a, $2
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
    ld [PlayerXSpeed + 1], a
    jp EntryPoint.doneInitPlayer

updatePlayer::
    ld c, 0 ; C holds the movement state: 0 = not turning, 1 = turning left, 2 = turning right

    ld a, [curButtons]
    ld b, a ; save curButtons into b
    and PADF_UP
    jr z, .upNotPressed
    ; Subtract PlayerYSpeed from Player Y
    AddSub16 PlayerY, PlayerYSpeed, 0
    AddSub16 CurrentRoadScrollSpeed, PlayerAcceleration, 1
.upNotPressed:

    ld a, b
    and PADF_DOWN
    jr z, .downNotPressed
    ; Add PlayerYSpeed to Player Y
    AddSub16 PlayerY, PlayerYSpeed, 1
    AddSub16 CurrentRoadScrollSpeed, PlayerAcceleration, 0
.downNotPressed:

    ld a, b
    and PADF_LEFT
    jr z, .leftNotPressed
    ld c, 1 ; movement state = turning left
    ; Subtract PlayerXSpeed from Player X
    AddSub16 PlayerX, PlayerXSpeed, 0
.leftNotPressed:

    ld a, b
    and PADF_RIGHT
    jr z, .rightNotPressed
    ld c, 2 ; movement state = turning right
    ; Add PlayerXSpeed to Player X
    AddSub16 PlayerX, PlayerXSpeed, 1
.rightNotPressed:

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

    ; Collision detection with the road edges
    ld a, [PlayerY]
    ld b, a
    ld a, [CurrentRoadScrollPos]
    add b ; a = PlayerY + CurrentRoadScrollPos
    sub 16 ; a = (PlayerY + CurrentRoadScrollPos) - 16 (sprites are offset by 16)
    ld l, a
    ld h, RoadCollisionTableLeftX >> 8 ; HL = address into RoadCollisionTableLeftX
    ld a, [PlayerX]
    cp [hl] ; C: Set if no borrow (a < [hl])
    jr nc, .noLeftCollide
    ld a, [hl]
    ld [PlayerX], a
.noLeftCollide:
    ld h, RoadCollisionTableRightX >> 8
    ld a, [PlayerX]
    add 16 ; car is 16 pix wide
    cp [hl]
    jr c, .noRightCollide
    ld a, [hl]
    sub 16
    ld [PlayerX], a
.noRightCollide:

    jp GameLoop.doneUpdatePlayer