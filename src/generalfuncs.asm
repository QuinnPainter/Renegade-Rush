Section "General Functions", ROM0

; Shift B left by a given amount
; Input - B = Value to shift
; Input - C = How many times to shift
; Sets - B to shifted value
; Sets - A to garbage
shiftLeft::
    xor a ; \
    add c ; | Return immediately if C is 0
    ret z ; /
.lp:
    sla b
    dec c
    jr nz, .lp
    ret

; Gets the absolute value of a signed number
; Input - A = Number to get absolute value of
; Sets - A
absolute::
    bit 7, a
    ret z ; if number is positive, return
    cpl
    inc a
    ret