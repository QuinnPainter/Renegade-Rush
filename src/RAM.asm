INCLUDE "hardware.inc"

; In Game VRAM

SECTION "VRAM 8000", VRAM[_VRAM8000]
PlayerTilesVRAM::
    DS 16 * 16 ; 16 tiles * 16 bytes per tile
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
WarningTilesVRAM::
    DS 2 * 16

;SECTION "VRAM 8800", VRAM[_VRAM8800]
StatusBarVRAM::
    DS 61 * 16 ; 60 tiles * 16 bytes per tile
MenuBarTilesVRAM::
    DS 40 * 16
MenuBarNumbersVRAM::
    DS 10 * 16

SECTION "VRAM 9000", VRAM[_VRAM9000]
RoadTiles1VRAM::
    DS 16 * 16 ; 16 tiles * 16 bytes per tile
RoadTiles2VRAM::
    DS 16 * 16 ; 16 tiles * 16 bytes per tile
RoadTiles3VRAM::
    DS 16 * 16 ; 16 tiles * 16 bytes per tile
RoadTiles4VRAM::
    DS 16 * 16 ; 16 tiles * 16 bytes per tile

; Title Screen / Menus VRAM

RSSET (_VRAM8000)
DEF GarageTilesVRAM RB 19 * 16 ; 19 tiles
DEF GarageObjectTilesVRAM RB 7 * 16 ; 7 tiles
;DEF GCARPAD RB 16 ; CarTiles must be aligned on even number tile index
DEF GarageCarTilesVRAM RB 16 * 16 ; SAME AS PlayerTilesVRAM above
DEF FontPSwapTilesVRAM RB 26 * 16 ; 26 tiles

RSSET (_VRAM8800 + (3 * 16))
DEF MainMenuFontVRAM RB 73 * 16 ; 73 tiles (overallocated)
DEF TitleBottomTilesVRAM RB 75 * 16 ; 75 tiles
DEF TitleTilesVRAM RB 105 * 16 ; 105 tiles

EXPORT GarageTilesVRAM, GarageObjectTilesVRAM, GarageCarTilesVRAM, FontPSwapTilesVRAM
EXPORT TitleTilesVRAM, TitleBottomTilesVRAM, MainMenuFontVRAM


SECTION "StackArea", WRAM0[$DF00]
    DS $FF ; Reserve 255 bytes for the stack at the end of WRAM.

SECTION "Scratchpad", HRAM
Scratchpad::
    DS 16 ; Reserve 16 bytes for use as a data scratchpad