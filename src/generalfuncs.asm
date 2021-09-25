INCLUDE "hardware.inc"
INCLUDE "macros.inc"

; All functions are in different sections so they can cram into small gaps
; such as the gaps between interrupt vectors

SECTION "Memset", ROM0

; Fills a block of memory with a value
; Input - HL = Destination address
; Input - BC = Number of bytes
; Input - A	 = Value to fill with
; Sets	- BC to 0
; Sets	- HL to end of block
memset::
    inc b
    inc c
    jr .decCounter
.loadByte:
    ld [hli], a
.decCounter:
    dec c
    jr nz, .loadByte
    dec b
    jr nz, .loadByte
    ret

SECTION "Memcpy", ROM0

; Copies a block of data
; Input - HL = Destination address
; Input - DE = Start address
; Input - BC = Data length
; Sets  - A to garbage
; Sets	- BC to 0
; Sets	- HL DE to their initial values + BC
memcpy::
    dec bc
    inc b
    inc c
.loop:
    ld a, [de]
    ld [hli], a
    inc de
    dec c
    jr nz, .loop
    dec b
    jr nz, .loop
    ret

/*SECTION "Shift Left", ROM0

; Shift B left by a given amount
; Input - B = Value to shift
; Input - A = How many times to shift
; Sets - B to shifted value
; Sets - A to 0
shiftLeft::
    and a ; Return immediately if A is 0
    ret z ;
.lp:
    sla b
    dec a
    jr nz, .lp
    ret

SECTION "Shift Left 16", ROM0

; Shift HL left by a given amount
; Input - HL = Value to shift
; Input - A = How many times to shift
; Sets - HL to shifted value
; Sets - A to 0
shiftLeft16::
    and a ; Return immediately if A is 0
    ret z ;
.lp:
    add hl, hl ; adding with itself is equivalent to left shift by 1
    dec a
    jr nz, .lp
    ret*/

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

SECTION "Difference", ROM0

; Gets the difference between 2 unsigned 8 bit numbers
; by subtracting the smaller number from the bigger one
; Input - A B = Numbers to compare
; Sets - A = Difference
difference::
    cp b
    jr nc, .aGrtrThanB ; technically a >= b
    cpl ; Calc B-A
    inc a
    add b
    ret
.aGrtrThanB:
    sub b ; Calc A-B
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

; Copies a string (ending in 0)
; Input - HL = Destination address
; Input - BC = Start address
; Sets	- A to garbage
; Sets  - HL BC to original values + string length
copyString::
	ld a, [bc]
    and a
    ret z
	ld [hli], a
	inc bc
	jr copyString

SECTION "Disable LCD", ROM0

; Disable the LCD during VBlank
; Calling this when the LCD is already disabled
; will result in a permanent loop!
; Sets - A to 0
disableLCD::
	ldh a, [rLY]
	cp 144 ; Check if the LCD is past VBlank
	jr c, disableLCD
	xor a ; turn off the LCD
	ldh [rLCDC], a
    ret

SECTION "ScreenTilemapCopy", ROM0

; Copy a tilemap to the screen
; Input - HL = Destination Screen RAM address
; Input - BC = Source data address
; Input - A  = Number of lines to copy (Line = 20 tiles)
; Sets  - A B C D E H L S[0] to garbage
ScreenTilemapCopy::
    ldh [Scratchpad], a
    lb de, 20, 12
    ;ld de, 12 ; Offset needed to jump from end of this line to start of next line
    ;ld e, 20 ; 20 tiles in a line
.tilemapCopyLp:
    ld a, [bc]
    inc bc
    ld [hli], a
    dec d
    jr nz, .tilemapCopyLp
    add hl, de ; D is always 0 here, so this is add hl, 12
    ld d, 20
    ldh a, [Scratchpad]
    dec a
    ldh [Scratchpad], a
    jr nz, .tilemapCopyLp
    ret

