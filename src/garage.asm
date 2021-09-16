INCLUDE "hardware.inc"
INCLUDE "macros.inc"
INCLUDE "spriteallocation.inc"

DEF GROBJ_TILE_OFFSET EQUS "((GarageObjectTilesVRAM - $8000) / 16)"
DEF GRCARSPRITE_TILE_OFFSET EQUS "((GarageCarTilesVRAM - $8000) / 16)"

SECTION "GarageVars", WRAM0
SelectedCar:: DS 1
CurCarLockState: DS 1 ; Selected car's entry in CarLockStateArray
CarLockStateArray:: DS NUM_PLAYER_CARS ; In each entry 0 = Locked, 1 = Unlocked, 2 = Upgraded

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
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINOFF | LCDCF_BG8000 \  ; switch to secondary BG map and tileset
    | LCDCF_BG9C00 | LCDCF_OBJ16 | LCDCF_OBJON | LCDCF_BGON         ; and setup sprites
    ldh [rLCDC], a

    ld a, GRCARSPRITE_TILE_OFFSET                                                       ; \
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (GARAGE_CAR_SPRITE + 0)) + OAMA_TILEID], a   ; |
    add 2                                                                               ; |
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (GARAGE_CAR_SPRITE + 1)) + OAMA_TILEID], a   ; | Car sprite tiles
    add 2                                                                               ; |
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (GARAGE_CAR_SPRITE + 2)) + OAMA_TILEID], a   ; |
    add 2                                                                               ; |
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (GARAGE_CAR_SPRITE + 3)) + OAMA_TILEID], a   ; /

    xor a                                                                               ; \
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (GARAGE_CAR_SPRITE + 0)) + OAMA_FLAGS], a    ; |
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (GARAGE_CAR_SPRITE + 1)) + OAMA_FLAGS], a    ; | Car sprite flags
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (GARAGE_CAR_SPRITE + 2)) + OAMA_FLAGS], a    ; |
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (GARAGE_CAR_SPRITE + 3)) + OAMA_FLAGS], a    ; /

    ld a, 28 + 8                                                                    ; \
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (GARAGE_CAR_SPRITE + 0)) + OAMA_X], a    ; |
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (GARAGE_CAR_SPRITE + 2)) + OAMA_X], a    ; |
    add 8                                                                           ; | Car sprite X pos
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (GARAGE_CAR_SPRITE + 1)) + OAMA_X], a    ; |
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (GARAGE_CAR_SPRITE + 3)) + OAMA_X], a    ; /

    ld a, 40 + 16                                                                   ; \
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (GARAGE_CAR_SPRITE + 0)) + OAMA_Y], a    ; |
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (GARAGE_CAR_SPRITE + 1)) + OAMA_Y], a    ; |
    add 16                                                                          ; | Car sprite Y pos
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (GARAGE_CAR_SPRITE + 2)) + OAMA_Y], a    ; |
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (GARAGE_CAR_SPRITE + 3)) + OAMA_Y], a    ; /

    ld hl, VblankVectorRAM
    di
    ld a, LOW(garageVblank)
    ld [hli], a
    ld a, HIGH(garageVblank)
    ld [hl], a
    ei

    ld a, %11001100 ; Swap Middle 2
    ld [SelectionPalette], a
    ld a, 112 ; Selection bar over "Select" option
    ld [SelBarTargetPos], a
    ld [SelBarTopLine], a

    call drawCarEntry
    

GarageLoop:
    call readInput

    ld a, [newButtons]
    and PADF_B
    jr z, .noBPress
    ; Return to main menu
    call saveGame ; save the new stuff
    ld a, %11100100 ; Init background palette
	ldh [rBGP], a
    ld a, %00100111 ; Palette for selection bar
    ld [SelectionPalette], a
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINOFF | LCDCF_BG8800 \
    | LCDCF_BG9800 | LCDCF_OBJ8 | LCDCF_OBJOFF | LCDCF_BGON
    ldh [rLCDC], a ; Screen settings
    di
    ld hl, VblankVectorRAM
    ld a, LOW(MainMenuVBlank)
    ld [hli], a
    ld a, HIGH(MainMenuVBlank)
    ld [hl], a
    ei
    ld a, MENU_TOP_ITEM_POS + 8     ; put selection over "Garage"
    ld [SelBarTopLine], a           ;
    ld [SelBarTargetPos], a         ;
    jp MainMenuLoop
.noBPress:

    ld a, [newButtons]
    and PADF_LEFT
    jr z, .noLeftPress
    ld a, [SelectedCar]
    dec a
    bit 7, a
    jr nz, .noLeftPress
    ld [SelectedCar], a
    call drawCarEntry
.noLeftPress:
    ld a, [newButtons]
    and PADF_RIGHT
    jr z, .noRightPress
    ld a, [SelectedCar]
    inc a
    cp NUM_PLAYER_CARS
    jr z, .noRightPress
    ld [SelectedCar], a
    call drawCarEntry
.noRightPress:



    call updateAudio
    call selectionBarUpdate

    call waitVblank
    jp GarageLoop

