INCLUDE "hardware.inc"
INCLUDE "macros.inc"
INCLUDE "spriteallocation.inc"
INCLUDE "collision.inc"

DEF MISSILE_TILE_OFFSET EQUS "((MissileTilesVRAM - $8000) / 16)"

DEF MISSILE_ACCELERATION EQU $0026 ; How fast missile accelerates, in pixels per frame per frame. 8.8
DEF MISSILE_ANIM_SPEED EQU 4 ; Number of frames between the animation cels.

RSRESET
DEF MissileX RB 2       ; Position of missile. 8.8
DEF MissileY RB 2       ;
DEF MissileYSpeed RB 2  ; Y speed. Will always be positive, regardless of missile direction. 8.8
DEF MissileState RB 1   ; Bit 0 [0 = Inactive, 1 = Active], Bit 1 [0 = Moving Down, 1 = Moving Up]
DEF MissileSprite RB 1  ; Low byte of the address in the SpriteBuffer.
DEF MissileAnimState RB 1 ; 0 = Cel 1, FF = Cel 2
DEF MissileAnimFrameCtr RB 1
DEF MissileCollisionIndex RB 1 ; Index into the object collision array
DEF MissileCollisionFlags RB 1 ; Object collision flags, determines which objects this missile will collide with
DEF sizeof_MissileVars RB 0

SECTION "Missile1Vars", WRAM0, ALIGN[8]
Missile1Vars: DS sizeof_MissileVars

SECTION "Missile2Vars", WRAM0, ALIGN[8]
Missile2Vars: DS sizeof_MissileVars

SECTION "MissileCode", ROM0

; Initialise all missiles
initMissiles::
    ld h, HIGH(Missile1Vars)
    ld c, LOW(sizeof_OAM_ATTRS * MISSILE_SPRITE_1)
    ld d, MISSILE_COLLISION_1
    call initMissile
    ld h, HIGH(Missile2Vars)
    ld c, LOW(sizeof_OAM_ATTRS * MISSILE_SPRITE_2)
    ld d, MISSILE_COLLISION_2
    call initMissile
    ret

; Updates all missiles
updateMissiles::
    ld h, HIGH(Missile1Vars)
    call updateMissile
    ld h, HIGH(Missile2Vars)
    call updateMissile
    ret

; Initialises a single missile
; Input - H = High byte of missile state address
; Input - C = Low byte of sprite address
; Input - D = Collision array index
initMissile:
    ld l, LOW(Missile1Vars) + MissileState
    xor a
    ld [hli], a                 ; Set state to Inactive
    ld [hl], c                  ; Set sprite address
    inc l
    ld b, HIGH(SpriteBuffer)    ; Set sprite Y position to 0 (offscreen)
    ld [bc], a                  ;
    ld [hli], a                 ; Set MissileAnimState to 0
    inc a
    ld [hli], a                 ; Set MissileAnimFrameCtr to 1
    ld [hl], d                  ; Set MissileCollisionIndex
    ret

; Updates a single missile
; Input - H = High byte of missile state address
updateMissile:
    ld l, LOW(Missile1Vars) + MissileState
    ld a, [hl]
    rra ; set carry to bit 0 (inactive / active)
    jr c, .missileActive
    ; Missile is inactive
    ld l, LOW(Missile1Vars) + MissileCollisionIndex ; \
    ld a, [hl]                                      ; |
    add LOW(ObjCollisionArray)                      ; |
    ld c, a                                         ; | disable collision array entry
    ld b, HIGH(ObjCollisionArray)                   ; |
    xor a                                           ; |
    ld [bc], a                                      ; /
    ret

