# Generates the tilemaps to draw the curved charge bars in the status bar
# this is... not amazing. surely there's a better way?
# Arg 1 = Destination File Path
import sys

# 00 00
# |   | missile = top bar
# | special = bottom bar
# tile order is top left, top right, bottom left, bottom right

# Tile indices - relative to the statusbar
TL_ON = 36 # Top Left tile
TL_OFF = 34
TR_TON_BOFF = 32 # Top Right tile
TR_TOFF_BON = 33
TR_TOFF_BOFF = 35
TR_TON_BON = 37
BL_LOFF_ROFF = 50 # Bottom Left tile
BL_LON_RON = 52
BL_LOFF_RON = 56
BL_LON_ROFF = 57
BR_LON_TOFF = 48 # Bottom Right tile
BR_LOFF_TON = 49
BR_LOFF_TOFF = 51
BR_LON_TON = 53

tilemaps = [TL_OFF, TR_TOFF_BOFF, BL_LOFF_ROFF, BR_LOFF_TOFF, # 0 = 0000 - all bars off
            TL_ON, TR_TOFF_BOFF, BL_LON_ROFF, BR_LOFF_TOFF, # 1 = 0001 - missile stage 1
            TL_OFF, TR_TON_BOFF, BL_LOFF_ROFF, BR_LOFF_TOFF, # 2 = 0010 - missile stage 2
            TL_ON, TR_TON_BOFF, BL_LON_ROFF, BR_LOFF_TOFF, # 3 = 0011 - missile stage 1 & 2
            TL_OFF, TR_TOFF_BOFF, BL_LOFF_RON, BR_LON_TOFF, # 4 = 0100 - special stage 1
            TL_ON, TR_TOFF_BOFF, BL_LON_RON, BR_LON_TOFF, # 5 = 0101 - special stage 1 & missile stage 1
            TL_OFF, TR_TON_BOFF, BL_LOFF_RON, BR_LON_TOFF, # 6 = 0110 - special stage 1 & missile stage 2
            TL_ON, TR_TON_BOFF, BL_LON_RON, BR_LON_TOFF, # 7 = 0111 - special stage 1 & missile stage 1 & 2
            TL_OFF, TR_TOFF_BON, BL_LOFF_ROFF, BR_LOFF_TON, # 8 = 1000 - special stage 2
            TL_ON, TR_TOFF_BON, BL_LON_ROFF, BR_LOFF_TON, # 9 = 1001 - special stage 2 & missile stage 1
            TL_OFF, TR_TON_BON, BL_LOFF_ROFF, BR_LOFF_TON, # 10 = 1010 - special stage 2 & missile stage 2
            TL_ON, TR_TON_BON, BL_LON_ROFF, BR_LOFF_TON, # 11 = 1011 - special stage 2 & missile stage 1 & 2
            TL_OFF, TR_TOFF_BON, BL_LOFF_RON, BR_LON_TON, # 12 = 1100 - special stage 1 & 2
            TL_ON, TR_TOFF_BON, BL_LON_RON, BR_LON_TON, # 13 = 1101 - special stage 1 & 2 & missile stage 1
            TL_OFF, TR_TON_BON, BL_LOFF_RON, BR_LON_TON, # 14 = 1110 - special stage 1 & 2 & missile stage 2
            TL_ON, TR_TON_BON, BL_LON_RON, BR_LON_TON] # 15 = 1111 - special stage 1 & 2 & missile stage 1 & 2

destFilePath = sys.argv[1]

with open(destFilePath, "wb+") as f:
    f.write(bytearray(tilemaps))