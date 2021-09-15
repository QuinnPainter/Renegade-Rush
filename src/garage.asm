INCLUDE "hardware.inc"
INCLUDE "macros.inc"

DEF GROBJ_TILE_OFFSET EQUS "((GarageObjectTilesVRAM - $8000) / 16)"

SECTION "GarageVars", WRAM0
SelectedCar:: DS 1

SECTION "GarageCode", ROM0

openGarage::
    rom_bank_switch BANK("GarageTilemap")
    ld hl, $9C00                        ; \
    ld bc, STARTOF("GarageTilemap")     ; | Fill secondary BG map with garage background map
    ld a, 18                            ; |
    call LCDScreenTilemapCopy           ; /
    ld hl, $9C2A
    ld bc, GR_SpeedString
    call LCDCopyString
    ld hl, $9C6A
    ld bc, GR_WeightString
    call LCDCopyString
    ld hl, $9CAA
    ld bc, GR_MissileString
    call LCDCopyString
    ld hl, $9CEA
    ld bc, GR_SpecialString
    call LCDCopyString
    ldh a, [rLCDC]                          ; \
    or a, LCDCF_BG9C00 | LCDCF_BG8000       ; | switch to secondary BG map & secondary tileset
    ldh [rLCDC], a                          ; /

    call drawCarEntry
    

GarageLoop:
    call readInput

    call updateAudio

    call waitVblank
    jp GarageLoop

; Redraw the parts of the garage screen related to the car info
; Called when opening the garage menu, and when the user changes
; selection, or upgrades a car or something.
drawCarEntry:
    rom_bank_switch BANK("Car Info")
    ld a, [SelectedCar] ; \
    add HIGH(CarInfo)   ; |
    ld d, a             ; |
    ld e, CARINFO_NAME1 ; |
    ld hl, $9C21        ; |
    ld c, 7             ; | Draw name
    call LCDMemcpyFast  ; |
    ld hl, $9C41        ; |
    ld c, 7             ; |
    call LCDMemcpyFast  ; /
FOR N, 7                        ; \
    ld hl, $9D4A + ($20 * N)    ; |
    ld c, 9                     ; | Draw description
    call LCDMemcpyFast          ; |
ENDR                            ; /
    ld hl, $9C4B        ; \
    call drawStatBar    ; |
    ld hl, $9C8B        ; |
    call drawStatBar    ; | Draw stat bars
    ld hl, $9CCB        ; |
    call drawStatBar    ; |
    ld hl, $9D0B        ; |
    call drawStatBar    ; /
:   ldh a, [rSTAT]                  ;
    and STATF_BUSY                  ;
    jr nz, :-                       ;
    ld a, GROBJ_TILE_OFFSET + 2     ;
    ld [$9CC1], a                   ;
:   ldh a, [rSTAT]                  ; Draw left / right arrows
    and STATF_BUSY                  ;
    jr nz, :-                       ;
    ld a, GROBJ_TILE_OFFSET + 3     ;
    ld [$9CC7], a                   ;
    ret

; Draw one of the bars representing the car's stats
; Input - [DE] = "Charge level" of the bar
; Input - HL   = VRAM Address of the start of the bar
; Sets  - BC to garbage
; Sets  - DE += 1
drawStatBar:
    ld a, [de]
    inc de
    dec a
    ld b, a
    ld c, 8
.barLp:
    ldh a, [rSTAT]          ; \
    and STATF_BUSY          ; | Wait for VRAM to be ready
    jr nz, .barLp           ; /
    ld a, b
    rla     ; put top bit (negative) into carry
    ld a, GROBJ_TILE_OFFSET
    adc 0   ; switch tile type if carry set
    ld [hli], a
    dec b
    dec c
    jr nz, .barLp
    ret