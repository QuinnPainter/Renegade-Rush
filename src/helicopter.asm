INCLUDE "hardware.inc"
INCLUDE "macros.inc"
INCLUDE "spriteallocation.inc"

DEF HELI_TILE_OFFSET EQUS "((HelicopterTilesVRAM - $8000) / 16)"

DEF HELI_ANIM_SPEED EQU 3 ; Number of frames between each animation cel.
DEF HELI_NUM_ANIM_CELS EQU 8 ; Number of animation cels.

DEF HELI_SPAWN_CHANCE EQU 127 ; Chance of the helicopter spawning each frame, out of 65535
; So, if you calculate 1 / (HELI_SPAWN_CHANCE / 65535), you get the avg number of frames for it to spawn
; so 520 frames, or 8 seconds
DEF HELI_LEFT_BOUND EQU 16      ; The left and right X positions the helicopter will "bounce" between
DEF HELI_RIGHT_BOUND EQU 135    ;
DEF HELI_X_SPEED EQU $00BB      ; The side-to-side movement speed, in pixels per frame. 8.8 fixed-point
DEF HELI_BASE_Y EQU 17          ; The Y pos the helicopter is normally at.
DEF HELI_SPAWN_Y_SPEED EQU $0063    ; The speed the helicopter moves in at when spawning, in pixels per frame. 8.8

SECTION "HelicopterVars", WRAM0
HelicopterX: DS 2 ; Coordinates of the top-left of the heli. 8.8 fixed point.
HelicopterY: DS 2
HeliAnimationFrameCtr: DS 1
HeliAnimationCel: DS 1
HeliMovementState: DS 1 ; 0 - Moving Left, 1 = Moving Right
HeliState: DS 1 ; 0 - Inactive, 1 = Spawning, 2 = Active, 3 = Exploding

SECTION "HelicopterCode", ROM0

initHelicopter::
    xor a ; Set sprite attributes - no flip and no BG over OBJ
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 0)) + OAMA_FLAGS], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 1)) + OAMA_FLAGS], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 2)) + OAMA_FLAGS], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 3)) + OAMA_FLAGS], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 4)) + OAMA_FLAGS], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 5)) + OAMA_FLAGS], a
    ld [HeliState], a
    inc a
    ld [HeliAnimationCel], a
    ld [HeliAnimationFrameCtr], a
    ret

updateHelicopter::
    ld a, [HeliState]
    and a
    jr z, .StateInactive
    dec a
    jr z, .StateSpawning
    dec a
    jr z, .StateActive
    ; Exploding State

.StateSpawning:
    ld hl, HelicopterY
    ld a, [hli]
    ld l, [hl]
    ld h, a
    ld bc, HELI_SPAWN_Y_SPEED
    add hl, bc
    ld a, 127 ; if Y is still negative, it's still spawning
    cp h ; c set if 127 < y
    jr c, .stillSpawning
    ld a, HELI_BASE_Y ; have we reached the destination position yet?
    cp h ; c set if HELI_BASE_Y < y
    jr nc, .stillSpawning
    ld [HelicopterY], a ; done moving, change state to Active
    ld a, 2
    ld [HeliState], a
    ret
.stillSpawning:
    ld a, h
    ld [HelicopterY], a
    ld a, l
    ld [HelicopterY + 1], a
    jp .setAnimAndPos

.StateInactive:
    call genRandom
    ld bc, HELI_SPAWN_CHANCE
    cp_16r bc, hl
    ret c

    ld a, 1
    ld [HeliState], a
    call genRandom      ; random check passed, now initialise the position
    and %01111111       ; gen number between 0 and 127
    add (160 / 2) - 64  ; add that to the X of the middle of the screen - 64, to get a possible range of 16 to 143
    ld [HelicopterX], a
    cp 79   ; c set if HeliX < 79 (middle of screen)
    ld a, 0 ; preserve flags
    rla     ; shift carry into bit 1 of A
    ld [HeliMovementState], a   ; move left if on right side, move right if on left side

    xor a
    ld [HelicopterX + 1], a
    ld [HelicopterY + 1], a
    ld a, -16 ; spawn 32 pixels off the top
    ld [HelicopterY], a

.StateActive:
    ; Update movement
    ld hl, HelicopterX ; Moving left
    ld a, [hli]
    ld l, [hl]
    ld h, a
    ld bc, HELI_X_SPEED

    ld a, [HeliMovementState]
    and a
    jr nz, .movingRight
    sub_16r hl, bc, hl ; Moving left
    ld a, HELI_LEFT_BOUND
    cp h
    jr c, .doneProcessMove
    ld h, a
    ld a, 1
    ld [HeliMovementState], a
    jr .doneProcessMove
.movingRight: ; Moving right
    add hl, bc
    ld a, HELI_RIGHT_BOUND
    cp h
    jr nc, .doneProcessMove
    ld h, a
    xor a
    ld [HeliMovementState], a
.doneProcessMove:
    ld a, h
    ld [HelicopterX], a
    ld a, l
    ld [HelicopterX + 1], a

.setAnimAndPos: ; Spawning state jumps here
    ; Update animation
    ld hl, HeliAnimationFrameCtr
    dec [hl]
    jr nz, .noUpdateAnim
    ld a, HELI_ANIM_SPEED
    ld [hl], a
    ld hl, HeliAnimationCel
    dec [hl]
    jr nz, .noResetCel
    ld a, HELI_NUM_ANIM_CELS
    ld [hl], a
.noResetCel:
    ld a, [hl]  ; HeliAnimation Cel is 1-8, but there are only 3 actual frames of animation
    bit 0, a    ; use noRotorCel frame if HeliAnimationCel is an even number
    jr z, .noRotorCel
    cp 5        ; use rotorCel1 frame if HeliAnimationCel is 1 to 4
    jr c, .rotorCel1
    ld a, 2     ; use rotorCel2 frame if HeliAnimationCel is 5 to 8
    jr .doneFindCel
.noRotorCel:
    ld a, 1
    jr .doneFindCel
.rotorCel1:
    xor a
.doneFindCel:
    sla a ; a = AnimationCel * 2
    ld b, a
    sla a ; a = AnimationCel * 4
    add b ; a = AnimationCel * 6
    add HELI_TILE_OFFSET ; a = HELI_TILE_OFFSET + (AnimationCel * 6)
    ld b, 2
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 0)) + OAMA_TILEID], a
    add b
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 1)) + OAMA_TILEID], a
    add b
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 2)) + OAMA_TILEID], a
    add 14
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 3)) + OAMA_TILEID], a
    add b
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 4)) + OAMA_TILEID], a
    add b
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 5)) + OAMA_TILEID], a
.noUpdateAnim:

    ; Update sprite positions
    ld a, [HelicopterX]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 0)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 3)) + OAMA_X], a
    add 8
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 1)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 4)) + OAMA_X], a
    add 8
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 2)) + OAMA_X], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 5)) + OAMA_X], a
    ld a, [HelicopterY]
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 0)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 1)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 2)) + OAMA_Y], a
    add 16
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 3)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 4)) + OAMA_Y], a
    ld [SpriteBuffer + (sizeof_OAM_ATTRS * (HELICOPTER_SPRITE + 5)) + OAMA_Y], a
    ret