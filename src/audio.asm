INCLUDE "hardware.inc"
INCLUDE "macros.inc"

SECTION "AudioVars", WRAM0
AudioEnableFlags:: DS 1 ; Bit 0 = Enable SFX, Bit 1 = Enable Music
MusicPlaying:: DS 1 ; 0 = No music playing, 1 = Music Playing
CurrentMusicBank:: DS 1 ; Bank index of the currently playing song

SECTION "Audio Code", ROM0

initAudio::
    ; Init sound registers
    ld a, $FF
    ldh [rAUDENA], a ; Turn on sound controller
    ldh [rAUDTERM], a ; Enable all channels
    ld a, $77
    ldh [rAUDVOL], a ; Set master volume to max

    xor a
    ld [MusicPlaying], a

    rom_bank_switch BANK("Sound FX")
    call InitFXEngine
    ret

updateAudio::
    rom_bank_switch BANK("Sound FX")
    call UpdateFXEngine
    ld a, [MusicPlaying]    ; \
    and a                   ; | Return if music isn't playing
    ret z                   ; /
    ld a, [AudioEnableFlags]    ; \
    bit 1, a                    ; | Return if music isn't enabled
    ret z                       ; /
    ld a, [CurrentMusicBank]
    ld [rROMB0], a
    call hUGE_dosound
    ret

; Input - HL = Song Descriptor Pointer
; Input - A = Song Bank Number
playSong::
    ld [rROMB0], a ; switch bank to music bank
    ld [CurrentMusicBank], a
    ld a, 1
    ld [MusicPlaying], a
    call hUGE_init
    ret

stopMusic::
    ld a, [MusicPlaying]    ; \
    and a                   ; | do nothing if music is already stopped
    ret z                   ; /
    xor a
    ld [MusicPlaying], a
    ld b, 0
    call note_cut
    inc b
    call note_cut
    inc b
    call note_cut
    inc b
    call note_cut
    ret

; Taken from hUGEDriver source.
; Cuts note on a channel.
; Input - B = Current channel ID (0 = CH1, 1 = CH2, etc.)
; Sets - A H L to garbage
note_cut:
    ld a, b
    add a
    add a
    add b ; multiply by 5
    add LOW(rAUD1ENV)
    ld l, a
    ld h, HIGH(rAUD1ENV)
    xor a
    ld [hl+], a
    ld a, b
    cp 2
    ret z ; return early if CH3-- no need to retrigger note

    ; Retrigger note
    inc l ; Not `inc hl` because H stays constant (= $FF)
    ld [hl], $FF
    ret