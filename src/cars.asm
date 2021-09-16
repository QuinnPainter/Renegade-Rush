INCLUDE "charmaps.inc"

RSRESET
DEF CARINFO_GFXADDR RB 2
DEF CARINFO_NAME1 RB 7
DEF CARINFO_NAME2 RB 7
DEF CARINFO_DESC RB 9 * 7 ; 9 chars * 7 lines
DEF CARINFO_SPEEDBARS RB 1 ; 0 to 8
DEF CARINFO_WEIGHTBARS RB 1
DEF CARINFO_MISSILEBARS RB 1
DEF CARINFO_SPECIALBARS RB 1
DEF sizeof_CARINFO RB 0

ASSERT sizeof_CARINFO <= 256 ; can not be larger than a page
EXPORT CARINFO_GFXADDR, CARINFO_NAME1

DEF NUM_PLAYER_CARS EQU 2
EXPORT NUM_PLAYER_CARS

SETCHARMAP MainMenuCharmap

SECTION "StarterCar Info", ROMX, ALIGN[8]
FirstCarInfo::
DW StarterCarTiles
DB "CLASSIC"
DB "       "
DB "Your mom "
DB "gave it  "
DB "to you.  "
DB "         "
DB "         "
DB "Special: "
DB "None     "
DB 5
DB 4
DB 3
DB 0

SECTION "Truck Info", ROMX, ALIGN[8]
DW TruckTiles
DB " TRUCK "
DB "       "
DB "Big and  "
DB "beefy.   "
DB "         "
DB "         "
DB "Special: "
DB "Drop a   "
DB "rock     "
DB 4
DB 6
DB 3
DB 2