INCLUDE "hardware.inc"
INCLUDE "macros.inc"
INCLUDE "charmaps.inc"

; This file is in charge of keeping track of the player's travelled distance,
; and for increasing the difficulty accordingly.

DEF MENUBAR_TILE_OFFSET EQUS "(((MenuBarTilesVRAM - $8800) / 16) + 128)"
DEF NUMBER_TILE_OFFSET EQUS "(((MenuBarNumbersVRAM - $8800) / 16) + 128)"

SECTION "DistanceVars", WRAM0
DistanceTravelled: DS 3 ; Little endian BCD. Counts number of road lines travelled (8 pixels)
BestDistance:: DS 3 ; "High Score" distance

SECTION "DistanceCode", ROM0

initDistance::
    xor a
    ld hl, DistanceTravelled
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ret

; Add 1 to the distance value
; Sets - A H L to garbage
incrementDistance::
    ld hl, DistanceTravelled
    ld a, [hl]
    add 1
    daa
    ld [hli], a
    ld a, [hl]
    adc 0
    daa
    ld [hli], a
    ld a, [hl]
    adc 0
    daa
    ld [hli], a
    ret

; Sets the best distance if the current distance is greater
; Called when the game is over
; Sets - A H L to garbage
updateBestDistance::
    ld hl, DistanceTravelled
    ld a, [BestDistance]
    sub [hl]
    inc hl
    ld a, [BestDistance + 1]
    sbc [hl]
    inc hl
    ld a, [BestDistance + 2]
    sbc [hl]
    ret nc   ; BestDistance >= DistanceTravelled
    ld hl, DistanceTravelled    ; \
    ld a, [hli]                 ; |
    ld [BestDistance], a        ; |
    ld a, [hli]                 ; | BestDistance = DistanceTravelled
    ld [BestDistance + 1], a    ; |
    ld a, [hli]                 ; |
    ld [BestDistance + 2], a    ; /
    ret

; Draw the best distance used in the main menu
; Input - HL = Screen address to draw to
; Sets - A B C D to garbage
SETCHARMAP MainMenuCharmap
mainMenuDrawBest::
    push hl
    ld hl, Scratchpad

    ld a, [BestDistance]
    ld d, a
    ld a, [BestDistance + 1]
    ld c, a
    ld a, [BestDistance + 2]
    ld b, a

    ld a, b
    and $F0
    jr nz, .firstChar
    ld a, " "
    ld [hli], a
    ld a, b
    and $0F
    jr nz, .secondChar
    ld a, " "
    ld [hli], a

    ld a, c
    and $F0
    jr nz, .thirdChar
    ld a, " "
    ld [hli], a
    ld a, c
    and $0F
    jr nz, .fourthChar
    ld a, " "
    ld [hli], a
    
    ld a, d
    and $F0
    jr nz, .fifthChar
    ld a, " "
    ld [hli], a
    jr .sixthChar

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
.fifthChar:
    ld a, d
    and $F0
    swap a
    add "0"
    ld [hli], a
.sixthChar:
    ld a, d
    and $0F
    add "0"
    ld [hli], a

    pop hl
    ld de, Scratchpad
    ld c, 6
    call LCDMemcpyFast
    ret

; Draw the best distance used in the game over panel
; TODO: combine this with mainMenuDrawBest
; Input - HL = Screen address to draw to
; Input - A  = 0 to draw DistanceTravelled, 1 to draw BestDistance
; Sets - A B C D to garbage
gameOverDrawDistance::
    push hl
    ld hl, Scratchpad

    and a
    jr z, .drawDistanceTravelled
    ld a, [BestDistance]
    ld d, a
    ld a, [BestDistance + 1]
    ld c, a
    ld a, [BestDistance + 2]
    ld b, a
    jr .donePickDistance
.drawDistanceTravelled:
    ld a, [DistanceTravelled]
    ld d, a
    ld a, [DistanceTravelled + 1]
    ld c, a
    ld a, [DistanceTravelled + 2]
    ld b, a
.donePickDistance:

    ld a, b
    and $F0
    jr nz, .firstChar
    ld a, MENUBAR_TILE_OFFSET + 4 ; Blank Space tile
    ld [hli], a
    ld a, b
    and $0F
    jr nz, .secondChar
    ld a, MENUBAR_TILE_OFFSET + 4
    ld [hli], a

    ld a, c
    and $F0
    jr nz, .thirdChar
    ld a, MENUBAR_TILE_OFFSET + 4
    ld [hli], a
    ld a, c
    and $0F
    jr nz, .fourthChar
    ld a, MENUBAR_TILE_OFFSET + 4
    ld [hli], a
    
    ld a, d
    and $F0
    jr nz, .fifthChar
    ld a, MENUBAR_TILE_OFFSET + 4
    ld [hli], a
    jr .sixthChar

.firstChar:
    ld a, b
    and $F0
    swap a
    add NUMBER_TILE_OFFSET
    ld [hli], a
.secondChar:
    ld a, b
    and $0F
    add NUMBER_TILE_OFFSET
    ld [hli], a
.thirdChar:
    ld a, c
    and $F0
    swap a
    add NUMBER_TILE_OFFSET
    ld [hli], a
.fourthChar:
    ld a, c
    and $0F
    add NUMBER_TILE_OFFSET
    ld [hli], a
.fifthChar:
    ld a, d
    and $F0
    swap a
    add NUMBER_TILE_OFFSET
    ld [hli], a
.sixthChar:
    ld a, d
    and $0F
    add NUMBER_TILE_OFFSET
    ld [hli], a

    pop hl
    ld de, Scratchpad
    ld c, 6
    call LCDMemcpyFast
    ret