INCLUDE "hardware.inc/hardware.inc"
INCLUDE "macros.inc"

STATUS_BAR_TILE_OFFSET EQUS "(((StatusBarVRAM - $8800) / 16) + 128)"
MENUBAR_TILE_OFFSET EQUS "(((MenuBarTilesVRAM - $8800) / 16) + 128)"
MENU_BAR_ANIM_SPEED EQU 3 ; How fast the menu bar opens / closes. Pixels per frame.
MENU_BAR_MID_POS EQU 64 ; Scanline number of the middle of the menu bar
MENU_BAR_HEIGHT EQU 24 ; Distance from middle of menu bar to the top and bottom

SECTION "StatusBarBuffer", WRAM0, ALIGN[6]
DS 20 * 2 ; 20 tiles wide * 2 tiles tall

SECTION "MenuBarState", WRAM0
menuBarTopLine: DS 1 ; Scanline of the top of the menu bar
menuBarBottomLine: DS 1 ; Scanline of the bottom of the menu bar
whichMenuOpen: DS 1 ; 0 = Pause Menu, nonzero = Game Over
menuBarState: DS 1 ; 0 = growing, nonzero = shrinking
menuBarDoneAnim: DS 1 ; 0 = still animating, menu functionality is disabled, nonzero = menu is ready

SECTION "In-Game UI Code", ROM0

; Initialise the starting state of game UI
; Sets - A to garbage
initGameUI::
    ; Load in status bar tiles that never change
    ld a, STATUS_BAR_TILE_OFFSET + 11 ; dollar sign
    ld [STARTOF("StatusBarBuffer")], a
    ld a, STATUS_BAR_TILE_OFFSET + 27
    ld [STARTOF("StatusBarBuffer") + 20], a
    ld a, STATUS_BAR_TILE_OFFSET + 26 ; blank space to left of missile
    ld [STARTOF("StatusBarBuffer") + 20 + 11], a
    ld [STARTOF("StatusBarBuffer") + 20 + 14], a ; blank space to left of speed
    ld a, STATUS_BAR_TILE_OFFSET + 10
    ld [STARTOF("StatusBarBuffer") + 14], a
    ld [STARTOF("StatusBarBuffer") + 18], a ; blank space at top right
    ld a, STATUS_BAR_TILE_OFFSET + 60
    ld [STARTOF("StatusBarBuffer") + 19], a
    ld a, STATUS_BAR_TILE_OFFSET + 58 ; km / h
    ld [STARTOF("StatusBarBuffer") + 20 + 18], a
    inc a
    ld [STARTOF("StatusBarBuffer") + 20 + 19], a
    ; Setup interrupt options that tell the selection bar to go the bottom of the menu bar
    ld a, LOW(menuBarBottomLineFunc)
    ld [AfterSelIntVec], a
    ld a, HIGH(menuBarBottomLineFunc)
    ld [AfterSelIntVec + 1], a
    ld a, MENU_BAR_MID_POS + MENU_BAR_HEIGHT
    ld [AfterSelIntLine], a
    ret

; Generates the tilemaps for the Paused and Game Over menus, and puts them in the BG map
; Assumes VRAM is always active, so needs to be run while screen is disabled
genMenuBarTilemaps::
    rom_bank_switch BANK("MenuBarTilemap")
    ld de, STARTOF("MenuBarTilemap")
    ld b, MENUBAR_TILE_OFFSET
FOR N, 0, 12
    ld hl, _SCRN1 + (32 * (18 + N))
    ld c, 20
    rst memcpyFastOffset
ENDR
    ret

; Updates the status bar state, and puts it into StatusBarBuffer
; Sets - A B C D E H L to garbage
updateStatusBar::
    ; Draw status bar
    ; HL = top line pointer
    ; BC = bottom line pointer
    rom_bank_switch BANK("CurveBarTilemap")
    ld hl, STARTOF("StatusBarBuffer") + 1 ; + 1 to skip past dollar sign
    ld bc, STARTOF("StatusBarBuffer") + 1 + 20
    ; Draw money
FOR N, 1, -1, -1 ; run this for MoneyAmount + 1 and MoneyAmount
    ld a, [MoneyAmount + N]
    ld d, a
    swap a
    and $0F
    add STATUS_BAR_TILE_OFFSET
    ld [hli], a ; digit 1 top
    add 16
    ld [bc], a ; digit 1 bottom
    inc c ; never changes pages, so "inc c" works instead of "inc bc"
    ld a, d
    and $0F
    add STATUS_BAR_TILE_OFFSET
    ld [hli], a ; digit 2 top
    add 16
    ld [bc], a ; digit 2 bottom
    inc c
