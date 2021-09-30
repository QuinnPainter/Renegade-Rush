include "include/hUGE.inc"

SECTION "Song Data", ROMX

MUSIC_INGAME::
db 6
dw order_cnt
dw order1, order2, order3, order4
dw duty_instruments, wave_instruments, noise_instruments
dw routines
dw waves

order_cnt: db 36
order1: dw P26,P26,P26,P26,P9,P27,P9,P13,P30,P37,P39,P39,P39,P0,P44,P33,P21,P17
order2: dw P1,P1,P10,P10,P10,P10,P10,P10,P31,P31,P10,P10,P39,P0,P0,P34,P22,P18
order3: dw P2,P8,P2,P8,P2,P8,P2,P8,P29,P38,P41,P8,P39,P0,P0,P35,P23,P25
order4: dw P3,P3,P12,P12,P12,P12,P12,P12,P32,P32,P42,P43,P43,P0,P0,P36,P24,P20

P0:
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn E_4,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn G_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P1:
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P2:
 dn A_3,7,$E05
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn G#3,7,$E05
 dn A_3,6,$000
 dn B_3,7,$E05
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,6,$000

P3:
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P8:
 dn A_3,7,$E05
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn G#3,7,$E05
 dn A_3,6,$000
 dn E_4,7,$E05
 dn E_4,6,$000
 dn E_4,7,$E05
 dn E_4,7,$000
 dn E_4,6,$000
 dn E_4,7,$E05
 dn E_4,7,$000
 dn E_4,6,$000
 dn E_4,7,$E05
 dn E_4,7,$000
 dn E_4,6,$000
 dn E_4,7,$E05
 dn E_4,7,$000
 dn E_4,6,$000
 dn E_4,7,$E05
 dn E_4,6,$000
 dn E_4,7,$E05
 dn E_4,6,$000
 dn E_4,7,$E05
 dn E_4,7,$000
 dn E_4,6,$000
 dn E_4,7,$E05
 dn E_4,7,$000
 dn E_4,6,$000
 dn E_4,7,$E05
 dn E_4,7,$000
 dn E_4,6,$000
 dn E_4,7,$E05
 dn E_4,7,$000
 dn E_4,6,$000
 dn E_4,7,$E05
 dn E_4,6,$000

P9:
 dn A_3,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn E_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_3,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_3,6,$000
 dn ___,0,$000
 dn E_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_3,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn E_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_3,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn E_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_3,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000

P10:
 dn B_3,9,$24A
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,9,$24A
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn B_3,9,$24A
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,9,$24A
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn B_3,9,$24A
 dn ___,0,$000
 dn C_4,9,$24A
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn B_3,9,$24A
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,9,$24A
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn B_3,9,$24A
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,9,$24A
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn B_3,9,$24A
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,9,$24A
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn B_3,9,$24A
 dn ___,0,$000
 dn C_4,9,$24A
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn B_3,9,$24A
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,9,$24A
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P12:
 dn A#5,3,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P13:
 dn A_3,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn E_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_3,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_3,6,$000
 dn ___,0,$000
 dn E_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_3,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn E_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_3,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn E_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_3,6,$000
 dn ___,0,$000

P17:
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P18:
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P20:
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P21:
 dn A_3,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn E_4,6,$000
 dn ___,0,$000
 dn D#4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn E_3,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P22:
 dn B_3,9,$24A
 dn ___,0,$24A
 dn ___,0,$24A
 dn ___,0,$000
 dn C_4,9,$24A
 dn ___,0,$24A
 dn ___,0,$24A
 dn ___,0,$000
 dn B_3,9,$24A
 dn ___,0,$24A
 dn ___,0,$24A
 dn ___,0,$000
 dn C_4,9,$24A
 dn ___,0,$24A
 dn ___,0,$24A
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn B_3,9,$24A
 dn ___,0,$24A
 dn C_4,9,$24A
 dn ___,0,$24A
 dn ___,0,$24A
 dn ___,0,$000
 dn B_3,9,$24A
 dn ___,0,$24A
 dn ___,0,$24A
 dn ___,0,$000
 dn C_4,9,$24A
 dn ___,0,$24A
 dn ___,0,$24A
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P23:
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P24:
 dn A#5,3,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P25:
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P26:
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P27:
 dn A_3,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn E_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_3,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_3,6,$000
 dn ___,0,$000
 dn E_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_3,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn E_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_3,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn E_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_3,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000

