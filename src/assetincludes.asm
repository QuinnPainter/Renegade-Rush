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

; Screen Shake
    compact_incbin ScreenShakeLUT, "res/screenShakeLUT.bin", ROMX

; Road
    compact_incbin RoadTiles1, "res/lines.2bpp", ROMX
    compact_incbin RoadTiles2, "res/lines2.2bpp", ROMX
    compact_incbin RoadTiles3, "res/lines3.2bpp", ROMX
    compact_incbin RoadTiles4, "res/lines4.2bpp", ROMX
    compact_incbin RoadTilemap, "res/lines.tilemap", ROMX
    compact_incbin RoadCollisionROM, "res/roadcollision.bin", ROMX

; Player Car
    compact_incbin StarterCarTiles, "res/starterCar.2bpp", ROMX
    compact_incbin TruckTiles, "res/truck.2bpp", ROMX
    compact_incbin TimeCarTiles, "res/timecar.2bpp", ROMX
    compact_incbin PlayerTilemap, "staticres/player.tilemap", ROMX
    compact_incbin PlayerAttrmap, "staticres/player.attrmap", ROMX

; Police Car
    compact_incbin PoliceCarTiles, "res/policecar.2bpp", ROMX
    compact_incbin PoliceCarTilemap, "staticres/policecar.tilemap", ROMX
    compact_incbin PoliceCarAttrmap, "staticres/policecar.attrmap", ROMX
    compact_incbin PoliceCarCollision, "res/policecarcol.bin", ROMX
    compact_incbin PoliceHeavyTiles, "res/policeheavy.2bpp", ROMX

; Helicopter
    compact_incbin HelicopterTiles, "res/helicopter.2bpp", ROMX

; Missile
    compact_incbin MissileTiles, "res/missile.2bpp", ROMX

; Explosions
    compact_incbin Explosion1Tiles, "res/explosion1.2bpp", ROMX
    compact_incbin HelicopterExplosionTiles, "res/helicopterExplode.2bpp", ROMX

; Game UI
    compact_incbin StatusBar, "res/statusbar.2bpp", ROMX
    compact_incbin_align CurveBarTilemap, "res/curvebar.tilemap", ROMX, 6
    compact_incbin MenuBarTiles, "res/menubar.2bpp", ROMX
    compact_incbin MenuBarTilemap, "res/menubar.tilemap", ROMX

; Title Screen / Main Menu
    compact_incbin TitleTiles, "res/title.2bpp", ROMX
    compact_incbin TitleTilemap, "res/title.tilemap", ROMX
    compact_incbin TitleScreenBottomTiles, "res/titleScreenBottom.2bpp", ROMX
    compact_incbin TitleScreenBottomTilemap, "res/titleScreenBottom.tilemap", ROMX
    compact_incbin FontTiles, "res/font.2bpp", ROMX

; Garage
    compact_incbin FontPSwapTiles, "res/fontPSwap.2bpp", ROMX
    compact_incbin GarageTiles, "res/garage.2bpp", ROMX
    compact_incbin GarageTilemap, "res/garage.tilemap", ROMX
    compact_incbin GarageObjectTiles, "res/garageObjects.2bpp", ROMX

; Road Object Stuff
    compact_incbin WarningTiles, "res/warning.2bpp", ROMX
SECTION "RoadObjectTiles", ROMX
INCBIN "res/boulder.2bpp"
INCBIN "res/boulder2.2bpp"
INCBIN "res/barrel.2bpp"
INCBIN "res/dirtpile.2bpp"
INCBIN "res/hole.2bpp"
INCBIN "res/manhole.2bpp"
INCBIN "res/stump.2bpp"
INCBIN "res/cube.2bpp"