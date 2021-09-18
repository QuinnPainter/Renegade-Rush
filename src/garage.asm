INCLUDE "hardware.inc"
INCLUDE "macros.inc"
INCLUDE "spriteallocation.inc"
INCLUDE "charmaps.inc"

DEF GROBJ_TILE_OFFSET EQUS "((GarageObjectTilesVRAM - $8000) / 16)"
DEF GRCARSPRITE_TILE_OFFSET EQUS "((GarageCarTilesVRAM - $8000) / 16)"

DEF GARAGE_TOP_ITEM_POS EQU 112

SECTION "GarageVars", WRAM0
SelectedCar:: DS 1 ; Car the user has selected, and is currently using.
ViewedCar: DS 1 ; Car the user is currently viewing in the garage.
GarageOptionSelected: DS 1
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

    ld hl, VblankVectorRAM      ; \
    di                          ; |
    ld a, LOW(garageVblank)     ; |
    ld [hli], a                 ; | Setup VBlank vector
    ld a, HIGH(garageVblank)    ; |
    ld [hl], a                  ; |
    ei                          ; /

    ld a, %11001100 ; Swap Middle 2
    ld [SelectionPalette], a
    ld a, GARAGE_TOP_ITEM_POS ; Selection bar over "Select" option
    ld [SelBarTargetPos], a
    ld [SelBarTopLine], a
    xor a
    ld [GarageOptionSelected], a

    ld a, [SelectedCar] ; Start with the view on the selected car
    ld [ViewedCar], a   ;

    call drawCarEntry
    

GarageLoop:
    call readInput

    ; B Input
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

    ; A Input
    ld a, [newButtons]
    and PADF_A
    jp z, .noAPress
    ld a, [CurCarLockState]
    and a
    jr z, .carBuyButton ; Car is locked - cursor is over "buy"
    dec a
    jr z, .checkSelection ; Car is unlocked - need to check if we're over "select" or "upgrade"
    jr .carSelectButton ; Car is upgraded - cursor is over "select"
.checkSelection:
    ld a, [GarageOptionSelected]
    and a
    jr z, .carSelectButton
    jr .carUpgradeButton
.carSelectButton:
    ld a, [ViewedCar]
    ld hl, SelectedCar
    cp [hl]
    jp z, .noAPress ; do nothing if car is already selected
    ld [hl], a
    play_sound_effect FX_CarSelect
    call drawCarEntry
    jp .noAPress
.carBuyButton:
    ld l, CARINFO_PRICE
    jr .buyCarOrUpgrade
.carUpgradeButton:
    ld l, CARINFO_UPGRADEPRICE
.buyCarOrUpgrade:
    rom_bank_switch BANK("StarterCar Info")
    ld a, [ViewedCar]
    add HIGH(FirstCarInfo)
    ld h, a

    ld a, [MoneyAmount]     ; \
    sub [hl]                ; |
    inc l                   ; | Check if there's enough money
    ld a, [MoneyAmount + 1] ; |
    sbc [hl]                ; |
    jr c, .notEnoughMoney   ; /
    dec l
    ld a, [MoneyAmount]     ; \
    sub [hl]                ; |
    daa                     ; |
    ld [MoneyAmount], a     ; |
    inc l                   ; | Take money away
    ld a, [MoneyAmount + 1] ; |
    sbc [hl]                ; |
    daa                     ; |
    ld [MoneyAmount + 1], a ; /
    play_sound_effect FX_CarBuy
    ld hl, CurCarLockState      ; \
    inc [hl]                    ; |
    ld hl, CarLockStateArray    ; |
    ld b, 0                     ; |
    ld a, [ViewedCar]           ; | Increment lock state
    ld c, a                     ; |
    add hl, bc                  ; |
    ld a, [CurCarLockState]     ; |
    ld [hl], a                  ; /
    ld a, GARAGE_TOP_ITEM_POS       ; \
    ld [SelBarTargetPos], a         ; | Move selection to top item
    xor a                           ; |
    ld [GarageOptionSelected], a    ; /
    call drawCarEntry           ; Redraw car box
    jr .noAPress
.notEnoughMoney:
    play_sound_effect FX_CarFailBuy
    ld hl, $9DCA
    ld bc, GR_NoMoneyString1
    call LCDCopyString
    ld hl, $9DEA
    ld bc, GR_NoMoneyString2
    call LCDCopyString
    ld hl, $9E0A
    ld bc, GR_NoMoneyString3
    call LCDCopyString
