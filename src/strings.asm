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
CHARMAP "a", "Z" + 1
CHARMAP "b", "a" + 1
CHARMAP "c", "b" + 1
CHARMAP "d", "c" + 1
CHARMAP "e", "d" + 1
CHARMAP "f", "e" + 1
CHARMAP "g", "f" + 1
CHARMAP "h", "g" + 1
CHARMAP "i", "h" + 1
CHARMAP "j", "i" + 1
CHARMAP "k", "j" + 1
CHARMAP "l", "k" + 1
CHARMAP "m", "l" + 1
CHARMAP "n", "m" + 1
CHARMAP "o", "n" + 1
CHARMAP "p", "o" + 1
CHARMAP "q", "p" + 1
CHARMAP "r", "q" + 1
CHARMAP "s", "r" + 1
CHARMAP "t", "s" + 1
CHARMAP "u", "t" + 1
CHARMAP "v", "u" + 1
CHARMAP "w", "v" + 1
CHARMAP "x", "w" + 1
CHARMAP "y", "x" + 1
CHARMAP "z", "y" + 1
CHARMAP "-", "z" + 1
CHARMAP "0", "-" + 1
CHARMAP "1", "0" + 1
CHARMAP "2", "1" + 1
CHARMAP "3", "2" + 1
CHARMAP "4", "3" + 1
CHARMAP "5", "4" + 1
CHARMAP "6", "5" + 1
CHARMAP "7", "6" + 1
CHARMAP "8", "7" + 1
CHARMAP "9", "8" + 1
CHARMAP ".", "9" + 1
CHARMAP ":", "." + 1
CHARMAP " ", $CC

SECTION "MainMenuStrings", ROM0
MM_PlayString:: DB "PLAY<E>"
MM_GarageString:: DB "GARAGE<E>"
MM_SettingsString:: DB "SETTINGS<E>"
MM_InfoString:: DB "INFO<E>"

SECTION "InfoPageStrings", ROM0 ; reminder - 20 chars per screen line
INFO_Line1:: DB "<E>"
DB " Renegade Rush<E>"
DB " version 0.1<E>"
DB " by Quinn Painter<E>"
DB "<E>"
DB " Copyright 2021<E>"
DB " License: MIT<E>"
DB "<E>"
DB "   -  Credits  -<E>"
DB "<E>"
DB " WitchFont 8<E>"
DB "       by Lavenfurr<E>"
DB " Spy Fighter Assets<E>"
DB "   by Chasersgaming<E>"
DB "<E>"
DB "<E>"
DB " press B to return<E>", 1