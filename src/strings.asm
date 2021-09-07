NEWCHARMAP MainMenuCharmap
CHARMAP "<E>", 0 ; End of String
CHARMAP "A", $83
CHARMAP "B", "A" + 1
CHARMAP "C", "B" + 1
CHARMAP "D", "C" + 1
CHARMAP "E", "D" + 1
CHARMAP "F", "E" + 1
CHARMAP "G", "F" + 1
CHARMAP "H", "G" + 1
CHARMAP "I", "H" + 1
CHARMAP "J", "I" + 1
CHARMAP "K", "J" + 1
CHARMAP "L", "K" + 1
CHARMAP "M", "L" + 1
CHARMAP "N", "M" + 1
CHARMAP "O", "N" + 1
CHARMAP "P", "O" + 1
CHARMAP "Q", "P" + 1
CHARMAP "R", "Q" + 1
CHARMAP "S", "R" + 1
CHARMAP "T", "S" + 1
CHARMAP "U", "T" + 1
CHARMAP "V", "U" + 1
CHARMAP "W", "V" + 1
CHARMAP "X", "W" + 1
CHARMAP "Y", "X" + 1
CHARMAP "Z", "Y" + 1

SECTION "Strings", ROM0
; Main Menu options
MM_PlayString:: DB "PLAY<E>"
MM_GarageString:: DB "GARAGE<E>"
MM_SettingsString:: DB "SETTINGS<E>"
MM_InfoString:: DB "INFO<E>"