P29:
 dn D_4,7,$E05
 dn D_4,6,$000
 dn D_4,7,$E05
 dn D_4,7,$000
 dn D_4,6,$000
 dn D_4,7,$E05
 dn D_4,7,$000
 dn D_4,6,$000
 dn D_4,7,$E05
 dn D_4,7,$000
 dn D_4,6,$000
 dn D_4,7,$E05
 dn D_4,7,$000
 dn D_4,6,$000
 dn D_4,7,$E05
 dn D_4,6,$000
 dn D_4,7,$E05
 dn D_4,6,$000
 dn D_4,7,$E05
 dn D_4,7,$000
 dn D_4,6,$000
 dn D_4,7,$E05
 dn D_4,7,$000
 dn D_4,6,$000
 dn D_4,7,$E05
 dn D_4,7,$000
 dn D_4,6,$000
 dn D_4,7,$E05
 dn D_4,7,$000
 dn D_4,6,$000
 dn G#3,7,$E05
 dn A_3,6,$000
 dn B_3,7,$E05
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,6,$000

P30:
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn G#3,6,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn A#3,6,$000
 dn ___,0,$000

P31:
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P32:
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P33:
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn E_4,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn G_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn G_3,6,$000
 dn ___,0,$000
 dn E_4,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn G_3,6,$000
 dn ___,0,$000
 dn G_3,6,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn E_4,6,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn G_3,6,$000
 dn ___,0,$000
 dn G_3,6,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn E_4,6,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn G_3,6,$000
 dn ___,0,$000
 dn G_3,6,$000
 dn C_4,6,$000
 dn ___,0,$000

P34:
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P35:
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P36:
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000

P37:
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn A_3,6,$000
 dn ___,0,$000
 dn G#3,6,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn B_3,6,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn C_4,6,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P38:
 dn D_4,7,$E05
 dn D_4,6,$000
 dn D_4,7,$E05
 dn D_4,7,$000
 dn D_4,6,$000
 dn D_4,7,$E05
 dn D_4,7,$000
 dn D_4,6,$000
 dn D_4,7,$E05
 dn D_4,7,$000
 dn D_4,6,$000
 dn D_4,7,$E05
 dn D_4,7,$000
 dn D_4,6,$000
 dn D_4,7,$E05
 dn D_4,6,$000
 dn D_4,7,$E05
 dn D_4,6,$000
 dn D_4,7,$E05
 dn D_4,7,$000
 dn D_4,6,$000
 dn D_4,7,$E05
 dn D_4,7,$000
 dn D_4,6,$000
 dn D_4,7,$E05
 dn D_4,7,$000
 dn D_4,6,$000
 dn D_4,7,$E05
 dn D_4,7,$000
 dn D_4,6,$000
 dn G#3,7,$E05
 dn A_3,6,$000
 dn E_4,7,$E05
 dn E_4,6,$000
 dn E_4,7,$E05
 dn E_4,7,$000
 dn E_4,6,$000
 dn E_4,7,$E05
 dn E_4,7,$000
 dn E_4,6,$000
 dn E_4,7,$E05
 dn E_4,7,$000
 dn E_4,6,$000
 dn E_4,7,$E05
 dn E_4,7,$000
 dn E_4,6,$000
 dn E_4,7,$E05
 dn E_4,6,$000
 dn F_4,7,$E05
 dn F_4,6,$000
 dn F_4,7,$E05
 dn F_4,7,$000
 dn F_4,6,$000
 dn F_4,7,$E05
 dn F_4,7,$000
 dn F_4,6,$000
 dn F_4,7,$E05
 dn F_4,7,$000
 dn F_4,6,$000
 dn F_4,7,$E05
 dn F_4,7,$000
 dn F_4,6,$000
 dn F_4,7,$E05
 dn F_4,6,$000

