INCLUDE "hardware.inc"

DEF SOUND_END EQU $FF
DEF CHANGE_PRIORITY EQU $FE

SECTION FRAGMENT "Sound FX", ROMX

; https://daid.github.io/gbsfx-studio/

FX_ShortCrash:: ; Played for small "bumps" between cars
    DB 0 ; Starting priority byte
    DB LOW(rNR42), $61, 0
    DB LOW(rNR43), $80, 0
    DB LOW(rNR44), $80, 0
    DB SOUND_END, $FF

FX_CarExplode:: ; Played for car explosions
    DB 0
    DB LOW(rNR42), $D2, 0
    DB LOW(rNR43), $90, 0
    DB LOW(rNR44), $80, 0
    DB SOUND_END, $FF