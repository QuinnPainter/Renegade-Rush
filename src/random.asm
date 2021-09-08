SECTION "random_vars", WRAM0
RandState:: DS 2

SECTION "random", ROM0

; could switch to ISSOtm's one later if this one isn't random enough?
; https://github.com/ISSOtm/gb-starter-kit/blob/master/src/misc/rand.asm

; Seeding the generator is accomplished by just setting RandState.
; Make sure it isn't 0!

; Generate a pseudorandom number between 1 and FFFF
; Sets - HL = pseudorandom number
; Sets - A to L (lower byte of random number)
; http://www.retroprogramming.com/2017/07/xorshift-pseudorandom-numbers-in-z80.html
genRandom::
    ld hl, RandState
    ld a, [hli]
    ld l, [hl]
    ld h, a
    rra
    ld a, l
    rra
    xor h
    ld h, a
    ld a, l
    rra
    ld a, h
    rra
    xor l
    ld l, a
    xor h
    ld h, a
    ld [RandState], a
    ld a, l
    ld [RandState + 1], a
    ret