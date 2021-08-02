INCLUDE "hardware.inc/hardware.inc"
INCLUDE "macros.inc"

SELECTION_PALETTE EQU %00100111 ; Swap index 3 and 0 (darkest and lightest), middle 2 shades stay same
SELECTION_HEIGHT EQU 8 ; Vertical size of the selection bar, in pixels

SECTION "Menu Selection Vars", WRAM0
AfterSelIntVec:: DS 2 ; The interrupt vector that the LCD int is set to after the last line of the menu selection bar
AfterSelIntLine:: DS 1 ; The LY line the LCD int is set to afterwards
PrevPalette: DS 1 ; The palette used before the selection bar, that gets reset when the bar is over
IntState: DS 1 ; Are we on the first or last line interrupt? 0 = first, nonzero = last
SelBarTopLine:: DS 2 ; Current position of the top of the selection bar. 8.8 fixed point
SelBarTargetPos:: DS 1 ; Position the bar is animating towards.

SECTION "Menu Selection Code", ROM0

; Updates the position of the selection bar.
selectionBarUpdate::
    ld a, [SelBarTopLine]
    ld b, a
    ld a, [SelBarTargetPos]
    cp b
    ret z ; positions are already the same
    ld h, a                     ; \ Set HL to SelBarTargetPos
    ld l, $7F ; instead of aiming for 0, aim for the middle subpixel. this fixes some weirdness where it stays 1 pixel away from target
    ld a, [SelBarTopLine + 1]   ; \ Set BC to SelBarTopLine
    ld c, a                     ; /
    sub_16r hl, bc, hl ; HL = Offset between top line and target
    ld a, h             ; \
    rra                 ; |
    rr l                ; |
    rra                 ; |
    rr l                ; |
    bit 7, h            ; |
    jr nz, .negative    ; | Shift HL right twice
    and %00111111       ; |
    jr .doneApplySign   ; |
.negative:              ; |
    or %11000000        ; |
.doneApplySign:         ; |
    ld h, a             ; /
    add hl, bc ; Add new offset to top line
    ld a, h
    ld [SelBarTopLine], a
    ld a, l
    ld [SelBarTopLine + 1], a
    ret

; Set up the top line interrupt
; Sets - A to garbage
selectionBarSetupTopInt::
    ld a, LOW(selectionBarIntFunc)
    ld [LCDIntVectorRAM], a
    ld a, HIGH(selectionBarIntFunc)
    ld [LCDIntVectorRAM + 1], a
    ld a, [SelBarTopLine]
    dec a
    ld [rLYC], a
    xor a
    ld [IntState], a
    ret

; Runs on the top and bottom scanlines of the selection bar.
selectionBarIntFunc:
    ld a, [IntState]
    and a
    jr nz, .lastLine
    ldh a, [rBGP]
    ld [PrevPalette], a ; First line - set previous palette, and set current palette to flipped one
    ld b, SELECTION_PALETTE
    jr .donePickPalette
.lastLine: ; Last line - selection bar is over, set palette back to previous one
    ld a, [PrevPalette]
    ld b, a
.donePickPalette:

    ; Wait for safe VRAM access (next hblank)
:   ld a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ; Set LCD registers
    ld a, b
    ldh [rBGP], a

    ; Set up next interrupt
    ld a, [IntState]
    and a
    jr nz, .afterLastLine
    ld a, $FF ; Setup interrupt for last line of selection bar
    ld [IntState], a
    ld a, [SelBarTopLine]
    add SELECTION_HEIGHT - 1
    ld [rLYC], a
    jp LCDIntEnd
.afterLastLine:
    xor a
    ld [IntState], a
    ld a, [AfterSelIntVec] ; Setup interrupt for thing after selection bar
    ld [LCDIntVectorRAM], a
    ld a, [AfterSelIntVec + 1]
    ld [LCDIntVectorRAM + 1], a
    ld a, [AfterSelIntLine]
    dec a
    ld [rLYC], a
    jp LCDIntEnd