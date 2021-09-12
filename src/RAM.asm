INCLUDE "hardware.inc"

; In Game VRAM

SECTION UNION "VRAM 8000", VRAM[_VRAM8000]
PlayerTilesVRAM::
    DS 12 * 16 ; 12 tiles * 16 bytes per tile
PoliceCarTilesVRAM::
    DS 18 * 16 ; 18 tiles * 16 bytes per tile
HelicopterTilesVRAM::
    DS 36 * 16
HelicopterExplosionTilesVRAM::
    DS 36 * 16
MissileTilesVRAM::
    DS 4 * 16
Explosion1TilesVRAM::
    DS 20 * 16

SECTION UNION "VRAM 8800", VRAM[_VRAM8800]
StatusBarVRAM::
    DS 61 * 16 ; 60 tiles * 16 bytes per tile
MenuBarTilesVRAM::
    DS 50 * 16 ; no idea how many tiles needed, change this later

SECTION UNION "VRAM 9000", VRAM[_VRAM9000]
RoadTilesVRAM::
    DS 16 * 16 ; 16 tiles * 16 bytes per tile

; Title Screen / Menus VRAM

RSSET (_VRAM8800 + (3 * 16))
DEF MainMenuFontVRAM RB 53 * 16 ; 53 tiles
DEF MainMenuBottomTilesVRAM RB 20 * 16 ; 20 tiles
DEF TitleBottomTilesVRAM RB 75 * 16 ; 75 tiles
DEF TitleTilesVRAM RB 105 * 16 ; 105 tiles

EXPORT TitleTilesVRAM, TitleBottomTilesVRAM, MainMenuBottomTilesVRAM, MainMenuFontVRAM


SECTION "StackArea", WRAM0[$DF00]
    DS $FF ; Reserve 255 bytes for the stack at the end of WRAM.

SECTION "Scratchpad", HRAM
Scratchpad::
    DS 16 ; Reserve 16 bytes for use as a data scratchpad