P39:
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P41:
 dn A_3,7,$E05
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn A_3,7,$E05
 dn A_3,7,$000
 dn A_3,6,$000
 dn G#3,7,$E05
 dn A_3,6,$000
 dn B_3,7,$E05
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,7,$000
 dn B_3,6,$000
 dn B_3,7,$E05
 dn B_3,6,$000

P42:
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000

P43:
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn A#5,3,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$000
 dn D_7,2,$000
 dn ___,0,$000
 dn D_7,1,$000
 dn ___,0,$B01

P44:
 dn B_3,9,$24A
 dn ___,0,$24A
 dn ___,0,$24A
 dn ___,0,$000
 dn C_4,9,$24A
 dn ___,0,$24A
 dn ___,0,$24A
 dn ___,0,$000
 dn B_3,9,$24A
 dn ___,0,$24A
 dn ___,0,$24A
 dn ___,0,$000
 dn C_4,9,$24A
 dn ___,0,$24A
 dn ___,0,$24A
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn B_3,9,$24A
 dn ___,0,$24A
 dn C_4,9,$24A
 dn ___,0,$24A
 dn ___,0,$24A
 dn ___,0,$000
 dn B_3,9,$24A
 dn ___,0,$24A
 dn ___,0,$24A
 dn ___,0,$000
 dn C_4,9,$24A
 dn ___,0,$24A
 dn ___,0,$24A
 dn ___,0,$000
 dn B_3,9,$24A
 dn ___,0,$24A
 dn ___,0,$24A
 dn ___,0,$000
 dn C_4,9,$24A
 dn ___,0,$24A
 dn ___,0,$24A
 dn ___,0,$000
 dn B_3,9,$24A
 dn ___,0,$24A
 dn ___,0,$24A
 dn ___,0,$000
 dn C_4,9,$24A
 dn ___,0,$24A
 dn ___,0,$24A
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn B_3,9,$24A
 dn ___,0,$24A
 dn C_4,9,$24A
 dn ___,0,$24A
 dn ___,0,$24A
 dn ___,0,$000
 dn B_3,9,$24A
 dn ___,0,$24A
 dn ___,0,$24A
 dn ___,0,$000
 dn C_4,9,$24A
 dn ___,0,$24A
 dn ___,0,$24A
 dn ___,0,$000

duty_instruments:
itSquareinst1: db 8,0,240,128
itSquareinst2: db 8,64,240,128
itSquareinst3: db 8,128,240,128
itSquareinst4: db 8,192,240,128
itSquareinst5: db 8,0,241,128
itSquareinst6: db 8,64,209,128
itSquareinst7: db 8,128,241,128
itSquareinst8: db 8,192,241,128
itSquareinst9: db 8,142,177,128
itSquareinst10: db 8,64,199,128
itSquareinst11: db 8,128,240,128
itSquareinst12: db 8,128,240,128
itSquareinst13: db 8,128,240,128
itSquareinst14: db 8,128,240,128
itSquareinst15: db 8,128,240,128


wave_instruments:
itWaveinst1: db 0,32,0,128
itWaveinst2: db 0,32,1,128
itWaveinst3: db 0,32,2,128
itWaveinst4: db 0,32,3,128
itWaveinst5: db 0,32,4,128
itWaveinst6: db 0,32,5,128
itWaveinst7: db 0,32,6,128
itWaveinst8: db 0,32,7,128
itWaveinst9: db 0,32,8,128
itWaveinst10: db 0,32,9,128
itWaveinst11: db 0,32,10,128
itWaveinst12: db 0,32,11,128
itWaveinst13: db 0,32,12,128
itWaveinst14: db 0,32,13,128
itWaveinst15: db 0,32,14,128


