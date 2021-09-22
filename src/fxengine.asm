INCLUDE "hardware.inc"

; Sound array header:
; Byte 1 = FX Channel to play on (NOT the same as hardware audio channel!) (0 or 1)
; Byte 2 = Starting Sound Priority

; Format of sound array entries:
; Byte 1 = Command
; FF = Stop Sound
; FE = Change Priority
; FD = Change CH1 Pan
; FC = Change CH2 Pan
; FB = Change CH3 Pan
; FA = Change CH4 Pan
; F9 = Set Music Mute
; Everything else = Set Register

; Byte 2 = Command Parameter
; for Change Priority, this is the priority number
; for Set Register, this is the value the reg gets set to
; for Set Music Mute, top 4 bits are sound channel (0-3) and bottom 4 are if the music should mute (1) or unmute (0)

; Byte 3 = Frame Wait
; Number of frames to wait before next command

MACRO PLAY_FX
DEF FX_ADDR\@ EQUS "\1"
DEF FX_WAIT_TIME\@ EQUS "\2"
DEF FX_PLAYING\@ EQUS "\3"
DEF FX_PRIORITY\@ EQUS "\4"
    ld a, [FX_PLAYING\@]    ; \
    and a                   ; | skip priority check if no sound is playing
    jr z, .setFX\@          ; /

    ld a, [FX_PRIORITY\@]
    ld b, a
    ld a, [hl]
    cp b ; c unset if FXPriority <= new fx priority
    jr c, .donePlay\@ ; new fx priority < FXPriority, so don't play anything

.setFX\@:
    ld a, [hli]
    ld [FX_PRIORITY\@], a   ; set new FXPriority
    ld a, l                 ; \
    ld [FX_ADDR\@], a       ; | set new FXAddr
    ld a, h                 ; |
    ld [FX_ADDR\@ + 1], a   ; /
    ld a, 1
    ld [FX_WAIT_TIME\@], a  ; FXWaitTime = 1
    ld [FX_PLAYING\@], a   ; FXPlaying = 1
.donePlay\@:
PURGE FX_ADDR\@
PURGE FX_WAIT_TIME\@
PURGE FX_PLAYING\@
PURGE FX_PRIORITY\@
ENDM

MACRO UPDATE_FX_CHANNEL
DEF FX_ADDR\@ EQUS "\1"
DEF FX_WAIT_TIME\@ EQUS "\2"
DEF FX_PLAYING\@ EQUS "\3"
DEF FX_PRIORITY\@ EQUS "\4"
    ; Check if a sound is playing
    ld a, [FX_PLAYING\@]
    and a
    jp z, .doneUpdateChannel\@ ; no fx playing
    ; Update remaining wait time
    ld hl, FX_WAIT_TIME\@
    dec [hl]
    jp nz, .doneUpdateChannel\@ ; if wait time is nonzero, don't play any effect
.processCommand\@:
    ld hl, FX_ADDR\@     ; \
    ld a, [hli]          ; | Load address stored in FXAddr
    ld h, [hl]           ; | into HL
    ld l, a              ; /
    ld a, [hli]          ; A = Command byte
    ld b, a
    inc b ; cp $FF
    jr z, .stopSound\@
    inc b ; cp $FE
    jr z, .changePriority\@
    inc b ; cp $FD
    jr z, .ch1Pan\@
    inc b ; cp $FC
    jr z, .ch2Pan\@
    inc b ; cp $FB
    jr z, .ch3Pan\@
    inc b ; cp $FA
    jr z, .ch4Pan\@
    inc b ; cp $F9
    jr z, .musicMute\@
    ; Set Register command
    ld c, a     ; C = Pointer to sound register
    ld a, [hli] ; A = Command Parameter
    ld [$FF00+C], a ; Set register
    jr .doneProcessCommand\@
.stopSound\@:
    xor a
    ld [FX_PLAYING\@], a
    jr .doneUpdateChannel\@ ; don't bother doing any more processing, sound is over
.changePriority\@:
    ld a, [hli] ; A = Command Parameter
    ld [FX_PRIORITY\@], a
    jr .doneProcessCommand\@
.ch1Pan\@:
    ldh a, [rNR51]
    and %11101110
    or [hl]
    inc hl
    ldh [rNR51], a
    jr .doneProcessCommand\@
.ch2Pan\@:
    ldh a, [rNR51]
    and %11011101
    or [hl]
    inc hl
    ldh [rNR51], a
    jr .doneProcessCommand\@
.ch3Pan\@:
    ldh a, [rNR51]
    and %10111011
    or [hl]
    inc hl
    ldh [rNR51], a
    jr .doneProcessCommand\@
.ch4Pan\@:
    ldh a, [rNR51]
    and %01110111
    or [hl]
    inc hl
    ldh [rNR51], a
    jr .doneProcessCommand\@
.musicMute\@:
    ld a, [hli]
    ld b, a
    and $0F
    ld c, a
    ld a, b
    swap a
    and $0F
    ld b, a
    push hl
    call hUGE_mute_channel
    pop hl
.doneProcessCommand\@:
    ld a, [hli] ; A = Frames to wait
    and a
    ld [FX_WAIT_TIME\@], a
    ld a, l                 ; \
    ld [FX_ADDR\@], a       ; | Write back new FXAddr
    ld a, h                 ; |
    ld [FX_ADDR\@ + 1], a   ; /
    jr z, .processCommand\@ ; If frames is 0, process another command
.doneUpdateChannel\@:
PURGE FX_ADDR\@
PURGE FX_WAIT_TIME\@
PURGE FX_PLAYING\@
PURGE FX_PRIORITY\@
ENDM


SECTION "FX Engine RAM", WRAM0
FXAddr1: DS 2       ; Address of the current position in the command array
FXWaitTime1: DS 1   ; Number of frames left to wait until next command
FXPlaying1: DS 1    ; Is a sound effect playing? 0 or 1
FXPriority1: DS 1   ; Current sound priority. Higher priority takes precedence
FXAddr2: DS 2
FXWaitTime2: DS 1
FXPlaying2: DS 1
FXPriority2: DS 1

SECTION FRAGMENT "Sound FX", ROMX ; BANKED CODE - MAKE SURE TO BANKSWITCH BEFORE USE

; Initialise when program starts
; Sets - A to 0
InitFXEngine::
    xor a
    ld [FXPlaying1], a
    ld [FXPlaying2], a
    ret

; Start playing a sound
; Input - HL = Starting address of sound data
; Sets - A B H L to garbage
PlayNewFX::
    ld a, [hli]
    and a
    jr nz, .playChannel2
    PLAY_FX FXAddr1, FXWaitTime1, FXPlaying1, FXPriority1
    ret
.playChannel2:
    PLAY_FX FXAddr2, FXWaitTime2, FXPlaying2, FXPriority2
    ret

; Update the current sound effect
; Run this once every frame
; Sets - A B C E H L to garbage
UpdateFXEngine::
    UPDATE_FX_CHANNEL FXAddr1, FXWaitTime1, FXPlaying1, FXPriority1
    UPDATE_FX_CHANNEL FXAddr2, FXWaitTime2, FXPlaying2, FXPriority2
    ret