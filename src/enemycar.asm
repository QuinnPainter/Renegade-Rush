include "hardware.inc/hardware.inc"
include "spriteallocation.inc"
include "macros.inc"

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
EnemyCarX:: DS 2 ; Coordinates of the top-left of the car. 8.8 fixed point.
EnemyCarY:: DS 2
EnemyCarXSpeed:: DS 2 ; Speed of the car moving left and right on the screen in pixels per frame. 8.8 fixed point.
EnemyCarRoadSpeed:: DS 2 ; Speed of the car, in terms of road scroll speed. 8.8 fixed point.
EnemyCarAcceleration:: DS 2 ; Car's road scroll acceleration - pixels per frame per frame. 8.8 fixed point.
EnemyCarAnimationTimer:: DS 1 ; Incremented every frame. Used to update animations.
EnemyCarAnimationState:: DS 1 ; Current state of the animation. 0 = state 1, FF = state 2

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

    ; Collision detection with the road edges
    ld a, [EnemyCarY]
    ld b, a
    ld a, [CurrentRoadScrollPos]
    add b ; a = EnemyCarY + CurrentRoadScrollPos
    sub 16 ; a = (EnemyCarY + CurrentRoadScrollPos) - 16 (sprites are offset by 16)
    ld l, a
    ld h, RoadCollisionTableLeftX >> 8 ; HL = address into RoadCollisionTableLeftX
    ld a, [EnemyCarX]
    cp [hl] ; C: Set if no borrow (a < [hl])
    jr nc, .noLeftCollide
    ld a, [hl]
    ld [EnemyCarX], a
.noLeftCollide:
    ld h, RoadCollisionTableRightX >> 8
    ld a, [EnemyCarX]
    add 16 ; car is 16 pix wide
    cp [hl]
    jr c, .noRightCollide
    ld a, [hl]
    sub 16
    ld [EnemyCarX], a
.noRightCollide:
    ret

; Input - A = Index of object to check collision for
; Sets - A = Nonzero if collided, 0 if not
; Sets - B = Collided object flags
; Sets - C = Collided object top Y
; Sets - D = Collided object left X
; Sets - E H L to garbage
objCollisionCheck:
    ld hl, ObjCollisionArray
    add l
    ld l, a ; HL = address of base object
    ld b, a ; save location of base object for later

    ld a, [hli]
    ld c, a ; C = Collision Flags
    ld a, [hli]
    ld d, a ; D = Top Y
    ld a, [hli]
    ld e, a ; E = Bottom Y
    ld a, [hli]
    ldh [Scratchpad], a ; Scratchpad 0 = Left X
    ld a, [hli]
    ldh [Scratchpad + 1], a ; Scratchpad 1 = Right X

    ld l, LOW(ObjCollisionArray) ; reset to the start of the array
.checkColLoop:
    ld b, a          ; \
    cp l             ; |  Check if the current object is the same as the base object
    jr z, .noCol5Inc ; /
    ld a, [hli]      ; \
    and c            ; |  Check if the objects have corresponding flags
    jr z, .noCol4Inc ; /
    ld a, [hli]
    cp e ; C set if other object top Y < this object bottom Y (no collision)
    jr c, .noCol3Inc
    ld a, [hli]
    cp d ; C unset if this object top Y <= other object bottom Y (no collision)
    jr nc, .noCol2Inc
    ldh a, [Scratchpad + 1]
    cp [hl] ; C set if this object right X < other object left X (no collision)
    inc l
    jr c, .noCol1Inc
    ldh a, [Scratchpad]
    cp [hl] ; C unset if other object right X <= this object left X (no collision)
    jr c, .noCol1Inc
    ; all conditions passed - we have a collision
    dec l ; ignore Right X
    ld a, [hld]
    ld d, a ; save Left X in D
    dec l ; ignore Bottom Y
    ld a, [hld]
    ld c, a ; save Top Y in C
    ld a, [hld]
    ld b, a ; save collision flags in B
    ret ; A = nonzero - there was a collision
.noCol5Inc:
    inc l
.noCol4Inc:
    inc l
.noCol3Inc:
    inc l
.noCol2Inc:
    inc l
.noCol1Inc:
    inc l
    ld a, LOW(ObjCollisionArrayEnd) ; \
    cp l                            ; | Check if we got to the end of the array
    jr nz, .checkColLoop            ; /
    xor a ; A = 0 - no collision
    ret