CHARMAP "A", 0
CHARMAP "B", "A" + 1
CHARMAP "C", "A" + 2
CHARMAP "D", "A" + 3
CHARMAP "E", "A" + 4
CHARMAP "F", "A" + 5
CHARMAP "G", "A" + 6
CHARMAP "H", "A" + 7
CHARMAP "I", "A" + 8
CHARMAP "J", "A" + 9
CHARMAP "K", "A" + 10
CHARMAP "L", "A" + 11
CHARMAP "M", "A" + 12
CHARMAP "N", "A" + 13
CHARMAP "O", "A" + 14
CHARMAP "P", "A" + 15
CHARMAP "Q", "A" + 16
CHARMAP "R", "A" + 17
CHARMAP "S", "A" + 18
CHARMAP "T", "A" + 19
CHARMAP "U", "A" + 20
CHARMAP "V", "A" + 21
CHARMAP "W", "A" + 22
CHARMAP "X", "A" + 23
CHARMAP "Y", "A" + 24
CHARMAP "Z", "A" + 25
CHARMAP "-", 26
CHARMAP " ", 27
CHARMAP "<e>", -1 ; Marks the end of the string

SECTION "Strings", ROMX
PausedString:: DB "- PAUSED -<e>"
ResumeString:: DB "RESUME<e>"
MenuString:: DB "MENU<e>"