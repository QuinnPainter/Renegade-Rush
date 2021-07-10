# Read a binary file, and apply an offset to every number in that file
# Arg 1 = File Path
# Arg 2 = Offset (integer)
import sys

filePath = sys.argv[1]
offset = int(sys.argv[2])

with open(filePath, "rb") as f:
    fileData = f.read()

with open(filePath, "wb+") as f:
    for byte in fileData:
        f.write(((byte + offset) & 0xFF).to_bytes(1, byteorder='big'))