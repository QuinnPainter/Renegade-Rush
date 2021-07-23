# Generates the table of car collision speed data.
# The table is indexed using the X and Y offsets between the two cars that collided
# and it gives you the X and Y knockback speed the car should now have.
# It assumes the car size is 16 * 24. This means smaller cars are possible, but will have
# lower maximum knockback values. This can be counteracted by increasing the base speed.
# Cars bigger that 16 * 24 will not work under this system.
# To index into the output table, use ((yOffset * 16) + xOffset) * 4
# Arg 1 = Destination File Path
# Arg 2 = Base Speed Value (float). Pixels Per Frame.
import sys

destFilePath = sys.argv[1]
baseSpeed = float(sys.argv[2])

fileData = []

for y in range(24):
    for x in range(16):
        if (x + y) == 0:
            xRatio = 1 # these values don't really matter
            yRatio = 0 # since they only apply if the cars perfectly overlap
        else:
            xRatio = x / (x + y)
            yRatio = y / (x + y)
        # Multiply by 256 to turn into 8.8 fixed point
        xValue = int(xRatio * baseSpeed * 256) & 0xFFFF
        yValue = int(yRatio * baseSpeed * 256) & 0xFFFF
        fileData.append(xValue)
        fileData.append(yValue)

print (len(fileData))

with open(destFilePath, "wb+") as f:
    for num in fileData: # num is 16 bit
        f.write(num.to_bytes(2, byteorder='big'))