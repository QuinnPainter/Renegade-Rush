; Add two 16 bit numbers in RAM
; \1 = Number 1
; \2 = Number 2
; \3 = Where to save result
; Sets - H L A to garbage
MACRO add_16
    ld hl, \2
    ld a, [hli]
    ld l, [hl]
    ld h, a
    ld a, [\1 + 1]
    add l
    ld [\3 + 1], a
    ld a, [\1]
    adc h
    ld [\3], a
ENDM

; Subtract two 16 bit numbers in RAM
; \1 = Number 1
; \2 = Number 2
; \3 = Where to save result
; Sets - H L A to garbage
MACRO sub_16
    ld hl, \2
    ld a, [hli]
    ld l, [hl]
    ld h, a
    ld a, [\1 + 1]
    sub l
    ld [\3 + 1], a
    ld a, [\1]
    sbc h
    ld [\3], a
ENDM