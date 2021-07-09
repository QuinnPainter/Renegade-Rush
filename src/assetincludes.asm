SECTION "Tiles", ROM0
Tiles::
INCBIN "res/lines.2bpp"
TilesEnd::

SECTION "Tilemap", ROM0
Tilemap::
INCBIN "res/lines.tilemap"
TilemapEnd::

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