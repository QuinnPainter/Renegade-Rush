INCLUDE "charmaps.inc"

SETCHARMAP MainMenuCharmap

SECTION "MainMenuStrings", ROM0
MM_PlayString:: DB "PLAY<E>"
MM_GarageString:: DB "GARAGE<E>"
MM_SettingsString:: DB "SETTINGS<E>"
MM_InfoString:: DB "INFO<E>"
MM_BestString:: DB "BEST:      <metre><E>"

SECTION "InfoPageStrings", ROM0 ; reminder - 20 chars per screen line
INFO_Line1:: DB "<E>"
DB " Renegade Rush<E>"
DB " GBcompo21 Demo<E>"
DB " by Quinn Painter<E>"
DB "<E>"
DB " Copyright 2021<E>"
DB "<E>"
DB "   -  Credits  -<E>"
DB "<E>"
DB " WitchFont8<E>"
DB "       by Lavenfurr<E>"
DB " Spy Fighter Assets<E>"
DB "   by Chasersgaming<E>"
DB " Misc Assets<E>"
DB "  by MaterialFuture<E>"
DB "<E>"
DB " press B to return<E>", 1

SECTION "SettingsPageStrings", ROM0
SP_Header::         DB "    - SETTINGS -    <E>"
SP_Back::           DB " BACK<E>"
SP_SoundFX::        DB " SOUND FX<E>"
SP_Music::          DB " MUSIC<E>"
SP_ResetSave::      DB " RESET SAVE<E>"
SP_SelectionOn::    DB "     <selOn><E>"
SP_SelectionOff::   DB "     <selOff><E>"

SECTION "ResetSavegameStrings", ROM0
RS_Line1:: DB "<E>"
DB " - SAVEGAME RESET - <E>"
DB "<E>"
DB "<E>"
DB " This will erase<E>"
DB " all game progress<E>"
DB "<E>"
DB "<E>"
DB " Press START and A<E>"
DB " to confirm<E>"
DB "<E>"
DB "<E>"
DB " Press B to cancel<E>", 1

SECTION "GarageStrings", ROM0
GR_SpeedString:: DB "SPEED<E>"
GR_WeightString:: DB "WEIGHT<E>"
GR_MissileString:: DB "MISSILE<E>"
GR_SpecialString:: DB "SPECIAL<E>"

GR_BalanceString:: DB "BALANCE:<E>"
GR_CostString:: DB "COST:<E>"

GR_NoMoneyString1:: DB "Not<E>"
GR_NoMoneyString2:: DB "enough<E>"
GR_NoMoneyString3:: DB "money<E>"

SETCHARMAP PSwapCharmap

GR_SelectString:: DB "SELECT <E>"
GR_UpgradeString:: DB "UPGRADE<E>"
GR_BuyString:: DB "BUY    <E>"
GR_BlankString:: DB "       <E>"