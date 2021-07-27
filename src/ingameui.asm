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
    jr nz, .missileOffChargeOn
.missileOffChargeOff:
    ld a, STATUS_BAR_TILE_OFFSET + 41
    ld [hli], a
    jr .doneDrawStraightBlock
.missileOffChargeOn:
    ld a, STATUS_BAR_TILE_OFFSET + 40
    ld [hli], a
    jr .doneDrawStraightBlock
.missileOn:
    ld a, [SpecialChargeValue]
    and d
    jr nz, .missileOnChargeOn
.missileOnChargeOff:
    ld a, STATUS_BAR_TILE_OFFSET + 39
    ld [hli], a
    jr .doneDrawStraightBlock
.missileOnChargeOn:
    ld a, STATUS_BAR_TILE_OFFSET + 38
    ld [hli], a
.doneDrawStraightBlock:
    sla d
    bit 6, d
    jr z, .drawStraightBarsLp
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