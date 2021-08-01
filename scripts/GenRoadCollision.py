# Generates the table of road collision data
# Arg 1 = Destination File Path
# Arg 2 = Road Tilemap Input
import sys

tiles = {
    0x00: [8, 8, 8, 8, 8, 8, 8, 8], # filled in side block
    0x01: [3, 3, 3, 3, 3, 3, 3, 3], # left side straight border
    0x02: [0, 0, 0, 0, 0, 0, 0, 0], # empty space block
    0x03: [3, 4, 4, 5, 5, 6, 6, 7],
    0x04: [7, 8, 8, 8, 8, 8, 8, 8],
    0x05: [0, 0, 0, 1, 1, 2, 2, 3],
    0x06: [7, 6, 6, 5, 5, 4, 4, 3],
    0x07: [8, 8, 8, 8, 8, 8, 8, 7],
    0x08: [3, 2, 2, 1, 1, 0, 0, 0],
    0x09: [3, 3, 3, 3, 3, 3, 3, 3], # right side straight border
    0x0A: [3, 4, 4, 5, 5, 6, 6, 7],
    0x0B: [0, 0, 0, 1, 1, 2, 2, 3],
    0x0C: [7, 8, 8, 8, 8, 8, 8, 8],
    0x0D: [7, 6, 6, 5, 5, 4, 4, 3],
    0x0E: [3, 2, 2, 1, 1, 0, 0, 0],
    0x0F: [8, 8, 8, 8, 8, 8, 8, 7]
}

# Gameboy X resolution = 160
# REMINDER: Sprite coordinates are adjusted by -8
# so the actual on-screen limits are (8, 168)

destFilePath = sys.argv[1]
tilemapPath = sys.argv[2]

tilemap = []
with open(tilemapPath, "rb") as f:
    tilemap = f.read()

fileData = []
for tileLine in range(0, 64): # Left side lines in the file
    for pixLine in range (7, -1, -1): # populate tile lines backwards (forwards is (0, 8))
        totalX = -16 # account for the screen shake buffer of 2 tiles
        for tile in range(0, 12):
            totalX += tiles[tilemap[(tileLine * 12) + tile]][pixLine]
        fileData.append(totalX + 8)
        fileData.append(0) # Type = Slope / Wall
for tileLine in range(64, 128): # Left side lines in the file
    for pixLine in range (7, -1, -1):
        totalX = -16 # account for the screen shake buffer of 2 tiles
        for tile in range(0, 12):
            totalX += tiles[tilemap[(tileLine * 12) + tile]][pixLine]
        fileData.append(168 - totalX)
        fileData.append(0) # Type = Slope / Wall


with open(destFilePath, "wb+") as f:
    f.write(bytearray(fileData))