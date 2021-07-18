INCLUDE "hardware.inc/hardware.inc"

SECTION "VRAM 8000", VRAM[_VRAM8000]
PlayerTilesVRAM::
    DS 10 * 16 ; 10 tiles * 16 bytes per tile
PlayerTilesVRAMEnd::
PoliceCarTilesVRAM::
    DS 12 * 16 ; 12 tiles * 16 bytes per tile
PoliceCarTilesVRAMEnd::

SECTION "VRAM 8800", VRAM[_VRAM8800]
RoadTilesVRAM::
    DS 16 * 16 ; 16 tiles * 16 bytes per tile
RoadTilesVRAMEnd::

; Each collision array entry:
; Byte 1 = Layer Flags (each bit is a different layer, only objs with the same layer bit set will collide)
; Byte 2 = Y Position (of top)
; Byte 3 = Y Position (of bottom)
; Byte 4 = X Position (of left)
; Byte 5 = X Position (of right)
SECTION "ObjCollisionArray", WRAM0, ALIGN[6]
ObjCollisionArray::
    DS 5 * 10 ; 5 bytes * 10 collision objects. Don't think all 10 slots are used, could reduce this later?
ObjCollisionArrayEnd::

SECTION "StackArea", WRAM0[$DF00]
    DS $FF ; Reserve 255 bytes for the stack at the end of WRAM.

SECTION "Scratchpad", HRAM
Scratchpad::
    DS 16 ; Reserve 16 bytes for use as a data scratchpad