SECTION "LCDScreenTilemapCopy", ROM0
; Copy a tilemap to the screen, while LCD is enabled
; Input - HL = Destination Screen RAM address
; Input - BC = Source data address
; Input - A  = Number of lines to copy (Line = 20 tiles)
; Sets  - A B C D E H L S[0] to garbage
LCDScreenTilemapCopy::
    ldh [Scratchpad], a
    lb de, 20, 12
    ;ld de, 12 ; Offset needed to jump from end of this line to start of next line
    ;ld e, 20 ; 20 tiles in a line
.tilemapCopyLp:
    di
    ldh a, [rSTAT]          ; \
	and STATF_BUSY          ; | Wait for VRAM to be ready
	jr nz, .tilemapCopyLp   ; /
    ld a, [bc]
    ld [hli], a
    ei
    inc bc
    dec d
    jr nz, .tilemapCopyLp
    add hl, de ; D is always 0 here, so this is add hl, 12
    ld d, 20
    ldh a, [Scratchpad]
    dec a
    ldh [Scratchpad], a
    jr nz, .tilemapCopyLp
    ret

SECTION "LCD Memset", ROM0

; Set a block of VRAM, while making sure VRAM is accesible.
; Input - HL = Destination address
; Input - BC = Length
; Input - D  = Value to set
; Sets  - HL = Original value + BC
; Sets  - BC = 0
; Sets  - A  = D
LCDMemset::
    inc b
    inc c
    jr .decCounter
.loadByte:
    di
	ldh a, [rSTAT]      ; \
	and STATF_BUSY      ; | Wait for VRAM to be ready
	jr nz, .loadByte    ; /
    ld a, d
    ld [hli], a
    ei
.decCounter:
    dec c
    jr nz, .loadByte
    dec b
    jr nz, .loadByte
    ret

SECTION "LCD Memset Fast", ROM0

; Set a block of VRAM, while making sure VRAM is accesible.
; Input - HL = Destination address
; Input - C  = Length
; Input - B  = Value to set
; Sets  - HL = Original value + C
; Sets  - C  = 0
; Sets  - A  = B
LCDMemsetFast::
    di
	ldh a, [rSTAT]          ; \
	and STATF_BUSY          ; | Wait for VRAM to be ready
	jr nz, LCDMemsetFast    ; /
	ld a, b
	ld [hli], a
    ei
	dec c
	jr nz, LCDMemsetFast
	ret

SECTION "LCD Memcpy", ROM0
; Copy data into VRAM, while making sure VRAM is accesible.
; Input - HL = Destination address
; Input - DE = Source address
; Input - BC = Length
LCDMemcpy::
    dec bc
    inc b
    inc c
.loop:
    di
    ldh a, [rSTAT]          ; \
    and STATF_BUSY          ; | Wait for VRAM to be ready
    jr nz, .loop            ; /
    ld a, [de]
    ld [hli], a
    ei
    inc de
    dec c
    jr nz, .loop
    dec b
    jr nz, .loop
    ret

SECTION "LCD Memcpy Fast", ROM0
; Copy data into VRAM, while making sure VRAM is accesible.
; Input - HL = Destination address
; Input - DE = Source address
; Input - C  = Length
; Sets  - C to 0
; Sets  - HL DE = HL DE + C
LCDMemcpyFast::
    ldh a, [rSTAT]          ; \
    and STATF_BUSY          ; | Wait for VRAM to be ready
    jr nz, LCDMemcpyFast    ; /
    ld a, [de]
    ld [hli], a
    inc de
    dec c
    jr nz, LCDMemcpyFast
    ret

SECTION "LCD Copy String", ROM0

; Copies a string (ending in 0), while making sure VRAM is accessible.
; Input - HL = Destination address
; Input - BC = Start address
; Sets	- A to garbage
; Sets  - HL BC to original values + string length
LCDCopyString::
    di
    ldh a, [rSTAT]          ; \
    and STATF_BUSY          ; | Wait for VRAM to be ready
    jr nz, LCDCopyString    ; /
	ld a, [bc]
    ei
    and a
    ret z
	ld [hli], a
	inc bc
	jr LCDCopyString