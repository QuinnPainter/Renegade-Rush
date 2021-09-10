include "hardware.inc"

SECTION "SpriteBuffer", WRAM0, ALIGN[8]
SpriteBuffer::
    DS 40 * 4 ; 40 sprites * 4 bytes each

SECTION "DMARoutineROM", ROM0
; The routine that gets copied into HRAM and executed during the DMA transfer
; Sets - A to 0
DMARoutine::
    ; start DMA transfer
    ld a, HIGH(SpriteBuffer) ;c2 b2
    ldh [rDMA], a ;c3 b2
    ; wait 160 cycles/microseconds, the time it takes for the
    ; transfer to finish; this works because 'dec' is 1 cycle
    ; and 'jr' is 3, for 4 cycles done 40 times
    ld a, 40 ; c2 b2
.loop:
    dec a ;c1 b1
    jr nz, .loop ;c3/2 b2
    ret ;c4 b1
DMARoutineEnd:

SECTION "DMARoutineHRAM", HRAM
DMARoutineHRAM::
    DS DMARoutineEnd - DMARoutine ; Reserve space in HRAM for the OAM DMA routine