ENDR
    ; Draw curved part of charge bars
    ld a, [SpecialChargeValue]
    and %00000011
    sla a
    sla a
    ld d, a
    ld a, [MissileChargeValue]
    and %00000011
    or a, d ; bottom 2 bits = on/off state of 2 curved bars for missile, 2 bits above = state for special
    sla a ; each entry is 4 bytes
    sla a
    ld de, STARTOF("CurveBarTilemap") ; \
    add e                             ; | ld de with CurveBarTilemap + offset
    ld e, a                           ; /
    ld a, [de]
    add STATUS_BAR_TILE_OFFSET
    ld [hli], a
    inc e
    ld a, [de]
    add STATUS_BAR_TILE_OFFSET
    ld [hli], a
    inc e
    ld a, [de]
    add STATUS_BAR_TILE_OFFSET
    ld [bc], a
    inc e
    inc c
    ld a, [de]
    add STATUS_BAR_TILE_OFFSET
    ld [bc], a
    inc c
    ; Draw straight part of charge bars
    ld d, %00000100
.drawStraightBarsLp:
    ld a, [MissileChargeValue]
    and d
    jr nz, .missileOn
    ld a, [SpecialChargeValue]
    and d
    jr nz, .missileOffSpecialOn
.missileOffSpecialOff:
    ld a, STATUS_BAR_TILE_OFFSET + 41
    ld [hli], a
    jr .doneDrawStraightBlock
.missileOffSpecialOn:
    ld a, STATUS_BAR_TILE_OFFSET + 40
    ld [hli], a
    jr .doneDrawStraightBlock
.missileOn:
    ld a, [SpecialChargeValue]
    and d
    jr nz, .missileOnSpecialOn
.missileOnSpecialOff:
    ld a, STATUS_BAR_TILE_OFFSET + 39
    ld [hli], a
    jr .doneDrawStraightBlock
.missileOnSpecialOn:
    ld a, STATUS_BAR_TILE_OFFSET + 38
    ld [hli], a
.doneDrawStraightBlock:
    sla d
    bit 6, d
    jr z, .drawStraightBarsLp
    ; Draw hearts
    ld a, [LivesValue]
    ld d, a
REPT 4
    dec d
    bit 7, d ; if result is negative
    jr z, .filledHeart\@
    ld a, STATUS_BAR_TILE_OFFSET + 55 ; empty heart
    jr .drawHeart\@
.filledHeart\@:
    ld a, STATUS_BAR_TILE_OFFSET + 54
.drawHeart\@:
    ld [bc], a
    inc c
ENDR
    inc c ; skip past already filled block
    ; Draw special / missile icons and lines
    ld a, [MissileChargeValue]
    and %00100000
    jr nz, .missileOn2
    ld a, [SpecialChargeValue]
    and %00100000
    jr nz, .missileOffSpecialOn2
.missileOffSpecialOff2:
    ld a, STATUS_BAR_TILE_OFFSET + 12 ; top line
    ld [hli], a
    ld a, STATUS_BAR_TILE_OFFSET + 42
    ld [hli], a
    inc a
    ld [hli], a
    ld a, STATUS_BAR_TILE_OFFSET + 46 ; bottom line
    ld [bc], a
    inc c
    inc a
    ld [bc], a
    inc c
    jr .doneDrawIcons
.missileOffSpecialOn2:
    ld a, STATUS_BAR_TILE_OFFSET + 28 ; top line
    ld [hli], a
    ld a, STATUS_BAR_TILE_OFFSET + 45
    ld [hli], a
    ld a, STATUS_BAR_TILE_OFFSET + 43
    ld [hli], a
    ld a, STATUS_BAR_TILE_OFFSET + 30 ; bottom line
    ld [bc], a
    inc c
    ld a, STATUS_BAR_TILE_OFFSET + 47
    ld [bc], a
    inc c
    jr .doneDrawIcons
.missileOn2:
    ld a, [SpecialChargeValue]
    and %00100000
    jr nz, .missileOnSpecialOn2
.missileOnSpecialOff2:
    ld a, STATUS_BAR_TILE_OFFSET + 13 ; top line
    ld [hli], a
    ld a, STATUS_BAR_TILE_OFFSET + 44
    ld [hli], a
    ld a, STATUS_BAR_TILE_OFFSET + 15
    ld [hli], a
    ld a, STATUS_BAR_TILE_OFFSET + 46 ; bottom line
    ld [bc], a
    inc c
    ld a, STATUS_BAR_TILE_OFFSET + 31
    ld [bc], a
    inc c
    jr .doneDrawIcons
.missileOnSpecialOn2:
    ld a, STATUS_BAR_TILE_OFFSET + 29 ; top line
    ld [hli], a
    ld a, STATUS_BAR_TILE_OFFSET + 14
    ld [hli], a
    inc a
    ld [hli], a
    ld a, STATUS_BAR_TILE_OFFSET + 30 ; bottom line
    ld [bc], a
    inc c
    inc a
    ld [bc], a
    inc c
