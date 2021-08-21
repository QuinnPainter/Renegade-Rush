; Sound array header:
; Byte 1 = Starting Sound Priority

; Format of sound array entries:
; Byte 1 = Command
; FF = Stop Sound (MUST HAVE NONZERO COMMAND PARAMETER ATTRIBUTE, or will continue playing junk)
; FE = Change Priority
; Everything else = Set Register

; Byte 2 = Command Parameter
; for Change Priority, this is the priority number
; for Set Register, this is the value the reg gets set to

; Byte 3 = Frame Wait
; Number of frames to wait before next command

; todo - support for multiple sounds on different channels playing at once?

SECTION "FX Engine RAM", WRAM0
FXAddr: DS 2       ; Address of the current position in the command array
FXWaitTime: DS 1   ; Number of frames left to wait until next command
FXPlaying: DS 1    ; Is a sound effect playing? 0 or 1
FXPriority: DS 1   ; Current sound priority. Higher priority takes precedence

SECTION FRAGMENT "Sound FX", ROMX ; BANKED CODE - MAKE SURE TO BANKSWITCH BEFORE USE

; Initialise when program starts
; Sets - A to 0
InitFXEngine::
    xor a
    ld [FXPlaying], a
    ret

; Start playing a sound
; Input - HL = Starting address of sound data
; Sets - A B H L to garbage
PlayNewFX::
    ld a, [FXPlaying] ; \
    and a             ; | skip priority check if no sound is playing
    jr z, .setFX      ; /

    ld a, [FXPriority]
    ld b, a
    ld a, [hl]
    cp b ; c unset if FXPriority <= new fx priority
    ret c ; new fx priority < FXPriority, so don't play anything

.setFX:
    ld a, [hli]
    ld [FXPriority], a  ; set new FXPriority
    ld a, l             ; \
    ld [FXAddr], a      ; | set new FXAddr
    ld a, h             ; |
    ld [FXAddr + 1], a  ; /
    ld a, 1
    ld [FXWaitTime], a  ; FXWaitTime = 1
    ld [FXPlaying], a   ; FXPlaying = 1
    ret

; Update the current sound effect
; Run this once every frame
; Sets - A B C H L to garbage
UpdateFXEngine::
    ; Check if a sound is playing
    ld a, [FXPlaying]
    and a
    ret z ; no fx playing
    ; Update remaining wait time
    ld hl, FXWaitTime
    dec [hl]
    ret nz ; if wait time is nonzero, don't play any effect
.processCommand:
    ld hl, FXAddr        ; \
    ld a, [hli]          ; | Load address stored in FXAddr
    ld h, [hl]           ; | into HL
    ld l, a              ; /
    ld a, [hli]          ; A = Command byte
    cp $FF
    jr z, .stopSound
    cp $FE
    jr z, .changePriority
    ; Set Register command
    ld c, a     ; BC = Pointer to sound register
    ld b, $FF   ;
    ld a, [hli] ; A = Command Parameter
    ld [bc], a  ; Set register
    jr .doneProcessCommand
.stopSound: ; For Stop Sound, HL is not incremented, so the Command Parameter is treated as Frame Wait
    xor a
    ld [FXPlaying], a
    jr .doneProcessCommand
.changePriority:
    ld a, [hli] ; A = Command Parameter
    ld [FXPriority], a
.doneProcessCommand:
    ld a, [hli] ; A = Frames to wait
    and a
    ld [FXWaitTime], a
    ld a, l             ; \
    ld [FXAddr], a      ; | Write back new FXAddr
    ld a, h             ; |
    ld [FXAddr + 1], a  ; /
    jr z, .processCommand ; If frames is 0, process another command
    ret