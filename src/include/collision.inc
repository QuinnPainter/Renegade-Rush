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
MACRO road_edge_collision
    ld a, [\2]
    ld b, a
    ld a, [CurrentRoadScrollPos]
    add b ; a = CarY + CurrentRoadScrollPos
    sub 16 ; a = (CarY + CurrentRoadScrollPos) - 16 (sprites are offset by 16)
    ld l, a
    ld h, HIGH(RoadCollisionTableLeftX) ; HL = address into RoadCollisionTableLeftX
    ld a, [\1]
    cp [hl] ; C: Set if no borrow (a < [hl])
    jr nc, .noLeftCollide\@
    ld a, [hl]
    ld [\1], a
.noLeftCollide\@:
    ld h, HIGH(RoadCollisionTableRightX)
    ld a, [\1]
    add 16 ; assume car is 16 pix wide - change later?
    cp [hl]
    jr c, .noRightCollide\@
    ld a, [hl]
    sub 16
    ld [\1], a
.noRightCollide\@:
ENDM

; Calculate the knockback speeds after a collision has occured
; Has to be called directly after objCollisionCheck as the register outputs are used.
; Make sure the bank has been switched to the one containing CollisionArray beforehand.
MACRO process_knockback
DEF BASE_KNOCKBACK_FRAMES\@ EQUS "\1"      ; 8.8 fixed point constant
DEF RemainingKnockbackFrames\@ EQUS "\2"   ; Address
DEF ThisObjX\@ EQUS "\3"                   ; Address
DEF ThisObjY\@ EQUS "\4"                   ; Address
DEF CollisionArray\@ EQUS "\5"             ; Address
DEF KnockbackSpeedX\@ EQUS "\6"            ; Address
DEF KnockbackSpeedY\@ EQUS "\7"            ; Address
    push bc ; save C (other obj Y) for later
    ; calculate knockback frames
    ld a, e ; move movement info to A
    and $0F ; isolate speed value
    cp 4 ; if speed < this value, knockback is not doubled
    ld a, BASE_KNOCKBACK_FRAMES
    jr c, .noDoubleKnockFrames\@
    add a
.noDoubleKnockFrames\@:
    ld [RemainingKnockbackFrames\@], a
    ; calculate knockback speed
    ld a, [ThisObjX\@]
    sub d ; subtract x pos of other object
    ld d, 0 ; now D is used to keep track of if X (bit 0) and Y (bit 1) are positive (0) or negative (1)
    call absolute
    jr z, .xPositive\@
    set 0, d
.xPositive\@:
    pop bc ; restore C (other obj Y)
    ld b, a ; move X offset to B
    ld a, [ThisObjY\@]
    sub c
    call absolute
    jr z, .yPositive\@
    set 1, d
.yPositive\@:
    ld h, 0 ; move Y Offset to HL
    ld l, a
    add hl, hl ; left shift 4 times = * 16 (16 X positions for each Y)
    add hl, hl
    add hl, hl
    add hl, hl
    ld c, b ; move X Offset to BC
    ld b, 0
    add hl, bc ; HL = (yOffset * 16) + xOffset
    add hl, hl ; left shift 2 more times = * 4 (4 bytes per entry)
    add hl, hl
    ld bc, CollisionArray\@
    add hl, bc ; HL = CollisionArray + ((yOffset * 16) + xOffset) * 4
    ld a, [hli] ; A = High byte X Speed
    ld [KnockbackSpeedX\@], a
    ld a, [hli]
    ld [KnockbackSpeedX\@ + 1], a
    ld a, [hli]
    ld [KnockbackSpeedY\@], a
    ld a, [hli]
    ld [KnockbackSpeedY\@ + 1], a
    ; invert X speed if going left
    bit 0, d
    jr z, .noInvertX\@
    ld hl, KnockbackSpeedX\@ ; \
    ld a, [hli]              ; | load 16 bit value in KnockbackSpeedX into HL
    ld l, [hl]               ; |
    ld h, a                  ; /
    neg_16 hl, hl
    ld a, h
    ld [KnockbackSpeedX\@], a
    ld a, l
    ld [KnockbackSpeedX\@ + 1], a
.noInvertX\@:
    ; invert Y speed if going up
    bit 1, d
    jr z, .noInvertY\@
    ld hl, KnockbackSpeedY\@ ; \
    ld a, [hli]              ; | load 16 bit value in KnockbackSpeedY into HL
    ld l, [hl]               ; |
    ld h, a                  ; /
    neg_16 hl, hl
    ld a, h
    ld [KnockbackSpeedY\@], a
    ld a, l
    ld [KnockbackSpeedY\@ + 1], a
.noInvertY\@:
PURGE BASE_KNOCKBACK_FRAMES\@
PURGE RemainingKnockbackFrames\@
PURGE ThisObjX\@
PURGE ThisObjY\@
PURGE CollisionArray\@
PURGE KnockbackSpeedX\@
PURGE KnockbackSpeedY\@
ENDM