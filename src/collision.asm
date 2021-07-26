; Each collision array entry:
; Byte 1 = Layer Flags (each bit is a different layer, only objs with the same layer bit set will collide)
;   Bit 0 = Player / Enemy Car Layer
;   Bit 1 = Player / Enemy Missile Layer
;   Bit 2 = Player Missile / Missile-able Enemy Layer
; Byte 2 = Y Position (of top)
; Byte 3 = Y Position (of bottom)
; Byte 4 = X Position (of left)
; Byte 5 = X Position (of right)
; Byte 6 = Movement Info (used for car collisions)
;   Bits 0 - 3 = Car Speed
;   Bit 4 - Moving Up
;   Bit 5 - Moving Down
;   Bit 6 - Moving Right
;   Bit 7 - Moving Left
SECTION "ObjCollisionArray", WRAM0, ALIGN[6]
ObjCollisionArray::
    DS 6 * 10 ; 6 bytes * 10 collision objects. Don't think all 10 slots are used, could reduce this later?
ObjCollisionArrayEnd::

SECTION "CollisionCode", ROM0

; Initialises collision
; Sets - A C H L to garbage
initCollision::
    ld hl, ObjCollisionArray
    ld c, ObjCollisionArrayEnd - ObjCollisionArray
    xor a
    rst memsetFast
    ret

; Input - A = Index of object to check collision for
; Sets - A = Nonzero if collided, 0 if not
; Sets - B = Collided object flags
; Sets - C = Collided object top Y
; Sets - D = Collided object left X
; Sets - E = Collided object movement info (only applies to cars)
; Sets - H L to garbage
objCollisionCheck::
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
    ld a, b          ; \
    cp l             ; |  Check if the current object is the same as the base object
    jr z, .noCol5Inc ; /
    ld a, [hli]      ; \
    and c            ; |  Check if the objects have corresponding flags
    jr z, .noCol4Inc ; /
    ld a, [hli]
    cp e ; C unset if this object bottom Y <= other object top Y (no collision)
    jr nc, .noCol3Inc
    ld a, [hli]
    dec a ; decrement to make consistent with other side
    cp d ; C set if other object bottom Y < this object top Y (no collision)
    jr c, .noCol2Inc
    ldh a, [Scratchpad + 1]
    dec a ; decrement to make consistent with other side
    cp [hl] ; C set if this object right X < other object left X (no collision)
    inc l
    jr c, .noCol1Inc
    ldh a, [Scratchpad]
    cp [hl] ; C unset if other object right X <= this object left X (no collision)
    jr nc, .noCol1Inc
    ; all conditions passed - we have a collision
    inc l
    ld a, [hld]
    ld e, a ; save movement info in E
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
    inc l ; skip movement info byte
    ld a, LOW(ObjCollisionArrayEnd) ; \
    cp l                            ; | Check if we got to the end of the array
    jr nz, .checkColLoop            ; /
    xor a ; A = 0 - no collision
    ret