noise_instruments:
itNoiseinst1: db 65,118,0,0,0,0,0,0
itNoiseinst2: db 82,0,0,0,0,0,0,0
itNoiseinst3: db 161,0,12,4,0,0,0,0
itNoiseinst4: db 240,0,0,0,0,0,0,0
itNoiseinst5: db 240,0,0,0,0,0,0,0
itNoiseinst6: db 240,0,0,0,0,0,0,0
itNoiseinst7: db 240,0,0,0,0,0,0,0
itNoiseinst8: db 240,0,0,0,0,0,0,0
itNoiseinst9: db 240,0,0,0,0,0,0,0
itNoiseinst10: db 240,0,0,0,0,0,0,0
itNoiseinst11: db 240,0,0,0,0,0,0,0
itNoiseinst12: db 240,0,0,0,0,0,0,0
itNoiseinst13: db 240,0,0,0,0,0,0,0
itNoiseinst14: db 240,0,0,0,0,0,0,0
itNoiseinst15: db 240,0,0,0,0,0,0,0


routines:
__hUGE_Routine_0:

__end_hUGE_Routine_0:
ret

__hUGE_Routine_1:

__end_hUGE_Routine_1:
ret

__hUGE_Routine_2:

__end_hUGE_Routine_2:
ret

__hUGE_Routine_3:

__end_hUGE_Routine_3:
ret

__hUGE_Routine_4:

__end_hUGE_Routine_4:
ret

__hUGE_Routine_5:

__end_hUGE_Routine_5:
ret

__hUGE_Routine_6:

__end_hUGE_Routine_6:
ret

__hUGE_Routine_7:

__end_hUGE_Routine_7:
ret

__hUGE_Routine_8:

__end_hUGE_Routine_8:
ret

__hUGE_Routine_9:

__end_hUGE_Routine_9:
ret

__hUGE_Routine_10:

__end_hUGE_Routine_10:
ret

__hUGE_Routine_11:

__end_hUGE_Routine_11:
ret

__hUGE_Routine_12:

__end_hUGE_Routine_12:
ret

__hUGE_Routine_13:

__end_hUGE_Routine_13:
ret

__hUGE_Routine_14:

__end_hUGE_Routine_14:
ret

__hUGE_Routine_15:

__end_hUGE_Routine_15:
ret

waves:
wave0: db 0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255
wave1: db 0,0,0,0,255,255,255,255,255,255,255,255,255,255,255,255
wave2: db 0,0,0,0,0,0,0,0,255,255,255,255,255,255,255,255
wave3: db 0,0,0,0,0,0,0,0,0,0,0,0,255,255,255,255
wave4: db 0,1,18,35,52,69,86,103,120,137,154,171,188,205,222,239
wave5: db 254,220,186,152,118,84,50,16,18,52,86,120,154,188,222,255
wave6: db 122,205,219,117,33,19,104,189,220,151,65,1,71,156,221,184
wave7: db 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
wave8: db 254,252,250,248,246,244,242,240,242,244,246,248,250,252,254,255
wave9: db 254,221,204,187,170,153,136,119,138,189,241,36,87,138,189,238
wave10: db 132,17,97,237,87,71,90,173,206,163,23,121,221,32,3,71
wave11: db 162,42,6,221,36,136,199,194,9,84,72,194,208,23,222,29
wave12: db 110,209,68,189,216,70,58,54,118,140,133,61,56,57,164,183
wave13: db 150,104,168,21,142,64,208,24,160,93,12,67,178,10,228,88
wave14: db 234,150,19,172,26,182,149,100,19,162,177,78,13,123,186,71
wave15: db 102,173,236,39,55,147,184,148,156,146,87,203,1,38,36,157

