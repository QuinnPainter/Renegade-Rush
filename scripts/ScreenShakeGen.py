# Arg 1 = Destination File Path
import random
import math
import struct
import sys

random.seed(4) # use constant seed so build is deterministic

radius = 30
randomAngle = random.randint(1, 360)

with open(sys.argv[1], "wb") as file:
    for i in range(0, 20):
        radius *= 0.9
        randomAngle += (150 + random.randint(0, 60))
        offsetX = math.sin(randomAngle) * radius
        #offsetY = math.cos(randomAngle) * radius
        print(round(offsetX))
        file.write(struct.pack("b", round(offsetX)))
    file.write(struct.pack("b", 0)) # make sure last number is 0
    file.write(struct.pack("b", 0)) # make sure last number is 0