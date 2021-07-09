INCLUDE "hardware.inc/hardware.inc"

SECTION "Input Vars", WRAM0
curButtons:: DB ; Buttons currently held down
newButtons:: DB ; Buttons that changed to pressed in the last frame

SECTION "InputCode", ROM0
; Reads the joypad state
; Sets - A and B to the joypad state
; in the order Start, Select, B, A, Down, Up, Left, Right
; 0 is released, 1 is pressed
readInput::
    ld a, ~P1F_5 ; Read buttons
	ldh [rP1], a
    call .knownret ; Waste 10 cycles
	ldh a, [rP1]
	ldh a, [rP1] ; Read a couple times for a delay to allow signals to propagate
	ldh a, [rP1]
	and $0F ; only get last 4 bits
	swap a	; swap last 4 bits with first 4
	ld b, a
	ld a, ~P1F_4 ; Read directions
	ldh [rP1], a
    call .knownret ; Waste 10 cycles
	ldh a, [rP1]
	ldh a, [rP1] ; Read a couple times for a delay to allow signals to propagate
	ldh a, [rP1]
	and $0F
	or b
	cpl		; invert so 0 is released 1 is pressed
	ld b, a ; set B to pressed buttons
    ld a, [curButtons] ; set A to last frame's buttons
    xor b ; CurrentInput xor PrevFrameInput gives the buttons that have changed
    and b ; Gives buttons that changed to 1 (were just pressed)
    ld [newButtons], a
    ld a, b
    ld [curButtons], a
.knownret:
	ret