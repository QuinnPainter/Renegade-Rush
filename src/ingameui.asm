INCLUDE "hardware.inc/hardware.inc"

STATUS_BAR_TILE_OFFSET EQUS "(((StatusBarVRAM - $8800) / 16) + 128)"

SECTION "StatusBarBuffer", WRAM0, ALIGN[6]
DS 20 * 2 ; 20 tiles wide * 2 tiles tall

SECTION "In-Game UI Code", ROM0

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
    ld a, STATUS_BAR_TILE_OFFSET + 58
    ld [STARTOF("StatusBarBuffer") + 19], a
    ld a, STATUS_BAR_TILE_OFFSET + 59 ; km / h
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

copyStatusBarBuffer::
    ld hl, _SCRN1 ; copy first line
    ld de, STARTOF("StatusBarBuffer")
    ld c, SIZEOF("StatusBarBuffer") / 2
    rst memcpyFast
    ld hl, _SCRN1 + 32 ; copy second line
    ld c, SIZEOF("StatusBarBuffer") / 2
    rst memcpyFast
    ret