INCLUDE "charmaps.inc"

RSRESET
DEF CARINFO_GFXADDR RB 2
DEF CARINFO_NAME1 RB 7
DEF CARINFO_NAME2 RB 7
DEF CARINFO_SPEEDBARS RB 1 ; 0 to 8
DEF CARINFO_WEIGHTBARS RB 1
DEF CARINFO_MISSILEBARS RB 1
DEF CARINFO_SPECIALBARS RB 1
DEF CARINFO_UPGR_SPEEDBARS RB 1
DEF CARINFO_UPGR_WEIGHTBARS RB 1
DEF CARINFO_UPGR_MISSILEBARS RB 1
DEF CARINFO_UPGR_SPECIALBARS RB 1
DEF CARINFO_DESC RB 9 * 7 ; 9 chars * 7 lines
DEF CARINFO_PRICE RB 2 ; Little endian BCD
DEF CARINFO_UPGRADEPRICE RB 2 ; Little endian BCD
DEF CARINFO_XSPEED RB 2 ; Big endian
DEF CARINFO_YSPEED RB 2
DEF CARINFO_YACCEL RB 2
DEF CARINFO_MISSILECHG RB 1
DEF CARINFO_SPECIALCHG RB 1
DEF CARINFO_KNOCKSLOWDOWN RB 1
DEF CARINFO_UPGR_XSPEED RB 2 ; Big endian
DEF CARINFO_UPGR_YSPEED RB 2
DEF CARINFO_UPGR_YACCEL RB 2
DEF CARINFO_UPGR_MISSILECHG RB 1
DEF CARINFO_UPGR_SPECIALCHG RB 1
DEF CARINFO_UPGR_KNOCKSLOWDOWN RB 1
DEF sizeof_CARINFO RB 0

ASSERT sizeof_CARINFO <= 256 ; can not be larger than a page
EXPORT CARINFO_GFXADDR, CARINFO_NAME1, CARINFO_UPGR_SPEEDBARS, CARINFO_DESC, CARINFO_PRICE, CARINFO_UPGRADEPRICE, CARINFO_XSPEED, CARINFO_UPGR_XSPEED

SETCHARMAP MainMenuCharmap

SECTION "StarterCar Info", ROMX, ALIGN[8]
FirstCarInfo::
DW StarterCarTiles
DB "CLASSIC"
DB "       "
DB 5 ; Speed
DB 4 ; Weight
DB 3 ; Missile
DB 0 ; Special
DB 5 ; Upgraded Speed
DB 5 ; Upgraded Weight
DB 4 ; Upgraded Missile
DB 0 ; Upgraded Special
DB "Your mom "
DB "gave it  "
DB "to you.  "
DB "         "
DB "         "
DB "Special: "
DB "None     "
DW $0000 ; Car Price
DW $0500 ; Upgrade Price
DB $01, $7F ; X Speed       -- BASE STATS --
DB $00, $60 ; Y Speed
DB $00, $07 ; Y Acceleration
DB $40 ; Missile Charge Speed (lower = faster)
DB $00 ; Special Charge Speed (lower = faster, 0 = disabled)
DB 30 ; Knockback Slowdown (higher value = faster slowdown / higher weight)
DB $01, $7F ; X Speed       -- UPGRADED STATS --
DB $00, $60 ; Y Speed
DB $00, $07 ; Y Acceleration
DB $35 ; Missile Charge Speed (lower = faster)
DB $00 ; Special Charge Speed (lower = faster, 0 = disabled)
DB 34 ; Knockback Slowdown (higher value = faster slowdown / higher weight)

SECTION "Truck Info", ROMX, ALIGN[8]
DW TruckTiles
DB " TRUCK "
DB "       "
DB 4 ; Speed
DB 6 ; Weight
DB 3 ; Missile
DB 2 ; Special
DB 5 ; Upgraded Speed
DB 6 ; Upgraded Weight
DB 4 ; Upgraded Missile
DB 3 ; Upgraded Special
DB "Big and  "
DB "beefy.   "
DB "         "
DB "         "
DB "Special: "
DB "Drop a   "
DB "rock     "
DW $1000 ; Car Price
DW $1500 ; Upgrade Price
DB $01, $20 ; X Speed       -- BASE STATS --
DB $00, $45 ; Y Speed
DB $00, $05 ; Y Acceleration
DB $40 ; Missile Charge Speed (lower = faster)
DB $48 ; Special Charge Speed (lower = faster, 0 = disabled)
DB 38 ; Knockback Slowdown (higher value = faster slowdown / higher weight)
DB $01, $50 ; X Speed       -- UPGRADED STATS --
DB $00, $52 ; Y Speed
DB $00, $06 ; Y Acceleration
DB $35 ; Missile Charge Speed (lower = faster)
DB $40 ; Special Charge Speed (lower = faster, 0 = disabled)
DB 38 ; Knockback Slowdown (higher value = faster slowdown / higher weight)