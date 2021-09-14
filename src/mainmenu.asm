INCLUDE "hardware.inc"
INCLUDE "macros.inc"

DEF START_FLASH_FRAMES EQU 40 ; Speed of the "Press Start" flash animation
DEF START_FAST_FLASH_FRAMES EQU 10 ; Speed of the flash animation after Start has been pressed
DEF START_FAST_FLASH_TIME EQU 80 ; Number of frames to wait after start press before going to main menu
DEF MENU_TOP_ITEM_POS EQU 88 ; Y position of the top item in the main menu
DEF SETTINGS_TOP_ITEM_POS EQU 64

SECTION "MainMenuVars", WRAM0
PressStartFlashState: DS 1 ; 0 = Off  1 = On
PressStartFlashCtr: DS 1
MainMenuState: DS 1 ; 0 = Title Screen, 1 = Title Screen after Start press, 0 = Main Menu
MainMenuStateTimer: DS 1 ; Used to count frames for stuff relating to the main menu state
menuOptionSelected: DS 1 ; Which item is selected in the main menu (0-3)
selectionBarEnabled: DS 1
settingsOptionSelected: DS 1 ; Which item is selected in the settings menu

SECTION "MainMenuCode", ROM0

EntryPoint:: ; At this point, interrupts are already disabled from the header code

    ld sp, $E000 ; Set the stack pointer to the top of RAM to free up HRAM

    call disableLCD

    ; Initialize VRAM to 0
	ld hl, $8000
	ld bc, $A000 - $8000
	xor a
	call memset
    ; Initialize sprite buffer to 0
	ld hl, STARTOF("SpriteBuffer")
	ld c, SIZEOF("SpriteBuffer")
	ld d, 0
	rst memsetFast
    ; Copy the OAM DMA routine into HRAM
    ld hl, DMARoutineHRAM
    ld de, STARTOF("DMARoutineROM")
    ld c, SIZEOF("DMARoutineROM")
    rst memcpyFast
    ; Copy the empty sprite buffer into OAM
    call DMARoutineHRAM

    ; Init input
    ld a, PADF_START    ; act as if start is already pressed, so holding start when console boots
    ld [curButtons], a  ; doesn't go straight into the menu (this helps with random seeding)
    xor a
    ld [newButtons], a

    ; Init display registers
	ld a, %11100100 ; Init background palette
	ldh [rBGP], a
    ldh [rOBP0], a ; Init sprite palettes
	ldh [rOBP1], a
    xor a
    ld [rSCX], a
    ld [rSCY], a

    ; No, vblank has not happened yet
    xor a
    ld [HasVblankHappened], a

    ; Start up audio
    call initAudio

    ; Copy tileset into VRAM
    rom_bank_switch BANK("TitleTiles")
    ld hl, TitleTilesVRAM
    ld de, STARTOF("TitleTiles")
    ld bc, SIZEOF("TitleTiles")
    call memcpy
    rom_bank_switch BANK("TitleScreenBottomTiles")
    ld hl, TitleBottomTilesVRAM
    ld de, STARTOF("TitleScreenBottomTiles")
    ld bc, SIZEOF("TitleScreenBottomTiles")
    call memcpy
    rom_bank_switch BANK("FontTiles")
    ld hl, MainMenuFontVRAM
    ld de, STARTOF("FontTiles")
    ld bc, SIZEOF("FontTiles")
    call memcpy

    ; Copy title screen tilemap into VRAM
    rom_bank_switch BANK("TitleTilemap")
    ld hl, $9800
    ld bc, STARTOF("TitleTilemap")
    ld a, 9
    call ScreenTilemapCopy
    rom_bank_switch BANK("TitleScreenBottomTilemap")
    ld hl, $9920
    ld bc, STARTOF("TitleScreenBottomTilemap")
    ld a, 9
    call ScreenTilemapCopy

    ; Enable screen and initialise screen settings
    ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINOFF | LCDCF_BG8800 \
        | LCDCF_BG9800 | LCDCF_OBJ8 | LCDCF_OBJOFF | LCDCF_BGON
    ldh [rLCDC], a

    ; Enable LY=LYC as LCD STAT interrupt source
    ld a, STATF_LYC
    ldh [rSTAT], a
    ; Setup LYC interrupt to happen right before "Press Start" text
    ld a, 126
    ldh [rLYC], a

    ; Init VBlank vector
    ld hl, VblankVectorRAM
    ld a, LOW(TitleScreenVBlank)
    ld [hli], a
    ld a, HIGH(TitleScreenVBlank)
    ld [hl], a

    ; Init LCD interrupt vector
    ld hl, LCDIntVectorRAM
    ld a, LOW(TitleScreenLYC)
    ld [hli], a
    ld a, HIGH(TitleScreenLYC)
    ld [hl], a

    ; Initialise variables
    xor a
    ld [PressStartFlashState], a
    ld [MainMenuState], a
    inc a
    ld [PressStartFlashCtr], a

    ; Load savegame
    ld c, 0
    call loadGameSave

    ; Disable all interrupts except VBlank and LCD
	ld a, IEF_VBLANK | IEF_STAT
	ldh [rIE], a
    xor a
    ldh [rIF], a ; Discard all pending interrupts (there would normally be a VBlank pending)
    ei

