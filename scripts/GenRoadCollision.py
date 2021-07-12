# Generates the table of road collision data
# Arg 1 = Destination File Path
# Arg 2 = Road Tilemap Input
import sys

tiles = {
    0x80: [8, 8, 8, 8, 8, 8, 8, 8], # filled in side block
    0x81: [3, 3, 3, 3, 3, 3, 3, 3], # left side straight border
    0x82: [0, 0, 0, 0, 0, 0, 0, 0], # empty space block
    0x83: [3, 4, 4, 5, 5, 6, 6, 7],
    0x84: [7, 8, 8, 8, 8, 8, 8, 8],
    0x85: [0, 0, 0, 1, 1, 2, 2, 3],
    0x86: [7, 6, 6, 5, 5, 4, 4, 3],
    0x87: [8, 8, 8, 8, 8, 8, 8, 7],
    0x88: [3, 2, 2, 1, 1, 0, 0, 0],
    0x89: [3, 3, 3, 3, 3, 3, 3, 3], # right side straight border
    0x8A: [3, 4, 4, 5, 5, 6, 6, 7],
    0x8B: [0, 0, 0, 1, 1, 2, 2, 3],
    0x8C: [7, 8, 8, 8, 8, 8, 8, 8],
    0x8D: [7, 6, 6, 5, 5, 4, 4, 3],
    0x8E: [3, 2, 2, 1, 1, 0, 0, 0],
    0x8F: [8, 8, 8, 8, 8, 8, 8, 7]
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