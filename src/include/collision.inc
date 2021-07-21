; Collision Array Allocation
RSRESET
DEF PLAYER_COLLISION RB 6
DEF ENEMYCAR_COLLISION_1 RB 6
DEF ENEMYCAR_COLLISION_2 RB 6
DEF ENEMYCAR_COLLISION_3 RB 6

; Process collision between an object and the road edges
; /1 = Car X Memory Address
; /2 = Car Y Memory Address
; Sets - A B H L to garbage
MACRO RoadEdgeCollision
    ld a, [\2]
    ld b, a
    ld a, [CurrentRoadScrollPos]
    add b ; a = CarY + CurrentRoadScrollPos
    sub 16 ; a = (CarY + CurrentRoadScrollPos) - 16 (sprites are offset by 16)
    ld l, a
    ld h, RoadCollisionTableLeftX >> 8 ; HL = address into RoadCollisionTableLeftX
    ld a, [\1]
    cp [hl] ; C: Set if no borrow (a < [hl])
    jr nc, .noLeftCollide\@
    ld a, [hl]
    ld [\1], a
.noLeftCollide\@:
    ld h, RoadCollisionTableRightX >> 8
    ld a, [\1]
    add 16 ; assume car is 16 pix wide - change later?
    cp [hl]
    jr c, .noRightCollide\@
    ld a, [hl]
    sub 16
    ld [\1], a
.noRightCollide\@:
ENDM