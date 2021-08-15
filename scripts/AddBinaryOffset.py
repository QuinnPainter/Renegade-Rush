# Read a binary file, and apply an offset to every number in that file
# Arg 1 = File Path
# Arg 2 = Output File Path
# Arg 3 = Offset (integer)
import sys

filePath = sys.argv[1]
outputFile = sys.argv[2]
offset = int(sys.argv[3])

with open(filePath, "rb") as f:
    fileData = f.read()

with open(outputFile, "wb+") as f:
    for byte in fileData:
        f.write(((byte + offset) & 0xFF).to_bytes(1, byteorder='big'))