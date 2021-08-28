INCLUDE "hardware.inc"
INCLUDE "macros.inc"

SECTION "Audio Code", ROM0

initAudio::
    ; Init sound registers
    ld a, $FF
    ldh [rAUDENA], a ; Turn on sound controller
    ldh [rAUDTERM], a ; Enable all channels
    ld a, $77
    ldh [rAUDVOL], a ; Set master volume to max

    rom_bank_switch BANK("Sound FX")
    call InitFXEngine
    ret

updateAudio::
    rom_bank_switch BANK("Sound FX")
    call UpdateFXEngine
    ret