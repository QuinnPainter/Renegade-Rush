; Switch ROM banks
; Input - A = Bank number
; If >256 banks is needed later, rROMB1 specifies the upper bit of the bank number.
; \1 = Bank number
MACRO rom_bank_switch
    ld a, \1
    ld [rROMB0], a
endm

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

; Compare two 16 bit numbers in RAM
; \1 = Number 1
; \2 = Number 2
; Sets - A to garbage
; Sets - HL = \2
; Sets - Z if high bytes are equal (high byte result is 0)
; Sets - C if underflow occurs (\1 < \2)
MACRO cp_16
    ld hl, \2 + 1
    ld a, [\1 + 1]
    sub [hl]
    dec hl
    ld a, [\1]
    sbc [hl]
ENDM

; Safe version of "inc hl" that doesn't have the OAM bug
MACRO inc_hl
    push bc
    ld bc, 1
    add hl, bc
    pop bc
ENDM

; Performs multiply by -1
; Input - \1 = 16 bit register pair
; Sets - \2 to result
; Sets - A to garbage
MACRO neg_16
    xor a
    sub LOW(\1)
    ld LOW(\2), a
    sbc a
    sub HIGH(\1)
    ld HIGH(\2), a
ENDM

; Subtracts two 16 bit register pairs
; Input - \1 = Number subtracted from
; Input - \2 = Number to subtract
; Sets - \3 = Result
; Sets - A to garbage
; Sets - Z if high bytes are equal (high byte result is 0)
; Sets - C if underflow occurs (\1 < \2)
MACRO sub_16r
    ld a, LOW(\1)
    sub LOW(\2)
    ld LOW(\3), a
    ld a, HIGH(\1)
    sbc HIGH(\2)
    ld HIGH(\3), a
ENDM

; Compares two 16 bit register pairs
; Input - \1 = Number subtracted from
; Input - \2 = Number to subtract
; Sets - A to garbage
; Sets - Z if high bytes are equal (high byte result is 0)
; Sets - C if underflow occurs (\1 < \2)
MACRO cp_16r
    ld a, LOW(\1)
    sub LOW(\2)
    ld a, HIGH(\1)
    sbc HIGH(\2)
ENDM

; Allows consolidating the loading of 2 bytes into a register pair into one 16 bit load
; for example "lb bc, bvalue, cvalue"
MACRO lb 
    ld \1, (\2) << 8 | (\3)
ENDM

; Plays a sound effect
; Input - \1 = Address of sound effect
; Sets - A B H L to garbage
MACRO play_sound_effect
    rom_bank_switch BANK("Sound FX")
    ld hl, \1
    call PlayNewFX
ENDM