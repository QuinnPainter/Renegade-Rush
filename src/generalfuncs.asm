; All functions are in different sections so they can cram into small gaps
; such as the gaps between interrupt vectors

SECTION "Shift Left", ROM0

; Shift B left by a given amount
; Input - B = Value to shift
; Input - C = How many times to shift
; Sets - B to shifted value
; Sets - A C to garbage
shiftLeft::
    xor a ; \
    add c ; | Return immediately if C is 0
    ret z ; /
.lp:
    sla b
    dec c
    jr nz, .lp
    ret

SECTION "Shift Left 16", ROM0

; Shift HL left by a given amount
; Input - HL = Value to shift
; Input - C = How many times to shift
; Sets - HL to shifted value
; Sets - A C to garbage
shiftLeft16::
    xor a ; \
    add c ; | Return immediately if C is 0
    ret z ; /
.lp:
    add hl, hl ; adding with itself is equivalent to left shift by 1
    dec c
    jr nz, .lp
    ret

SECTION "Absolute", ROM0

; Gets the absolute value of a signed number
; Input - A = Number to get absolute value of
; Sets - A
; Sets - Z = 0 if number was positive, 1 if negative
absolute::
    bit 7, a
    ret z ; if number is positive, return
    cpl
    inc a
    ret

SECTION "BCD16", ROM0

; https://github.com/pinobatch/little-things-gb/blob/master/bdos/src/math.z80
; Converts a 16-bit number from binary to decimal in about 200 cycles.
; Input - HL = the number
; Sets - C = digit in myriads place
; Sets - D = digits in thousands and hundreds places
; Sets - E = digits in tens and ones places
; Sets - A B to garbage
bcd16::
    ; Bits 15-13: Just shift left into A (12 c)
    xor a
    ld d, a
    ld c, a
    add hl, hl
    adc a
    add hl, hl
    adc a
    add hl, hl
    adc a
  
    ; Bits 12-9: Shift left into A and DAA (33 c)
    ld b, 4
.l1:
    add hl, hl
    adc a
    daa
    dec b
    jr nz, .l1
  
    ; Bits 8-0: Shift left into E, DAA, into D, DAA, into C (139 c)
    ld e, a
    rl d
    ld b, 9
.l2:
    add hl, hl
    ld a, e
    adc a
    daa
    ld e, a
    ld a, d
    adc a
    daa
    ld d, a
    rl c
    dec b
    jr nz, .l2

    ret

SECTION "Vblank Wait", ROM0

; HALT until Vblank has happened.
; Sets - A to garbage
waitVblank::
    xor a
    ld [HasVblankHappened], a
:   halt
    ld a, [HasVblankHappened]
    and a
    jr z, :-
    ret

SECTION "Copy String", ROM0

; Copies a string (ending in -1)
; Input - HL = Destination address
; Input - DE = Start address
; Input - C = Amount to increase each char by (tile offset)
; Sets	- A H L D E to garbage
copyString::
	ld a, [de]
    cp -1
    ret z
    add c
	ld [hli], a
	inc de
	jr copyString