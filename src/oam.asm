include "hardware.inc/hardware.inc"

SECTION "SpriteBuffer", WRAM0, ALIGN[8]
SpriteBuffer::
    DS 40 * 4 ; 40 sprites * 4 bytes each

SECTION "DMARoutineROM", ROM0
; The routine that gets copied into HRAM and executed during the DMA transfer
; Is 14 bytes long
; Sets - A to 0
DMARoutine::
    ; start DMA transfer
    ld a, SpriteBuffer >> 8
    ld [rDMA], a
    ; wait 160 cycles/microseconds, the time it takes for the
    ; transfer to finish; this works because 'dec' is 1 cycle
    ; and 'jr' is 3, for 4 cycles done 40 times
    ld a, 40
.loop:
    dec a
    jr nz, .loop
    ret

SECTION "DMARoutineHRAM", HRAM
DMARoutineHRAM::
    DS 14 ; Reserve 14 bytes in HRAM for the OAM DMA routine