.doneDrawIcons:
    inc l ; skip past 2 already filled blocks
    inc c
    ; Draw speed
    ; To convert road scroll speed to KM/H, shift right twice then subtract 40ish
    ; speeds above 0 but below a certain value will be negative - is this an issue?
    push hl ; save HL and BC for when we need to write the text
    push bc
    ld a, [CurrentRoadScrollSpeed + 1] ; load low byte
    srl a
    srl a
    ld d, a
    ld a, [CurrentRoadScrollSpeed] ; load high byte
    rrca ; rotate right is equivalent to shifting right onto new byte
    rrca ; if value was %00000111 it's now %11000001
    ld h, a
    and $F0 ; isolate top bits
    or d ; combine high and low bytes
    ld l, a ; move into low byte area
    ld a, h
    and $0F ; isolate bottom bits
    ld h, a ; move into high byte area
    or l               ; \
    jr z, .noKphOffset ; / special case so 0 speed shows as 0 kph
    ld bc, -40
    add hl, bc
.noKphOffset: ; kph conversion is done, value is in HL, now convert to characters

    call bcd16
    pop bc ; restore HL and BC to the array indices
    pop hl ; C isn't needed since the value is never >1000
    ld a, d
    and $0F ; isolate hundreds digit
    add STATUS_BAR_TILE_OFFSET ; \
    ld [hli], a                ; |
    add 16                     ; | write hundreds digit
    ld [bc], a                 ; |
    inc c                      ; /
    ld a, e
    and $F0 ; isolate tens digit
    swap a
    add STATUS_BAR_TILE_OFFSET ; \
    ld [hli], a                ; |
    add 16                     ; | write tens digit
    ld [bc], a                 ; |
    inc c                      ; /
    ld a, e
    and $0F ; isolate ones digit
    add STATUS_BAR_TILE_OFFSET ; \
    ld [hli], a                ; |
    add 16                     ; | write ones digit
    ld [bc], a                 ; /

    ret

; Copy the status bar buffer into VRAM
; Sets - A C D E H L to garbage
copyStatusBarBuffer::
    ld hl, _SCRN1 + (32 * 30) ; copy first line
    ld de, STARTOF("StatusBarBuffer")
    ld c, SIZEOF("StatusBarBuffer") / 2
    rst memcpyFast
    ld hl, _SCRN1 + (32 * 31) ; copy second line
    ld c, SIZEOF("StatusBarBuffer") / 2
    rst memcpyFast
    ret

; Run every frame, in an LCD interrupt on the first line of the status bar.
statusBarTopLine::
    ldh a, [rLCDC]
    and ~LCDCF_OBJON ; Disable sprites
    or LCDCF_BG9C00 ; Switch background tilemap
    ld b, a

    ; Wait for safe VRAM access (next hblank)
:   ld a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ; Set LCD registers
    ld a, b
    ldh [rLCDC], a
    xor a
    ldh [rSCX], a ; Set X scroll to 0
    ld a, (8 * 30) - 129 ; 8 pix per tile * 30 tile lines to bottom of VRAM - status bar starts scanline 129
    ldh [rSCY], a ; Set Y scroll to show status bar

    jp LCDIntEnd

; Set up LCD interrupt for top of menu bar
; Sets - A to garbage
setupMenuBarInterrupt::
    ld a, LOW(menuBarTopLineFunc)
    ld [LCDIntVectorRAM], a
    ld a, HIGH(menuBarTopLineFunc)
    ld [LCDIntVectorRAM + 1], a
    ld a, [menuBarTopLine]
    dec a
    ld [rLYC], a
    ret

; Runs on the top scanline of the menu bar.
menuBarTopLineFunc:
    ldh a, [rLCDC]
    and ~LCDCF_OBJON ; Disable sprites
    or LCDCF_BG9C00 ; Switch background tilemap
    ld b, a
    ld a, [whichMenuOpen]
    and a
    jr nz, .gameOverMenu
    ld c, (8 * 18) - 40 ; 8 pix per tile * 24 tile lines to the position in VRAM - menu bar starts scanline 40
    jr .donePickMenu
.gameOverMenu:
    ld c, (8 * 24) - 40 ; 8 pix per tile * 24 tile lines to the position in VRAM - menu bar starts scanline 40
.donePickMenu:

    ; Wait for safe VRAM access (next hblank)
:   ld a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ; Set LCD registers
    ld a, b
    ldh [rLCDC], a
    xor a
    ldh [rSCX], a ; Set X scroll to 0
    ld a, c
    ldh [rSCY], a ; Set Y scroll to show status bar

    ld a, [menuBarDoneAnim]
    and a
    jr z, .noSelBar
    call selectionBarSetupTopInt
    jp LCDIntEnd
