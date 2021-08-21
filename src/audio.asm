INCLUDE "hardware.inc"
INCLUDE "macros.inc"

SECTION "Audio Code", ROM0

initAudio::
    ; Init sound registers
    ld a, $FF
    ldh [rAUDENA], a ; Turn on sound controller
    ldh [rAUDVOL], a ; Set master volume to max
    ld a, AUDTERM_4_LEFT | AUDTERM_4_RIGHT
    ldh [rAUDTERM], a ; Enable only noise channel

    rom_bank_switch BANK("Sound FX")
    call InitFXEngine
    ret

updateAudio::
    rom_bank_switch BANK("Sound FX")
    call UpdateFXEngine
    ret

PlayShortCrashSound::
    rom_bank_switch BANK("Sound FX")
    ld hl, FX_ShortCrash
    call PlayNewFX
    ret

PlayCarExplodeSound:: ; maybe make these sound play functions into a macro?
    rom_bank_switch BANK("Sound FX")
    ld hl, FX_CarExplode
    call PlayNewFX
    ret