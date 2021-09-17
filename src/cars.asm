INCLUDE "charmaps.inc"

RSRESET
DEF CARINFO_GFXADDR RB 2
DEF CARINFO_NAME1 RB 7
DEF CARINFO_NAME2 RB 7
DEF CARINFO_SPEEDBARS RB 1 ; 0 to 8
DEF CARINFO_WEIGHTBARS RB 1
DEF CARINFO_MISSILEBARS RB 1
DEF CARINFO_SPECIALBARS RB 1
DEF CARINFO_DESC RB 9 * 7 ; 9 chars * 7 lines
DEF CARINFO_PRICE RB 2 ; Little endian BCD
DEF CARINFO_UPGRADEPRICE RB 2 ; Little endian BCD
DEF sizeof_CARINFO RB 0

ASSERT sizeof_CARINFO <= 256 ; can not be larger than a page
EXPORT CARINFO_GFXADDR, CARINFO_NAME1, CARINFO_DESC, CARINFO_PRICE, CARINFO_UPGRADEPRICE

SETCHARMAP MainMenuCharmap

SECTION "StarterCar Info", ROMX, ALIGN[8]
FirstCarInfo::
DW StarterCarTiles
DB "CLASSIC"
DB "       "
DB 5
DB 4
DB 3
DB 0
DB "Your mom "
DB "gave it  "
DB "to you.  "
DB "         "
DB "         "
DB "Special: "
DB "None     "
DW $0000
DW $0500

SECTION "Truck Info", ROMX, ALIGN[8]
DW TruckTiles
DB " TRUCK "
DB "       "
DB 4
DB 6
DB 3
DB 2
DB "Big and  "
DB "beefy.   "
DB "         "
DB "         "
DB "Special: "
DB "Drop a   "
DB "rock     "
DW $1000
DW $1500