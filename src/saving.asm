INCLUDE "hardware.inc"
INCLUDE "macros.inc"

SECTION "SaveVerifyString", ROM0
SaveVerifyString:
DB $52, $4e, $47, $44, $52, $55, $53, $48, $53, $41, $56, $45 ; RNGDRUSHSAVE
SaveVerifyStringEnd:

SECTION "SramInitialState", ROM0
SramInitialState:
DB $00, $00 ; MoneySRAM
DB %11 ; AudioEnableFlagsSRAM
SramInitialStateEnd:

RSSET _SRAM
DEF SaveVerifyStringSRAM RB (SaveVerifyStringEnd - SaveVerifyString)
DEF MoneySRAM RB 2
DEF AudioEnableFlagsSRAM RB 1

SECTION "SavingCode", ROM0

; Save current game state to cart SRAM
; Sets - HL to garbage
; Sets - A to 0
saveGame::
    ld a, $0A       ; Enable SRAM
    ld [rRAMG], a   ;
    xor a           ; Go to SRAM Bank 0
    ld [rRAMB], a   ;

    ld hl, MoneySRAM
    ld a, [MoneyAmount]
    ld [hli], a
    ld a, [MoneyAmount + 1]
    ld [hli], a
    ld a, [AudioEnableFlags]
    ld [hli], a

    xor a           ; Disable SRAM
    ld [rRAMG], a   ;
    ret

; Load game state from cart SRAM
; Input - C = 0 to load normally, 1 to reset savegame
; Sets - A D E H L to garbage
; Sets - C = 0 if load successful, 1 if data is invalid
loadGameSave::
    ld a, $0A       ; Enable SRAM
    ld [rRAMG], a   ;
    xor a           ; Go to SRAM Bank 0
    ld [rRAMB], a   ;
    ld a, c                     ; \
    and a                       ; | if resetting savegame, skip to invalid state
    jr nz, .verifyStringInvalid ; /
    ld de, SaveVerifyString
    ld hl, SaveVerifyStringSRAM
    ld c, SaveVerifyStringEnd - SaveVerifyString
.checkVerifyStringLoop:
    ld a, [de]
    cp [hl]
    jr nz, .verifyStringInvalid
    inc hl
    inc de
    dec c
    jr nz, .checkVerifyStringLoop
    ld c, 0 ; Return 0 - load successful
    jr .verifyStringValid
.verifyStringInvalid:
    call initialiseSaveRAM
    ld hl, SaveVerifyStringSRAM + (SaveVerifyStringEnd - SaveVerifyString)
    ld c, 1 ; Return 1 - data invalid / new save created
.verifyStringValid:

    ld a, [hli]
    ld [MoneyAmount], a
    ld a, [hli]
    ld [MoneyAmount + 1], a
    ld a, [hli]
    ld [AudioEnableFlags], a

    xor a           ; Disable SRAM
    ld [rRAMG], a   ;
    ret

; Setup the initial state of Save RAM
; Assumes SRAM is already open
initialiseSaveRAM:
    ld hl, SaveVerifyStringSRAM
    ld de, SaveVerifyString
    ld c, SaveVerifyStringEnd - SaveVerifyString
    rst memcpyFast
    ld de, SramInitialState
    ld c, SramInitialStateEnd - SramInitialState
    rst memcpyFast
    ret