.noAPress:

    ; Left / Right Inputs
    ld a, [newButtons]
    and PADF_LEFT
    jr z, .noLeftPress
    ld a, [ViewedCar]
    dec a
    bit 7, a
    jr nz, .noLeftPress
    jr .viewedCarChanged
.noLeftPress:
    ld a, [newButtons]
    and PADF_RIGHT
    jr z, .doneViewedCarChange
    ld a, [ViewedCar]
    inc a
    cp NUM_PLAYER_CARS
    jr z, .doneViewedCarChange
.viewedCarChanged:
    ld [ViewedCar], a
    play_sound_effect FX_MenuBip
    call drawCarEntry
    ld a, GARAGE_TOP_ITEM_POS
    ld [SelBarTargetPos], a
    xor a
    ld [GarageOptionSelected], a
.doneViewedCarChange:

    ; Up / Down Inputs
    ld a, [newButtons]
    and PADF_UP
    jr z, .noUpPress
    ld a, [GarageOptionSelected]
    and a
    jr z, .noUpPress
    dec a
    ld [GarageOptionSelected], a
    ld a, [SelBarTargetPos]
    sub 8
    ld [SelBarTargetPos], a
    play_sound_effect FX_MenuBip
    call drawDescriptionBox
.noUpPress:
    ld a, [newButtons]
    and PADF_DOWN
    jr z, .noDownPress
    ld b, 0
    ld a, [CurCarLockState]
    and a
    jr z, .oneMenuOption ; Car Locked - Only Buy option
    dec a
    jr z, .twoMenuOptions ; Car Unlocked - Select and Upgrade options
    jr .oneMenuOption ; Car Upgraded - Only Select option
.twoMenuOptions:
    inc b
.oneMenuOption:
    ld a, [GarageOptionSelected]
    cp b
    jr z, .noDownPress
    inc a
    ld [GarageOptionSelected], a
    ld a, [SelBarTargetPos]
    add 8
    ld [SelBarTargetPos], a
    play_sound_effect FX_MenuBip
    call drawDescriptionBox
.noDownPress:



    call updateAudio
    call selectionBarUpdate

    call waitVblank
    jp GarageLoop

; Redraw the parts of the garage screen related to the car info
; Called when opening the garage menu, and when the user changes
; selection, or upgrades a car or something.
drawCarEntry:
SETCHARMAP MainMenuCharmap
    rom_bank_switch BANK("StarterCar Info")
    ld a, [ViewedCar]               ; \
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

    ld a, [ViewedCar]       ; \
    add HIGH(FirstCarInfo)  ; |
    ld d, a                 ; |
    ld e, CARINFO_NAME1     ; |
    ld hl, $9C21            ; |
    ld c, 7                 ; | Draw name
    call LCDMemcpyFast      ; |
    ld hl, $9C41            ; |
    ld c, 7                 ; |
    call LCDMemcpyFast      ; /

    ld hl, $9C4B        ; \
    call drawStatBar    ; |
    ld hl, $9C8B        ; |
    call drawStatBar    ; | Draw stat bars
    ld hl, $9CCB        ; |
    call drawStatBar    ; |
    ld hl, $9D0B        ; |
    call drawStatBar    ; /

    ld hl, CarLockStateArray    ; \
    ld b, 0                     ; |
    ld a, [ViewedCar]           ; |
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

    call drawDescriptionBox

    ld b, GROBJ_TILE_OFFSET + 2     ; \
    ld a, [ViewedCar]               ; |
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
    ld a, [ViewedCar]               ; |
    cp NUM_PLAYER_CARS - 1          ; |
    jr nz, .rightArrowBright        ; |
    inc b                           ; |
.rightArrowBright:                  ; | Draw right arrow
:   ldh a, [rSTAT]                  ; |
    and STATF_BUSY                  ; |
    jr nz, :-                       ; |
    ld a, b                         ; |
    ld [$9CC7], a                   ; /

    ld a, [SelectedCar]             ; \
    ld hl, ViewedCar                ; |
    cp [hl]                         ; |
    jr nz, .curCarNotSelected       ; |
    ld b, GROBJ_TILE_OFFSET + 6     ; |
    jr .drawCarSelectedIcon         ; |
.curCarNotSelected:                 ; | Draw icon for selected car
    ld b, " "                       ; |
