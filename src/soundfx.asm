INCLUDE "hardware.inc"
INCLUDE "sound.inc"

DEF SOUND_END EQU $FF
DEF CHANGE_PRIORITY EQU $FE
DEF PAN_CH1 EQU $FD
DEF PAN_CH2 EQU $FC
DEF PAN_CH3 EQU $FB
DEF PAN_CH4 EQU $FA

DEF AUDHIGH_NO_RESTART EQU 0 ; missing from hardware.inc (counterpart to AUDHIGH_RESTART)
DEF NOISE_WIDTH_15 EQU %00000000
DEF NOISE_WIDTH_7 EQU %00001000

; --- Channel 2 ---

; \1 = Duty (use the AUDLEN_DUTY definitions from hardware.inc)
; \2 = Sound Length (0-63)
; \3 = Frame Wait (0-255)
MACRO CH2_LENGTH_DUTY
    DB LOW(rNR21), \1 | \2, \3
ENDM

; \1 = Initial Volume (0-$F)
; \2 = Envelope Direction (use the AUDENV definitions from hardware.inc)
; \3 = Number of envelope sweep (0-7)
; \4 = Frame Wait (0-255)
MACRO CH2_VOLENV
    DB LOW(rNR22), (\1 << 4) | \2 | \3, \4
ENDM

; \1 = Frequency (use the NOTE definitions)
; \2 = Stop sound after length expires (use the AUDHIGH_LENGTH defs from hardware.inc)
; \3 = If sound should be restarted (use the AUDHIGH defs)
; \4 = Number of frames to wait after effect (0-255)
MACRO CH2_FREQ
    DB LOW(rNR23), LOW(\1), 0
    DB LOW(rNR24), HIGH(\1) | \2 | \3, \4
ENDM

; --- Channel 4 ---

; \1 = Sound Length (0-63)
; \2 = Frame Wait (0-255)
MACRO CH4_LENGTH
    DB LOW(rNR41), \1, \2
ENDM

; \1 = Initial Volume (0-$F)
; \2 = Envelope Direction (use the AUDENV definitions from hardware.inc)
; \3 = Number of envelope sweep (0-7)
; \4 = Frame Wait (0-255)
MACRO CH4_VOLENV
    DB LOW(rNR42), (\1 << 4) | \2 | \3, \4
ENDM

; \1 = Counter Width (use the NOISE_WIDTH defs)
; \2 = Shift Clock Frequency (0-15)
; \3 = Frequency Dividing Ratio (0-7)
; \4 = Frame Wait (0-255)
MACRO CH4_POLYCT
    DB LOW(rNR43), \1 | (\2 << 4) | \3, \4
ENDM

; \1 = Stop sound after length expires (use the AUDHIGH_LENGTH defs from hardware.inc)
; \2 = If sound should be restarted (use the AUDHIGH defs)
; \3 = Frame Wait (0-255)
MACRO CH4_RESTART
    DB LOW(rNR44), \1 | \2, \3
ENDM

SECTION FRAGMENT "Sound FX", ROMX

; https://daid.github.io/gbsfx-studio/

FX_ShortCrash:: ; (CH4) Played for small "bumps" between cars
    DB 0 ; Starting priority byte
    CH4_VOLENV $6, AUDENV_DOWN, 1, 0
    CH4_POLYCT NOISE_WIDTH_15, $8, 0, 0
    CH4_RESTART AUDHIGH_LENGTH_OFF, AUDHIGH_RESTART, 0
    DB SOUND_END

FX_CarExplode:: ; (CH4) Played for car explosions
    DB 0
    CH4_VOLENV $D, AUDENV_DOWN, 2, 0
    CH4_POLYCT NOISE_WIDTH_15, $9, 0, 0
    CH4_RESTART AUDHIGH_LENGTH_OFF, AUDHIGH_RESTART, 0
    DB SOUND_END

FX_MenuBip:: ; (CH2) The small bip when moving between menu items
    DB 0
    CH2_LENGTH_DUTY AUDLEN_DUTY_12_5, 0, 0
    CH2_VOLENV $8, AUDENV_DOWN, 1, 0
    CH2_FREQ NOTE_A_3, AUDHIGH_LENGTH_OFF, AUDHIGH_RESTART, 0
    DB SOUND_END

FX_Pause:: ; (CH2) Played when the pause menu is opened
    DB 0
    CH2_LENGTH_DUTY AUDLEN_DUTY_50, 0, 0
    CH2_VOLENV $F, AUDENV_DOWN, 1, 0
    CH2_FREQ NOTE_C_3, AUDHIGH_LENGTH_OFF, AUDHIGH_RESTART, 3
    CH2_FREQ NOTE_D_3, AUDHIGH_LENGTH_OFF, AUDHIGH_RESTART, 3
    CH2_FREQ NOTE_F_3, AUDHIGH_LENGTH_OFF, AUDHIGH_RESTART, 0
    DB SOUND_END

FX_Unpause:: ; (CH2) Played when the pause menu is closed
    DB 0
    CH2_LENGTH_DUTY AUDLEN_DUTY_50, 0, 0
    CH2_VOLENV $F, AUDENV_DOWN, 1, 0
    CH2_FREQ NOTE_F_3, AUDHIGH_LENGTH_OFF, AUDHIGH_RESTART, 3
    CH2_FREQ NOTE_D_3, AUDHIGH_LENGTH_OFF, AUDHIGH_RESTART, 3
    CH2_FREQ NOTE_C_3, AUDHIGH_LENGTH_OFF, AUDHIGH_RESTART, 0
    DB SOUND_END