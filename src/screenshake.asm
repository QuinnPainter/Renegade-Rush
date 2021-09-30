INCLUDE "hardware.inc"
INCLUDE "macros.inc"

SECTION "ScreenShakeVars", WRAM0
ScreenShakePtr: DS 2
ScreenShakeCtr: DS 1

SECTION "ScreenShakeCode", ROM0

; Initialise screen shake
initScreenShake::
    xor a
    ld [ScreenShakeCtr], a
    ret

; Starts the screen shake
; Input - A = Intensity (0 to SIZEOF("ScreenShakeLUT"))
; Sets - A B C H L to garbage
startScreenShake::
    ld hl, ScreenShakeCtr
    cp [hl] ; c set if new intensity < old intensity
    ret c
    ld [hl], a
    cpl
    inc a
    add SIZEOF("ScreenShakeLUT") ; a = ScreenShakeLUTSize - Intensity
    ld c, a
    ld b, 0
    ld hl, ScreenShakeLUT
    add hl, bc
    ld a, l
    ld [ScreenShakePtr], a
    ld a, h
    ld [ScreenShakePtr + 1], a
    ret

; Updates the screen shake
; Sets - A B H L to garbage
updateScreenShake::
    ld a, [ScreenShakeCtr]
    and a
    ret z ; Screen shake is over :(
    rom_bank_switch BANK("ScreenShakeLUT")
    ; Update background shake
    ld hl, ScreenShakePtr
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, [hli] ; load value from LUT
    ld b, a
    add 16 ; compensate for background offset
    ld [ShadowScrollX], a
    ld a, l
    ld [ScreenShakePtr], a
    ld a, h
    ld [ScreenShakePtr + 1], a
    ; Update sprite shake
    /*ld a, [SpriteBuffer + (SPRITE * 0) + SPRITE_XPOS] ; Left side of car
    sub b ; why isn't this add???
    ld [SpriteBuffer + (SPRITE * 0) + SPRITE_XPOS], a
    ld [SpriteBuffer + (SPRITE * 2) + SPRITE_XPOS], a
    ld [SpriteBuffer + (SPRITE * 4) + SPRITE_XPOS], a
    ld a, [SpriteBuffer + (SPRITE * 1) + SPRITE_XPOS] ; Right side of car
    sub b
    ld [SpriteBuffer + (SPRITE * 1) + SPRITE_XPOS], a
    ld [SpriteBuffer + (SPRITE * 3) + SPRITE_XPOS], a
    ld [SpriteBuffer + (SPRITE * 5) + SPRITE_XPOS], a*/
    ; Update shake counter
    ld hl, ScreenShakeCtr
    dec [hl]
    ret