TitleScreenLoop:
    call readInput

    ; Check for start button press
    ld a, [MainMenuState]   ; \
    and a                   ; | Skip start check if start has already been pressed
    jr nz, .startNotPressed ; /
    ld a, [newButtons]
    and PADF_START
    jr z, .startNotPressed
    play_sound_effect FX_TitleScreenStart
    ld hl, PressStartFlashState
    ld a, 1
    ld [hli], a ; PressStartFlashState
    ld a, START_FAST_FLASH_FRAMES
    ld [hli], a ; PressStartFlashCtr
    ld a, 1
    ld [hli], a ; MainMenuState
    ld a, START_FAST_FLASH_TIME
    ld [hl], a ; MainMenuStateTimer
    ldh a, [rDIV]       ; Seed first byte of the RNG with DIV
    ld [RandState], a   ; when "start" is pressed at title screen
.startNotPressed:

    ; Update the state timer to go into the main menu
    ld a, [MainMenuState]
    and a
    jr z, .noUpdateStateTimer
    ld hl, MainMenuStateTimer
    dec [hl]
    jr nz, .noUpdateStateTimer
    xor a ; Timer has run out, time to transition to the menu
    ld [MainMenuState], a
    ld a, $FF       ; Disable LYC
    ldh [rLYC], a   ;
    ld hl, $9920            ; \
    ld bc, $9A34 - $9920    ; | Fill bottom half of screen with blank tiles
    ld d, $CC               ; | 
    call LCDMemset          ; /
    ld hl, $9968                ; Copy menu option strings
    ld bc, MM_PlayString        
    call LCDCopyString
    ld hl, $9987
    ld bc, MM_GarageString
    call LCDCopyString
    ld hl, $99A6
    ld bc, MM_SettingsString
    call LCDCopyString
    ld hl, $99C8
    ld bc, MM_InfoString
    call LCDCopyString

    ld hl, VblankVectorRAM          ; \
    ld a, LOW(MainMenuVBlank)       ; |
    ld [hli], a                     ; | Setup main menu Vblank
    ld a, HIGH(MainMenuVBlank)      ; |
    ld [hl], a                      ; /
    xor a                           ; \
    ld [menuOptionSelected], a      ; |
    ld [SelBarTopLine + 1], a       ; | Start with top option (Play) selected
    inc a                           ; |
    ld [selectionBarEnabled], a     ; |
    ld a, MENU_TOP_ITEM_POS         ; |
    ld [SelBarTopLine], a           ; |
    ld [SelBarTargetPos], a         ; /
    ld a, $FF                       ; \
    ld [AfterSelIntLine], a         ; | Disable LYC interrupt after selection bar
    ld [AfterSelIntVec], a          ; |
    ld [AfterSelIntVec + 1], a      ; /
    jr MainMenuLoop
.noUpdateStateTimer:

    ; Update "Press Start" flashing
    ld hl, PressStartFlashCtr
    dec [hl]
    jr nz, .noUpdateFlashState
    ld a, [MainMenuState]           ; \
    and a                           ; |
    ld a, START_FLASH_FRAMES        ; | Set A to the flash frames
    jr z, .noFastFlash              ; | based on the main menu state
    ld a, START_FAST_FLASH_FRAMES   ; |
.noFastFlash:                       ; /
    ld [hld], a
    ld a, [hl] ; HL = PressStartFlashState
    xor 1
    ld [hl], a
.noUpdateFlashState:

    call updateAudio

    call waitVblank
    jp TitleScreenLoop


TitleScreenVBlank:
    ld a, %11100100 ; Set bg palette
	ldh [rBGP], a
    jp VblankEnd


