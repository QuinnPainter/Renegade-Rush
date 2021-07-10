# Hacky fix for the fact that RGBGFX seems to be bugged and the X and Y flip bits are swapped.
# Reads an attribute file and flips the flip bits
# Arg 1 = File Path
import sys

filePath = sys.argv[1]

with open(filePath, "rb") as f:
    fileData = f.read()

with open(filePath, "wb+") as f:
    for byte in fileData:
        newbyte = 0
        if (byte & 0x20):
            newbyte |= 0x40
        if (byte & 0x40):
            newbyte |= 0x20
        f.write((newbyte).to_bytes(1, byteorder='big'))