.drawCarSelectedIcon:               ; |
:   ldh a, [rSTAT]                  ; |
    and STATF_BUSY                  ; |
    jr nz, :-                       ; |
    ld a, b                         ; |
    ld [$9D47], a                   ; /

    ld a, [CurCarLockState]
    and a
    jr z, .carLockedMenu
    dec a
    jr z, .carUnlockedMenu
    ; Car Unlocked + Upgraded Menu
    ld hl, $9DC1
    ld bc, GR_SelectString
    call LCDCopyString
    ld hl, $9DE1
    ld bc, GR_BlankString
    call LCDCopyString
    jr .doneSetMenu
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

; Draw the description box under the stat bars
drawDescriptionBox:
SETCHARMAP MainMenuCharmap
    ld b, " "                   ; \
FOR N, 7                        ; |
    ld hl, $9D4A + ($20 * N)    ; |
    ld c, 9                     ; | Empty description box
    call LCDMemsetFast          ; |
ENDR                            ; /

    rom_bank_switch BANK("StarterCar Info")
    ld a, [CurCarLockState]
    and a
    jr z, .drawBuyCarBox ; Car is locked - can only buy it
    dec a
    jr z, .carUnlocked ; Car is locked - draw either description or upgrade box depending on menu selection
    jr .drawCarDescription ; Car is upgraded - can only select it
    
.carUnlocked:
    ld a, [GarageOptionSelected]
    and a
    jr z, .drawCarDescription
    jr .drawBuyUpgradeBox

.drawBuyCarBox:
    ld l, CARINFO_PRICE
    jr .drawBuyBox
.drawBuyUpgradeBox:
    ld l, CARINFO_UPGRADEPRICE
.drawBuyBox:
    ld a, [ViewedCar]       ; \
    add HIGH(FirstCarInfo)  ; |
    ld h, a                 ; | BC = Car Price
    ld a, [hli]             ; |
    ld b, [hl]              ; |
    ld c, a                 ; /
    ld hl, $9DAE        ; Draw car price
    call drawPrice      ;
    ld hl, MoneyAmount      ; \
    ld a, [hli]             ; |
    ld b, [hl]              ; | Draw player balance
    ld c, a                 ; |
    ld hl, $9D6E            ; |
    call drawPrice          ; /

    ld a, [GarageOptionSelected]    ; \
    ld bc, GR_BalanceString         ; |
    ld hl, $9D4A                    ; |
    call LCDCopyString              ; | Draw "Cost" and "Balance" strings
    ld bc, GR_CostString            ; |
    ld hl, $9D8A                    ; |
    call LCDCopyString              ; /
    ret

.drawCarDescription:
    ld a, [ViewedCar]
    add HIGH(FirstCarInfo)
    ld d, a
    ld e, CARINFO_DESC
FOR N, 7                        ; \
    ld hl, $9D4A + ($20 * N)    ; |
    ld c, 9                     ; | Draw description
    call LCDMemcpyFast          ; |
ENDR                            ; /
    ret

; Draw one price value
; Input - BC = BCD Price to draw
; Input - HL = Screen address to draw to
SETCHARMAP MainMenuCharmap
drawPrice:
    push hl
    ld hl, Scratchpad

    ld a, b
    and $F0
    jr nz, .firstCharDollar
    ld a, " "
    ld [hli], a
    ld a, b
    and $0F
    jr nz, .secondCharDollar
    ld a, " "
    ld [hli], a
    ld a, c
    and $F0
    jr nz, .thirdCharDollar
    ld a, " "
    ld [hli], a
    jr .fourthCharDollar
.firstCharDollar:
    ld a, "$"
    ld [hli], a
    jr .firstChar
.secondCharDollar:
    ld a, "$"
    ld [hli], a
    jr .secondChar
.thirdCharDollar:
    ld a, "$"
    ld [hli], a
    jr .thirdChar
.fourthCharDollar:
    ld a, "$"
    ld [hli], a
    jr .fourthChar
.firstChar:
    ld a, b
    and $F0
    swap a
    add "0"
    ld [hli], a
.secondChar:
    ld a, b
    and $0F
    add "0"
    ld [hli], a
.thirdChar:
    ld a, c
    and $F0
    swap a
    add "0"
    ld [hli], a
.fourthChar:
    ld a, c
    and $0F
    add "0"
    ld [hli], a

    pop hl
    ld de, Scratchpad
    ld c, 5
    call LCDMemcpyFast
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