TitleScreenLYC:
    ld a, [PressStartFlashState]
    and a
    jr z, .textDisabled
    ld a, %11100100
    jr .doneSetPalette
.textDisabled:
    ld a, %11111111 ; Set bg palette
.doneSetPalette:
	ldh [rBGP], a
    jp LCDIntEnd


MainMenuLoop:
    call readInput

    ; Check for A / Start button selecting the current menu option
    ld a, [newButtons]
    and PADF_A | PADF_START
    jp z, .aNotPressed
    ld a, [menuOptionSelected]
    and a
    jr z, .playSelected
    dec a
    jr z, .garageSelected
    dec a
    jr z, .settingsSelected
    ; "About" is selected
    ld hl, $9C00            ; \
    ld bc, $9E34 - $9C00    ; | Fill secondary BG map with blank tiles
    ld d, $CC               ; |
    call LCDMemset          ; /
    ld hl, $9C00
    ld de, $0020
    ld bc, INFO_Line1
.drawInfoLoop:
    call LCDCopyString
    ld a, $E0               ; \
    and l                   ; | return to beginning of line
    ld l, a                 ; /
    add hl, de              ; go to next line
    inc bc                  ; progress forward from the end-string character
    ld a, [bc]              ; value of 1 indicates the string block should end
    cp 1                    ;
    jr nz, .drawInfoLoop
    ldh a, [rLCDC]          ; \
    or a, LCDCF_BG9C00      ; | switch to secondary BG map
    ldh [rLCDC], a          ; /
    xor a
    ld [selectionBarEnabled], a
    jp AboutPageLoop

.playSelected:
    ldh a, [rDIV]           ; Seed second byte of the RNG with DIV
    ld [RandState + 1], a   ; when "Play" is selected
    jp StartGame
.garageSelected: ; todo
    jr .aNotPressed
.settingsSelected:  ; Open Settings page
    ld hl, $9C00            ; \
    ld bc, $9E34 - $9C00    ; | Fill secondary BG map with blank tiles
    ld d, $CC               ; | 
    call LCDMemset          ; /
    ld hl, $9C20
    ld bc, SP_Header
    call LCDCopyString
    ld hl, $9D00
    ld bc, SP_Back
    call LCDCopyString
    ld hl, $9D20
    ld bc, SP_SoundFX
    call LCDCopyString
    ld hl, $9D40
    ld bc, SP_Music
    call LCDCopyString
    ld hl, $9D60
    ld bc, SP_ResetSave
    call LCDCopyString
    ldh a, [rLCDC]          ; \
    or a, LCDCF_BG9C00      ; | switch to secondary BG map
    ldh [rLCDC], a          ; /
    xor a                           ; \
    ld [settingsOptionSelected], a  ; |
    ld a, SETTINGS_TOP_ITEM_POS     ; | Start with top option (Back) selected
    ld [SelBarTargetPos], a         ; /
    call drawSettingsPageToggles
    jp SettingsPageLoop
.aNotPressed:

    ; Check for up/down buttons moving the selection
    ld hl, menuOptionSelected
    ld a, [hl]                  ; \
    and a                       ; | Skip "up" check if already at the top
    jr z, .upNotPressed         ; /
    ld a, [newButtons]
    and PADF_UP
    jr z, .upNotPressed
    dec [hl]
    ld a, [SelBarTargetPos]
    sub 8
    ld [SelBarTargetPos], a
    play_sound_effect FX_MenuBip
.upNotPressed:
    ld a, [hl]                  ; \
    cp 3                        ; | Skip "down" check if already at the bottom
    jr z, .downNotPressed       ; /
    ld a, [newButtons]
    and PADF_DOWN
    jr z, .downNotPressed
    inc [hl]
    ld a, [SelBarTargetPos]
    add 8
    ld [SelBarTargetPos], a
    play_sound_effect FX_MenuBip
.downNotPressed:

    call updateAudio
    call selectionBarUpdate

    call waitVblank
    jp MainMenuLoop

MainMenuVBlank:
	ld a, %11100100 ; fix background palette if the selection bar broke it
	ldh [rBGP], a   ; is this really a great fix?

    ld a, [selectionBarEnabled]
    and a
    jp z, VblankEnd
    call selectionBarSetupTopInt
    jp VblankEnd


