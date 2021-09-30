INCLUDE "hardware.inc"
INCLUDE "macros.inc"
INCLUDE "collision.inc"
INCLUDE "spriteallocation.inc"

DEF TIME_CAR_INVISIBLE_TIME EQU 200 ; number of frames.
DEF TIME_CAR_SCREEN_FLASH_FRAMES EQU 10

SECTION "SpecialVars", WRAM0
SpecialState: DS 1 ; For rock: 0 = On car, 1 = On road. For time car: 0 = Effect inactive, 1 = Active
SpecialSpriteX: DS 1 ; X position in sprite terms, used for the warning sign + object collision box.
SpecialSpriteY: DS 2 ; Y position used for the collision box. 8.8 fixed point.
SpecialTimer: DS 1 ; For time car: counts frames left in effect
ScreenFlashTimer: DS 1

SECTION "SpecialCode", ROM0

; Initialise special-related stuff
initSpecial::
    xor a
    ld [SpecialState], a
    ld [SpecialSpriteX], a
    ld [SpecialSpriteY], a
    ld [SpecialSpriteY + 1], a
    ld [ScreenFlashTimer], a

    xor a ; Set sprite attributes
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (SPECIAL_SPRITE + 0)) + OAMA_FLAGS], a
    ld a, $10 ; Set sprite tiles (would probably be better if this wasn't hardcoded)
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (SPECIAL_SPRITE + 0)) + OAMA_TILEID], a
    xor a ; Put sprite offscreen
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (SPECIAL_SPRITE + 0)) + OAMA_Y], a
    ret

; Update the special stuff
; Runs once per frame
updateSpecial::
    ld a, [SelectedCar]
    dec a
    jr z, .updateTruckSpecial
    ; Time Car Special
    ld hl, ScreenFlashTimer
    ld a, [hl]
    and a
    jr z, .noScreenFlash
    dec [hl]
    jr z, .screenFlashOver
    xor a
    ld [rBGP], a
    ld [rOBP0], a
    jr .noScreenFlash
.screenFlashOver:
    ld a, %11100100
    ld [rBGP], a
    ld [rOBP0], a
.noScreenFlash:

    ld a, [SpecialState]
    and a
    ret z

    ld hl, SpecialTimer
    ld a, [hl]
    and %11
    jr z, .drawVisible
    ld a, 1
    jr .doneSetVisibility
.drawVisible:
    xor a
.doneSetVisibility:
    ld [IsPlayerInvisible], a
    dec [hl]
    ret nz
    xor a ; time has run out
    ld [IsPlayerInvisible], a
    ld [SpecialState], a
    ld a, $FF
    ld [PlayerCollisionMask], a
    ld a, TIME_CAR_SCREEN_FLASH_FRAMES
    ld [ScreenFlashTimer], a
    play_sound_effect FX_TimeCarBlip
    ret

.updateTruckSpecial:
    ld a, [SpecialState]
    and a
    ret z

    add_16 CurrentRoadScrollSpeed, SpecialSpriteY, SpecialSpriteY
    ld a, [SpecialSpriteY]
    cp 190
    jr c, .notOffBottom
    xor a ; Went off the bottom of the screen, time to disable it
    ld [SpecialState], a
    ld [ObjCollisionArray + SPECIAL_COLLISION], a
    ret
.notOffBottom:

    ; Update entry in object collision array
    ld hl, ObjCollisionArray + SPECIAL_COLLISION
    ld a, %00010000 ; Collision Layer Flags
    ld [hli], a
    ld a, [SpecialSpriteY] ; Top Y
    ld [hli], a
    add 8 ; Bottom Y - rock is 8 px tall
    ld [hli], a
    ld a, [SpecialSpriteX] ; Left X
    ld [hli], a
    add 8 ; Right X - object is 8 px wide
    ld [hli], a
    ld a, 2 << 4 ; object type = road obstacle
    ld [hl], a

    ; Update sprite position
    ld a, [SpecialSpriteY]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (SPECIAL_SPRITE + 0)) + OAMA_Y], a
    ld a, [SpecialSpriteX]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (SPECIAL_SPRITE + 0)) + OAMA_X], a

    ret

; Runs when the user presses the button to activate a special
activateSpecial::
    ld a, [SelectedCar]
    dec a
    jr z, .activateTruckSpecial
    ; Activate Time car special
    ld a, TIME_CAR_INVISIBLE_TIME
    ld [SpecialTimer], a
    ld a, 1
    ld [IsPlayerInvisible], a
    ld [SpecialState], a
    xor a
    ld [PlayerCollisionMask], a
    ld a, TIME_CAR_SCREEN_FLASH_FRAMES
    ld [ScreenFlashTimer], a
    play_sound_effect FX_TimeCarBlip
    ret
.activateTruckSpecial
    ld a, [PlayerX]
    add 4 ; center on player
    ld [SpecialSpriteX], a
    ld a, [PlayerY]
    add 24 ; come out of the back of the player
    ld [SpecialSpriteY], a
    ld a, 1
    ld [SpecialState], a
    play_sound_effect FX_TruckDropRock
    ret