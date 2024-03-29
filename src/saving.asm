INCLUDE "hardware.inc"
INCLUDE "macros.inc"
INCLUDE "spriteallocation.inc"

SECTION "SaveVerifyString", ROM0
SaveVerifyString:
DB $52, $4e, $47, $44, $52, $55, $53, $48, $53, $41, $56, $45 ; RNGDRUSHSAVE
SaveVerifyStringEnd:

SECTION "SramInitialState", ROM0
SramInitialState:
DB $00, $00 ; MoneySRAM
DB %11 ; AudioEnableFlagsSRAM
DB 0, 0, 0 ; BestDistanceSRAM
DB 0 ; SelectedCarSRAM
DB 1 ; StarterCar Unlocked
DS NUM_PLAYER_CARS, 0 ; Other Cars Locked
SramInitialStateEnd:

RSSET _SRAM
DEF SaveVerifyStringSRAM RB (SaveVerifyStringEnd - SaveVerifyString)
DEF MoneySRAM RB 2
DEF AudioEnableFlagsSRAM RB 1
DEF BestDistanceSRAM RB 3
DEF SelectedCarSRAM RB 1
DEF CarLockStateArraySRAM RB NUM_PLAYER_CARS

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
    ld a, [BestDistance]
    ld [hli], a
    ld a, [BestDistance + 1]
    ld [hli], a
    ld a, [BestDistance + 2]
    ld [hli], a
    ld a, [SelectedCar]
    ld [hli], a
    ld de, CarLockStateArray
    ld c, NUM_PLAYER_CARS
    rst memcpyFast

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
    ld a, [hli]
    ld [BestDistance], a
    ld a, [hli]
    ld [BestDistance + 1], a
    ld a, [hli]
    ld [BestDistance + 2], a
    ld a, [hli]
    ld [SelectedCar], a
    ld d, h
    ld e, l
    ld hl, CarLockStateArray
    ld c, NUM_PLAYER_CARS
    rst memcpyFast

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