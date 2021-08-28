INCLUDE "hardware.inc"

DEF SOUND_END EQU $FF
DEF CHANGE_PRIORITY EQU $FE

SECTION FRAGMENT "Sound FX", ROMX

; https://daid.github.io/gbsfx-studio/
; http://www.devrs.com/gb/files/sndtab.html

FX_ShortCrash:: ; (CH4) Played for small "bumps" between cars
    DB 0 ; Starting priority byte
    DB LOW(rNR42), $61, 0
    DB LOW(rNR43), $80, 0
    DB LOW(rNR44), $80, 0
    DB SOUND_END

FX_CarExplode:: ; (CH4) Played for car explosions
    DB 0
    DB LOW(rNR42), $D2, 0
    DB LOW(rNR43), $90, 0
    DB LOW(rNR44), $80, 0
    DB SOUND_END

FX_MenuBip:: ; (CH2) The small bip when moving between menu items
    DB 0
    DB LOW(rNR21), $00, 0
    DB LOW(rNR22), $81, 0
    DB LOW(rNR23), $84, 0
    DB LOW(rNR24), $83, 0
    DB SOUND_END

FX_Pause:: ; (CH2) Played when the pause menu is opened
    DB 0
    DB SOUND_END