; Redraw the parts of the garage screen related to the car info
; Called when opening the garage menu, and when the user changes
; selection, or upgrades a car or something.
drawCarEntry:
    rom_bank_switch BANK("StarterCar Info")
    ld a, [SelectedCar]             ; \
    add HIGH(FirstCarInfo)          ; |
    ld d, a                         ; |
    ld e, CARINFO_GFXADDR           ; |
    ld a, [de]  ; \                 ; |
    ld b, a     ; |                 ; | Draw car sprite
    inc e       ; | DE = GFX Addr   ; |
    ld a, [de]  ; |                 ; |
    ld d, a     ; |                 ; |
    ld e, b     ; /                 ; |
    ld hl, GarageCarTilesVRAM       ; |
    ld bc, SIZEOF("StarterCarTiles"); |
    call LCDMemcpy                  ; /

    ld a, [SelectedCar]     ; \
    add HIGH(FirstCarInfo)  ; |
    ld d, a                 ; |
    ld e, CARINFO_NAME1     ; |
    ld hl, $9C21            ; |
    ld c, 7                 ; | Draw name
    call LCDMemcpyFast      ; |
    ld hl, $9C41            ; |
    ld c, 7                 ; |
    call LCDMemcpyFast      ; /
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

    ld b, GROBJ_TILE_OFFSET + 2     ; \
    ld a, [SelectedCar]             ; |
    and a                           ; |
    jr nz, .leftArrowBright         ; |
    inc b                           ; |
.leftArrowBright:                   ; | Draw left arrow
:   ldh a, [rSTAT]                  ; |
    and STATF_BUSY                  ; |
    jr nz, :-                       ; |
    ld a, b                         ; |
    ld [$9CC1], a                   ; /

    ld b, GROBJ_TILE_OFFSET + 4     ; \
    ld a, [SelectedCar]             ; |
    cp NUM_PLAYER_CARS - 1          ; |
    jr nz, .rightArrowBright        ; |
    inc b                           ; |
.rightArrowBright:                  ; | Draw right arrow
:   ldh a, [rSTAT]                  ; |
    and STATF_BUSY                  ; |
    jr nz, :-                       ; |
    ld a, b                         ; |
    ld [$9CC7], a                   ; /

    ld hl, CarLockStateArray    ; \
    ld b, 0                     ; |
    ld a, [SelectedCar]         ; |
    ld c, a                     ; | Update the lock state
    add hl, bc                  ; |
    ld a, [hl]                  ; |
    ld [CurCarLockState], a     ; /

    and a                       ; \
    jr nz, .carUnlockedPal      ; |
    ld a, %11111111             ; |
    jr .doneSetCarPal           ; | Set car palette based on lock state
.carUnlockedPal:                ; |
    ld a, %11100100             ; |
.doneSetCarPal:                 ; |
    ldh [rOBP0], a              ; /

    ld a, [CurCarLockState]
    and a
    jr z, .carLockedMenu
    dec a
    jr z, .carUnlockedMenu
    ; Car Unlocked + Upgraded Menu (todo)
.carLockedMenu:
    ld hl, $9DC1
    ld bc, GR_BuyString
    call LCDCopyString
    ld hl, $9DE1
    ld bc, GR_BlankString
    call LCDCopyString
    jr .doneSetMenu
.carUnlockedMenu:
    ld hl, $9DC1
    ld bc, GR_SelectString
    call LCDCopyString
    ld hl, $9DE1
    ld bc, GR_UpgradeString
    call LCDCopyString
.doneSetMenu:
    ret

; Draw one of the bars representing the car's stats
; Input - [DE] = "Charge level" of the bar
; Input - HL   = VRAM Address of the start of the bar
; Sets  - BC to garbage
; Sets  - DE += 1
drawStatBar:
    ld a, [de]
    inc de
    push de
    dec a
    ld b, a
    ld c, 8
.barLp:
    ld a, b
    rla     ; put top bit (negative) into carry
    ld a, GROBJ_TILE_OFFSET
    adc 0   ; switch tile type if carry set
    ld d, a
:   ldh a, [rSTAT]          ; \
    and STATF_BUSY          ; | Wait for VRAM to be ready
    jr nz, :-               ; /
    ld a, d
    ld [hli], a
    dec b
    dec c
    jr nz, .barLp
    pop de
    ret


garageVblank:
	ld a, %11100100
	ldh [rBGP], a

    call DMARoutineHRAM

    ld hl, LCDIntVectorRAM
    ld a, LOW(garageLYC)
    ld [hli], a
    ld a, HIGH(garageLYC)
    ld [hl], a
    ld a, 96 - 1
    ld [rLYC], a
    jp VblankEnd

; Triggers near the top of the Buy / Select menu box, to set up the selection bar palette effect
garageLYC:
    ld a, %11110000 ; 0 and 1 = Lightest, 2 and 3 = Darkest
    ldh [rBGP], a

    call selectionBarSetupTopInt
    jp LCDIntEnd