AboutPageLoop:
    call readInput

    ld a, [newButtons]
    and PADF_B
    jr z, .noBPress
    ldh a, [rLCDC]          ; \
    and a, ~LCDCF_BG9C00    ; | switch to primary BG map
    ldh [rLCDC], a          ; /
    ld a, 1
    ld [selectionBarEnabled], a
    jp MainMenuLoop
.noBPress:

    call updateAudio

    call waitVblank
    jr AboutPageLoop


; --- SETTINGS PAGE LOOP ---
SettingsPageLoop:
    call readInput

    ld a, [newButtons]
    and PADF_B
    jr z, .noBPress
.backSelected:
    call saveGame           ; save new settings
    ldh a, [rLCDC]          ; \
    and a, ~LCDCF_BG9C00    ; | switch to primary BG map
    ldh [rLCDC], a          ; /
    ld a, MENU_TOP_ITEM_POS + 16    ; put selection over "Settings"
    ld [SelBarTargetPos], a         ;
    jp MainMenuLoop
.noBPress:
    ld a, [newButtons]
    and PADF_A
    jp z, .aNotPressed
    ld a, [settingsOptionSelected]
    and a
    jr z, .backSelected
    dec a
    jr z, .soundFXToggleSelected
    dec a
    jr z, .musicToggleSelected
    ; Reset Save Selected
    ld hl, $9C00            ; \
    ld bc, $9E34 - $9C00    ; | Fill secondary BG map with blank tiles
    ld d, $CC               ; |
    call LCDMemset          ; /
    ld hl, $9C00
    ld de, $0020
    ld bc, RS_Line1
.drawSaveResetLoop:
    call LCDCopyString
    ld a, $E0               ; \
    and l                   ; | return to beginning of line
    ld l, a                 ; /
    add hl, de              ; go to next line
    inc bc                  ; progress forward from the end-string character
    ld a, [bc]              ; value of 1 indicates the string block should end
    cp 1                    ;
    jr nz, .drawSaveResetLoop
    xor a
    ld [selectionBarEnabled], a
    jp saveResetPageLoop
.soundFXToggleSelected:
    ld hl, AudioEnableFlags
    ld a, [hl]
    xor 1
    ld [hl], a
    call drawSettingsPageToggles
    jr .aNotPressed
.musicToggleSelected:
    ld hl, AudioEnableFlags
    ld a, [hl]
    xor %10
    ld [hl], a
    call drawSettingsPageToggles
    jr .aNotPressed
.aNotPressed:

    ; Check for up/down buttons moving the selection
    ld hl, settingsOptionSelected
    ld a, [hl]                  ; \
    and a                       ; | Skip "up" check if already at the top
    jr z, .upNotPressed         ; /
    ld a, [newButtons]
    and PADF_UP
    jr z, .upNotPressed
    dec [hl]
    ld a, [SelBarTargetPos]
    sub 8
    ld [SelBarTargetPos], a
    play_sound_effect FX_MenuBip
.upNotPressed:
    ld a, [hl]                  ; \
    cp 3                        ; | Skip "down" check if already at the bottom
    jr z, .downNotPressed       ; /
    ld a, [newButtons]
    and PADF_DOWN
    jr z, .downNotPressed
    inc [hl]
    ld a, [SelBarTargetPos]
    add 8
    ld [SelBarTargetPos], a
    play_sound_effect FX_MenuBip
.downNotPressed:

    call updateAudio
    call selectionBarUpdate

    call waitVblank
    jp SettingsPageLoop


; Draw the on/off boxes on the settings page
drawSettingsPageToggles:
    ld a, [AudioEnableFlags]
    rra
    jr nc, .sfxOff
    ld bc, SP_SelectionOn
    jr .drawSFX
.sfxOff:
    ld bc, SP_SelectionOff
.drawSFX:
    ld hl, $9D2C
    call LCDCopyString

    ld a, [AudioEnableFlags]
    bit 1, a
    jr z, .musicOff
    ld bc, SP_SelectionOn
    jr .drawMusic
.musicOff:
    ld bc, SP_SelectionOff
.drawMusic:
    ld hl, $9D4C
    jp LCDCopyString


; Save reset page loop
saveResetPageLoop:
    call readInput

    ld a, [newButtons]
    and PADF_B
    jr z, .bNotPressed
    jp EntryPoint
.bNotPressed:
    ld a, [curButtons]
    and PADF_A | PADF_START
    cp PADF_A | PADF_START
    jr nz, .noResetSave
    ld c, 1
    call loadGameSave
    jp EntryPoint
.noResetSave:

    call waitVblank
    jr saveResetPageLoop