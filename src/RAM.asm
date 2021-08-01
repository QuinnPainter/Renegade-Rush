INCLUDE "hardware.inc/hardware.inc"

SECTION "VRAM 8000", VRAM[_VRAM8000]
PlayerTilesVRAM::
    DS 10 * 16 ; 10 tiles * 16 bytes per tile
PlayerTilesVRAMEnd::
PoliceCarTilesVRAM::
    DS 12 * 16 ; 12 tiles * 16 bytes per tile
PoliceCarTilesVRAMEnd::

SECTION "VRAM 8800", VRAM[_VRAM8800]
StatusBarVRAM::
    DS 68 * 16 ; 68 tiles * 16 bytes per tile
StatusBarVRAMEnd::
GameFontVRAM::
    DS 27 * 16
GameFontVRAMEnd::

SECTION "VRAM 9000", VRAM[_VRAM9000]
RoadTilesVRAM::
    DS 16 * 16 ; 16 tiles * 16 bytes per tile
RoadTilesVRAMEnd::

SECTION "StackArea", WRAM0[$DF00]
    DS $FF ; Reserve 255 bytes for the stack at the end of WRAM.

SECTION "Scratchpad", HRAM
Scratchpad::
    DS 16 ; Reserve 16 bytes for use as a data scratchpad