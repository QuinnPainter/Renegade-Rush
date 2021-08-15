; All-in one include macro
; \1 = Name of section
; \2 = Source file
; \3 = Destination area (ROM0 or ROMX)
MACRO compact_incbin
SECTION "\1", \3
\1::
INCBIN \2
ENDM

MACRO compact_incbin_align
SECTION "\1", \3, ALIGN[\4]
INCBIN \2
ENDM

; Road
    compact_incbin RoadTiles, "res/lines.2bpp", ROMX
    compact_incbin RoadTilemap, "res/lines.tilemap", ROMX
    compact_incbin RoadCollisionROM, "res/roadcollision.bin", ROMX

; Player Car
    compact_incbin PlayerTiles, "res/player.2bpp", ROMX
    compact_incbin PlayerTilemap, "staticres/player.tilemap", ROMX
    compact_incbin PlayerAttrmap, "staticres/player.attrmap", ROMX

; Police Car
    compact_incbin PoliceCarTiles, "res/policecar.2bpp", ROMX
    compact_incbin PoliceCarTilemap, "res/policecar.tilemap", ROMX
    compact_incbin PoliceCarAttrmap, "staticres/policecar.attrmap", ROMX
    compact_incbin PoliceCarCollision, "res/policecarcol.bin", ROMX

; Explosions
    compact_incbin Explosion1Tiles, "res/explosion1.2bpp", ROMX

; Game UI
    compact_incbin StatusBar, "res/statusbar.2bpp", ROMX
    compact_incbin_align CurveBarTilemap, "res/curvebar.tilemap", ROMX, 6
    compact_incbin MenuBarTiles, "res/menubar.2bpp", ROMX
    compact_incbin MenuBarTilemap, "res/menubar.tilemap", ROMX