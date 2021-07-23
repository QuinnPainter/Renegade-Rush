; Road
SECTION "RoadTiles", ROMX
RoadTiles::
INCBIN "res/lines.2bpp"
RoadTilesEnd::

SECTION "RoadTilemap", ROMX
RoadTilemap::
INCBIN "res/lines.tilemap"
RoadTilemapEnd::

SECTION "RoadCollisionROM", ROMX
RoadCollisionROM::
INCBIN "res/roadcollision.bin"
RoadCollisionROMEnd::

; Player Car
SECTION "PlayerTiles", ROMX
PlayerTiles::
INCBIN "res/player.2bpp"
PlayerTilesEnd::

SECTION "PlayerTilemap", ROMX
PlayerTilemap::
INCBIN "res/player.tilemap"
PlayerTilemapEnd::

SECTION "PlayerAttrmap", ROMX
PlayerAttrmap::
INCBIN "res/player.attrmap"
PlayerAttrmapEnd::

; Police Car
SECTION "PoliceCarTiles", ROMX
PoliceCarTiles::
INCBIN "res/policecar.2bpp"
PoliceCarTilesEnd::

SECTION "PoliceCarTilemap", ROMX
PoliceCarTilemap::
INCBIN "res/policecar.tilemap"
PoliceCarTilemapEnd::

SECTION "PoliceCarAttrmap", ROMX
PoliceCarAttrmap::
INCBIN "res/policecar.attrmap"
PoliceCarAttrmapEnd::