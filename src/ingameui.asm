INCLUDE "hardware.inc/hardware.inc"

STATUS_BAR_TILE_OFFSET EQUS "(((StatusBarVRAM - $8800) / 16) + 128)"

SECTION "StatusBarBuffer", WRAM0
DS 20 * 2 ; 20 tiles wide * 2 tiles tall

SECTION "In-Game UI Code", ROM0

initGameUI::
    ; Load in status bar tiles that never change
    ; could optimise some of the "ld a" to adds?
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
    ld a, STATUS_BAR_TILE_OFFSET + 58
    ld [STARTOF("StatusBarBuffer") + 19], a
    ld a, STATUS_BAR_TILE_OFFSET + 44 ; km / h
    ld [STARTOF("StatusBarBuffer") + 20 + 18], a
    inc a
    ld [STARTOF("StatusBarBuffer") + 20 + 19], a
    ret

updateGameUI::
    ; Draw status bar
    ; HL = top line pointer
    ; BC = bottom line pointer
    ld hl, STARTOF("StatusBarBuffer") + 1 ; + 1 to skip past dollar sign
    ld bc, STARTOF("StatusBarBuffer") + 1 + 20
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
    ret

copyStatusBarBuffer::
    ld hl, _SCRN1 ; copy first line
    ld de, STARTOF("StatusBarBuffer")
    ld c, SIZEOF("StatusBarBuffer") / 2
    rst memcpyFast
    ld hl, _SCRN1 + 32 ; copy second line
    ld c, SIZEOF("StatusBarBuffer") / 2
    rst memcpyFast
    ret