.missileActive:
    ; Update position
    rra ; set carry to bit 1 (moving down / moving up)
    ld l, LOW(Missile1Vars) + MissileYSpeed ; \
    ld a, [hli]                             ; | BC = MissileYSpeed
    ld c, [hl]                              ; |
    ld b, a                                 ; /
    ld l, LOW(Missile1Vars) + MissileY + 1  ; A = low byte MissileY
    ld a, [hl]                              ;
    jr c, .movingUp
    add c                                   ; \
    ld [hld], a                             ; |
    ld a, [hl]                              ; | moving down - MissileY += MissileYSpeed
    adc b                                   ; |
    ld [hl], a                              ; /
    jr .doneProcessMove
.movingUp:
    sub c                                   ; \
    ld [hld], a                             ; |
    ld a, [hl]                              ; | moving up - MissileY -= MissileYSpeed
    sbc b                                   ; |
    ld [hl], a                              ; /
.doneProcessMove:
    cp 200                                  ; \
    jr c, .notOffScreen                     ; |
    xor a                                   ; |
    ld l, LOW(Missile1Vars) + MissileState  ; | deactivate missile if it went offscreen
    ld [hl], a                              ; |
    ld l, LOW(Missile1Vars) + MissileCollisionIndex ; \
    ld a, [hl]                                      ; |
    add LOW(ObjCollisionArray)                      ; |
    ld c, a                                         ; | disable collision array entry
    ld b, HIGH(ObjCollisionArray)                   ; |
    xor a                                           ; |
    ld [bc], a                                      ; /
    jr .updateSprite                        ; |
.notOffScreen:                              ; /

    ; Update speed
    ld l, LOW(Missile1Vars) + MissileYSpeed + 1 ; \
    ld a, [hl]                                  ; |
    add LOW(MISSILE_ACCELERATION)               ; |
    ld [hld], a                                 ; | MissileYSpeed += MISSILE_ACCELERATION
    ld a, [hl]                                  ; |
    adc HIGH(MISSILE_ACCELERATION)              ; |
    ld [hl], a                                  ; /

    ; Update entry in object collision array
    ld b, h ; Use BC instead of HL for missile vars for now
    ld l, LOW(Missile1Vars) + MissileCollisionIndex ; \
    ld a, [hl]                                      ; |
    add LOW(ObjCollisionArray)                      ; | HL = ObjCollisionArray pointer
    ld l, a                                         ; |
    ld h, HIGH(ObjCollisionArray)                   ; /
    ld c, LOW(Missile1Vars) + MissileCollisionFlags
    ld a, [bc] ; Collision Layer Flags
    ld [hli], a
    ld c, LOW(Missile1Vars) + MissileY
    ld a, [bc] ; Top Y
    ld [hli], a
    add 9 ; Bottom Y - missile is 9 px tall
    ld [hli], a
    ld c, LOW(Missile1Vars) + MissileX
    ld a, [bc] ; Left X
    ld [hli], a
    add 8 ; Right X - missile is 8 px wide
    ld [hl], a
    ld h, b ; Put HL back as the missile var pointer

    ; Check for collisions
    ld l, LOW(Missile1Vars) + MissileCollisionIndex
    ld a, [hl]
    push hl
    call objCollisionCheck
    pop hl
    and a
    jr z, .noCol ; collision happened - missile was destroyed
    ; disabling immediately can mean missed collisions
    ; so just hide it, and it will be destroyed next frame due to going offscreen
    ld a, 230
    ;ld l, LOW(Missile1Vars) + MissileState  ; \
    ;xor a                                   ; | state = disabled
    ;ld [hl], a                              ; /
    ld l, LOW(Missile1Vars) + MissileY      ; move missile offscreen
    ld [hl], a                              ;
.noCol:

.updateSprite:
    ; Update sprite position
    ld l, LOW(Missile1Vars) + MissileSprite ; \
    ld c, [hl]                              ; | BC = Y Position attribute of MissileSprite
    ld b, HIGH(SpriteBuffer)                ; /
    ld l, LOW(Missile1Vars) + MissileY      ; \
    ld a, [hl]                              ; | [BC] = MissileY
    ld [bc], a                              ; /
    inc c                                   ; BC = X Position attribute
    ld l, LOW(Missile1Vars) + MissileX      ; \
    ld a, [hl]                              ; | [BC] = MissileX
    ld [bc], a                              ; /

    ; Update animation state
    ld l, LOW(Missile1Vars) + MissileAnimFrameCtr
    dec [hl]
    jr nz, .noUpdateAnimation
    ld a, MISSILE_ANIM_SPEED            ; Reset frame counter
    ld [hld], a                         ;
    ld a, [hl]                          ; \
    cpl                                 ; | Invert MissileAnimState
    ld [hl], a                          ; /
.noUpdateAnimation:

    ; Set sprite tiles based on current animation frame
    inc c                                   ; BC = Tile Index
    ld l, LOW(Missile1Vars) + MissileAnimState
    ld a, [hl]
    and a
    ld a, MISSILE_TILE_OFFSET
    jr nz, .cel1
    add 2
.cel1:
    ld [bc], a
    ret

; Fire the player's missile
; Always uses missile number 1, and therefore the player can only have 1 missile on screen at a time
; Sets - H L A to garbage
firePlayerMissile::
    ld hl, Missile1Vars + MissileState      ; \
    ld a, %11                               ; | Set state to Active and Moving Up
    ld [hl], a                              ; /
    ld l, LOW(Missile1Vars) + MissileX      ; \
    ld a, [PlayerX]                         ; | MissileX = (PlayerX + offset) so missile is centered
    add (16 / 2) - (8 / 2)                  ; | PlayerWidth / 2 - MissileWidth / 2
    ld [hli], a                             ; /
    inc l                                   ; \
    ld a, [PlayerY]                         ; | MissileY = PlayerY - 12
    sub 10                                  ; |
    ld [hli], a                             ; /
    xor a                                   ; \
    ld [hli], a                             ; | MissileY low byte = 0
    ld [hli], a                             ; | MissileYSpeed = 0
    ld [hli], a                             ; /
    ld l, LOW(Missile1Vars) + MissileSprite ; \
    ld c, [hl]                              ; |
    ld b, HIGH(SpriteBuffer)                ; |
    inc c                                   ; | Sprite Attributes = No Flip
    inc c                                   ; |
    inc c                                   ; |
    ld [bc], a                              ; /
    ld l, LOW(Missile1Vars) + MissileCollisionFlags ; \
    ld a, %00000100                                 ; | Collision Flags = Collide with Enemies
    ld [hl], a                                      ; /
    ret

; Fire an enemy missile
; Will "dynamically" allocate any missile other than missile 1 (reserved for player)
; If there aren't any missiles available, nothing will happen.
; Input - B = Missile X
; Input - C = Missile Y
; Sets  - H L A to garbage
fireEnemyMissile::
    ld hl, Missile2Vars + MissileState      ; \
    ld a, %01                               ; | Set state to Active and Moving Down
    ld [hl], a                              ; /
    ld l, LOW(Missile1Vars) + MissileX      ; \
    ld a, b                                 ; | MissileX = B
    ld [hli], a                             ; /
    inc l                                   ; \
    ld a, c                                 ; | MissileY = C
    ld [hli], a                             ; /
    xor a                                   ; \
    ld [hli], a                             ; | MissileY low byte = 0
    ld [hli], a                             ; | MissileYSpeed = 0
    ld [hli], a                             ; /
    ld l, LOW(Missile1Vars) + MissileSprite ; \
    ld c, [hl]                              ; |
    ld b, HIGH(SpriteBuffer)                ; |
    inc c                                   ; | Sprite Attributes = Y Flip Enabled
    inc c                                   ; |
    inc c                                   ; |
    ld a, OAMF_YFLIP                        ; |
    ld [bc], a                              ; /
    ld l, LOW(Missile1Vars) + MissileCollisionFlags ; \
    ld a, %00000010                                 ; | Collision Flags = Collide with Player
    ld [hl], a                                      ; /
    ret