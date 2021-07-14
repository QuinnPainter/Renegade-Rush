; Road
SECTION "Tiles", ROM0
Tiles::
INCBIN "res/lines.2bpp"
TilesEnd::

SECTION "Tilemap", ROM0
Tilemap::
INCBIN "res/lines.tilemap"
TilemapEnd::

SECTION "RoadCollisionROM", ROM0
RoadCollisionROM::
INCBIN "res/roadcollision.bin"
RoadCollisionROMEnd::

; Player Car
SECTION "PlayerTiles", ROM0
PlayerTiles::
INCBIN "res/player.2bpp"
PlayerTilesEnd::

SECTION "PlayerTilemap", ROM0
PlayerTilemap::
INCBIN "res/player.tilemap"
PlayerTilemapEnd::

SECTION "PlayerAttrmap", ROM0
PlayerAttrmap::
INCBIN "res/player.attrmap"
PlayerAttrmapEnd::

; Police Car
SECTION "PoliceCarTiles", ROM0
PoliceCarTiles::
INCBIN "res/policecar.2bpp"
PoliceCarTilesEnd::

SECTION "PoliceCarTilemap", ROM0
PoliceCarTilemap::
INCBIN "res/policecar.tilemap"
PoliceCarTilemapEnd::

SECTION "PoliceCarAttrmap", ROM0
PoliceCarAttrmap::
INCBIN "res/policecar.attrmap"
PoliceCarAttrmapEnd::