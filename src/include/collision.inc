; Collision Array Allocation
RSRESET
DEF PLAYER_COLLISION RB 6
DEF ENEMYCAR_COLLISION_1 RB 6
DEF ENEMYCAR_COLLISION_2 RB 6
DEF ENEMYCAR_COLLISION_3 RB 6

; Calculate the knockback speeds after a collision has occured
; Has to be called directly after objCollisionCheck as the register outputs are used.
; Make sure the bank has been switched to the one containing CollisionArray beforehand.
MACRO process_knockback
DEF ThisObjX\@ EQUS "\1"                   ; Address
DEF ThisObjY\@ EQUS "\2"                   ; Address
DEF CollisionArray\@ EQUS "\3"             ; Address
DEF KnockbackSpeedX\@ EQUS "\4"            ; Address
DEF KnockbackSpeedY\@ EQUS "\5"            ; Address
IF _NARG == 6
DEF ObjectLastTouched\@ EQUS "\6"          ; Address (optional)
    ; set ObjectLastTouched
    ld a, e
    swap a
    and $01
    ld [ObjectLastTouched\@], a
ENDC
    ; calculate knockback speed
    ld a, [ThisObjX\@]
    sub d ; subtract x pos of other object
    ld d, 0 ; now D is used to keep track of if X (bit 0) and Y (bit 1) are positive (0) or negative (1)
    call absolute
    jr z, .xPositive\@
    set 0, d
.xPositive\@:
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
    ; increase knockback if speed is sufficient
    ld a, e ; move movement info to A
    and $0F ; isolate speed value
    cp 4 ; if speed < this value, knockback is not increased
    jr c, .noDoubleKnockSpeed\@
    ld hl, KnockbackSpeedX\@ ; X knockback increase
    ld a, [hli]
    ld l, [hl]
    ld h, a

    ld b, h ; BC = 0.5 x HL
    ld c, l
    srl b
    rr c
    add hl, bc ; HL = HL * 1.5

    ld a, h
    ld [KnockbackSpeedX\@], a
    ld a, l
    ld [KnockbackSpeedX\@ + 1], a
    ld hl, KnockbackSpeedY\@    ; Y knockback increase
    ld a, [hli]
    ld l, [hl]
    ld h, a

    ld b, h ; BC = 0.5 x HL
    ld c, l
    srl b
    rr c
    add hl, bc ; HL = HL * 1.5

    ld a, h
    ld [KnockbackSpeedY\@], a
    ld a, l
    ld [KnockbackSpeedY\@ + 1], a
.noDoubleKnockSpeed\@:
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
PURGE ThisObjX\@
PURGE ThisObjY\@
PURGE CollisionArray\@
PURGE KnockbackSpeedX\@
PURGE KnockbackSpeedY\@
IF DEF(ObjectLastTouched\@)
PURGE ObjectLastTouched\@
ENDC
ENDM

MACRO update_knockback
DEF ThisObjX\@ EQUS "\1"                    ; Address
DEF ThisObjY\@ EQUS "\2"                    ; Address
DEF KnockbackSpeedX\@ EQUS "\3"             ; Address
DEF KnockbackSpeedY\@ EQUS "\4"             ; Address
DEF KnockbackSlowdownSpeedOther\@ EQUS "\5" ; 8.8 fixed point constant [Slowdown speed if hit by non-player]
IF _NARG >= 6
DEF KnockbackSlowdownSpeedPlayer\@ EQUS "\6"; 8.8 fixed point constant (optional) [Slowdown speed if hit by player]
DEF ObjectLastTouched\@ EQUS "\7"           ; Address (optional)
ENDC
    add_16 KnockbackSpeedX\@, ThisObjX\@, ThisObjX\@
    add_16 KnockbackSpeedY\@, ThisObjY\@, ThisObjY\@

IF DEF(ObjectLastTouched\@)
    ld a, [ObjectLastTouched\@]
    rra ; set carry to bit 1
    jr c, :+
    ld bc, KnockbackSlowdownSpeedOther\@
    jr .doneSetSlowdownSpeed\@
:   ld bc, KnockbackSlowdownSpeedPlayer\@
.doneSetSlowdownSpeed\@:
ELSE
    ld bc, KnockbackSlowdownSpeedOther\@
ENDC
    push bc

    ld hl, KnockbackSpeedX\@
    ld a, [hli]
    ld l, [hl]
    ld h, a
    ld d, a ; save top byte for later
    bit 7, h
    jr nz, :+
    neg_16 bc, bc
:   add hl, bc
    ld a, d ; determine if sign of HL changed, if it did, set it to 0
    xor h
    bit 7, a ; Z not set = sign changed
    jr z, :+
    ld hl, 0
:   ld a, h
    ld [KnockbackSpeedX\@], a
    ld a, l
    ld [KnockbackSpeedX\@ + 1], a

    ld hl, KnockbackSpeedY\@
    ld a, [hli]
    ld l, [hl]
    ld h, a
    ld d, a ; save top byte for later
    pop bc
    bit 7, h
    jr nz, :+
    neg_16 bc, bc
:   add hl, bc
    ld a, d ; determine if sign of HL changed, if it did, set it to 0
    xor h
    bit 7, a ; Z not set = sign changed
    jr z, :+
    ld hl, 0
:   ld a, h
    ld [KnockbackSpeedY\@], a
    ld a, l
    ld [KnockbackSpeedY\@ + 1], a
PURGE ThisObjX\@
PURGE ThisObjY\@
PURGE KnockbackSpeedX\@
PURGE KnockbackSpeedY\@
PURGE KnockbackSlowdownSpeedOther\@
IF DEF(KnockbackSlowdownSpeedPlayer\@)
PURGE KnockbackSlowdownSpeedPlayer\@
ENDC
IF DEF(ObjectLastTouched\@)
PURGE ObjectLastTouched\@
ENDC
ENDM