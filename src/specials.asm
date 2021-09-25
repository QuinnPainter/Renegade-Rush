INCLUDE "hardware.inc"
INCLUDE "macros.inc"
INCLUDE "collision.inc"
INCLUDE "spriteallocation.inc"

SECTION "SpecialVars", WRAM0
SpecialState: DS 1 ; For rock: 0 = On car, 1 = On road
SpecialSpriteX: DS 1 ; X position in sprite terms, used for the warning sign + object collision box.
SpecialSpriteY: DS 2 ; Y position used for the collision box. 8.8 fixed point.

SECTION "SpecialCode", ROM0

initSpecial::
    xor a
    ld [SpecialState], a
    ld [SpecialSpriteX], a
    ld [SpecialSpriteY], a
    ld [SpecialSpriteY + 1], a

    xor a ; Set sprite attributes
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (SPECIAL_SPRITE + 0)) + OAMA_FLAGS], a
    ld a, $10 ; Set sprite tiles (would probably be better if this wasn't hardcoded)
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (SPECIAL_SPRITE + 0)) + OAMA_TILEID], a
    xor a ; Put sprite offscreen
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (SPECIAL_SPRITE + 0)) + OAMA_Y], a
    ret

updateSpecial::
    ld a, [SelectedCar]
    dec a
    jr z, .updateTruckSpecial
    ; Time Car Special
    ret
.updateTruckSpecial:
    ld a, [SpecialState]
    and a
    ret z

    add_16 CurrentRoadScrollSpeed, SpecialSpriteY, SpecialSpriteY
    ld a, [SpecialSpriteY]
    cp 160
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

activateSpecial::
    ld a, [SelectedCar]
    dec a
    jr z, .activateTruckSpecial
    ; Activate Time car special
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
    ret