.noSelBar:
    ; Set up menu bar bottom line interrupt
    ld a, LOW(menuBarBottomLineFunc)
    ld [LCDIntVectorRAM], a
    ld a, HIGH(menuBarBottomLineFunc)
    ld [LCDIntVectorRAM + 1], a
    ld a, [menuBarBottomLine]
    dec a
    ld [rLYC], a
    jp LCDIntEnd

; Runs on the bottom scanline of the menu bar.
menuBarBottomLineFunc:
    ldh a, [rLCDC]
    or LCDCF_OBJON ; Enable sprites
    and ~LCDCF_BG9C00 ; Switch background tilemap
    ld b, a
    ld a, [ShadowScrollX] ; Set X scroll back to road
    ld c, a
    ld a, [CurrentRoadScrollPos] ; Set Y scroll back to road
    ld d, a

    ; Wait for safe VRAM access (next hblank)
:   ld a, [rSTAT]
    and a, STATF_BUSY
    jr nz, :-

    ; Set LCD registers
    ld a, b
    ldh [rLCDC], a
    ld a, c
    ldh [rSCX], a
    ld a, d
    ldh [rSCY], a

    ; Set up status bar interrupt
    call setupStatusBarInterrupt
    jp LCDIntEnd

; Run when the menu bar opens.
; Input - A = Which menu to open (0 = Pause, nonzero = Game Over)
; Sets - A to garbage
startMenuBarAnim::
    ld [whichMenuOpen], a
    ld a, MENU_BAR_MID_POS
    ld [menuBarTopLine], a
    inc a
    ld [menuBarBottomLine], a
    xor a
    ld [menuBarState], a
    ld [menuBarDoneAnim], a
    ld a, 64 ; Start selection bar on "Resume"
    ld [SelBarTopLine], a
    ld [SelBarTargetPos], a
    xor a
    ld [SelBarTopLine + 1], a
    ret

; Run every frame when menu bar is open.
updateMenuBar::
    ld a, [menuBarState]
    and a
    ld a, [menuBarTopLine]
    ld b, MENU_BAR_ANIM_SPEED
    jr z, .barGrowing
    add b ; Bar is shrinking
    ld [menuBarTopLine], a
    ld c, a
    ld a, [menuBarBottomLine]
    sub b
    ld [menuBarBottomLine], a
    cp c ; C Set if (menuBarBottomLine < menuBarTopLine)
    jr nc, .doneAnimBar
    xor a ; When menu bar is done closing, unpause the game
    ld [IsGamePaused], a ; Only the pause menu shrinks, the game over menu doesn't, so this is fine.
    ld a, MENU_BAR_MID_POS    ; \
    ld [menuBarTopLine], a    ; | Reset the bar positions to 1 line high
    inc a                     ; | This prevents the bar from "glitching" for one frame after closing
    ld [menuBarBottomLine], a ; /
    jr .doneAnimBar
.barGrowing:
    sub b
    cp MENU_BAR_MID_POS - MENU_BAR_HEIGHT
    jr c, .doneGrowing
    ld [menuBarTopLine], a
    ld a, [menuBarBottomLine]
    add b
    ld [menuBarBottomLine], a
    jr .doneAnimBar
.doneGrowing:
    ld a, MENU_BAR_MID_POS - MENU_BAR_HEIGHT
    ld [menuBarTopLine], a
    ld a, MENU_BAR_MID_POS + MENU_BAR_HEIGHT
    ld [menuBarBottomLine], a
    ld a, $FF
    ld [menuBarDoneAnim], a
.doneAnimBar:

    ld a, [whichMenuOpen]   ; \
    and a                   ; | Can't close menu when game over, so skip past unpause
    jr nz, .pauseNotPressed ; /
    ld a, [newButtons] ; Start shrinking menu bar if start button is pressed
    and PADF_START
    jr z, .pauseNotPressed
    ld a, $FF
    ld [menuBarState], a
    xor a
    ld [menuBarDoneAnim], a
.pauseNotPressed:

    ld a, [menuBarDoneAnim]
    and a
    jr z, .skipCheckMenuButtons

    call selectionBarUpdate

    ld a, [newButtons]
    and PADF_UP
    jr z, .upNotPressed
    ld a, [SelBarTargetPos]
    sub 8
    ld [SelBarTargetPos], a
.upNotPressed:
    ld a, [newButtons]
    and PADF_DOWN
    jr z, .downNotPressed
    ld a, [SelBarTargetPos]
    add 8
    ld [SelBarTargetPos], a
.downNotPressed:
.skipCheckMenuButtons:
    ret