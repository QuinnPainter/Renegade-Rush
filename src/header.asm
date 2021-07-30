INCLUDE "macros.inc"

; rst vectors
; Used for fast, small, frequently used functions, since "rst" is slightly faster than "call"
; Can just substitute "call" for "rst", like "rst memset"
SECTION "rst00",ROM0[$00]
; Fills a block of memory with a value
; Input - HL = Destination address
; Input - BC = Number of bytes
; Input - D	 = Value to fill with
; Sets	- A B C to 0
; Sets	- H L to garbage
memset::
	ld [hl], d
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, memset
	ret

SECTION "rst08",ROM0[$08]
; Fills a block of memory with a value
; Faster than Memset, but can only set max 256 bytes
; Input - HL = Destination address
; Input - C = Number of bytes
; Input - A = Value to fill with
; Sets  - C to 0
; Sets  - H L to garbage
memsetFast::
	ld [hli], a
	dec c
	jr nz, memsetFast
	ret

SECTION "rst10",ROM0[$10]
; Copies a block of data
; Input - HL = Destination address
; Input - DE = Start address
; Input - BC = Data length
; Sets	- A B C to 0
; Sets	- H L D E to garbage
memcpy::
	ld a, [de] ; Grab 1 byte from the source
	ld [hli], a ; Place it at the destination, incrementing hl
	inc de ; Move to next byte
	dec bc ; Decrement count
	ld a, b ; Check if count is 0, since `dec bc` doesn't update flags
	or c
	jr nz, memcpy
	ret
	
; SECTION "rst18",ROM0[$18] ; memcpy is too big, so rst18 is sacrificed to make room

SECTION "rst20",ROM0[$20]
; Copies a block of data with max size 256
; Input - HL = Destination address
; Input - DE = Start address
; Input - C = Data length
; Sets	- C to 0
; Sets	- A H L D E to garbage
memcpyFast::
	ld a, [de]
	ld [hli], a
	inc de
	dec c
	jr nz, memcpyFast
	ret

; May as well remove unused rsts so that space can be used for other stuff
;SECTION "rst28",ROM0[$28]
;SECTION "rst30",ROM0[$30]
;SECTION "rst38",ROM0[$38]

; interrupt vectors
SECTION "vblank",ROM0[$40]
	jp VblankHandler
SECTION "lcdstat",ROM0[$48]
	jp LCDIntHandler
SECTION "timer",ROM0[$50]
	reti
SECTION "serial",ROM0[$58]
	reti
SECTION "joypad",ROM0[$60]
	reti

SECTION "Header", ROM0[$100]

	; This is the ROM's entry point
	; There's 4 bytes of code to do... something
	di
	jp EntryPoint

	; Make sure to allocate some space for the header, so no important
	; code gets put there and later overwritten by RGBFIX.
	; RGBFIX is designed to operate over a zero-filled header, so make
	; sure to put zeros regardless of the padding value. (This feature
	; was introduced in RGBDS 0.4.0, but the -MG etc flags were also
	; introduced in that version.)
	DS $150 - @, 0

SECTION "Interrupt Stuff RAM", WRAM0
VblankVectorRAM:: DS 2 ; Interrupt vector addresses.
LCDIntVectorRAM:: DS 2 ; These are jumped to on their corresponding interrupt.
HasVblankHappened:: DS 1 ; 1 if Vblank has happened this frame, 0 otherwise.

SECTION "Interrupt Handlers", ROM0

VblankHandler:
	push hl
	push af
	ld hl, VblankVectorRAM ; load value at VblankVectorRAM into HL
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp_hl ; jump to [VblankVectorRAM]
VblankEnd::
	pop af
	pop hl
	reti

LCDIntHandler:
	push hl
	push af
	ld hl, LCDIntVectorRAM ; load value at LCDIntVectorRAM into HL
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp_hl ; jump to [LCDIntVectorRAM]
LCDIntEnd::
	pop af
	pop hl
	reti