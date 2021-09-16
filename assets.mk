GFX = rgbgfx
PYTHON = python
ADDOFFSET = $(PYTHON) scripts/AddBinaryOffset.py
#SWAPATTR = $(PYTHON) scripts/SwapFlipBits.py
ROADCOLGEN = $(PYTHON) scripts/GenRoadCollision.py
CARCOLGEN = $(PYTHON) scripts/GenCarCollision.py
CURVEBARGEN = $(PYTHON) scripts/GenCurvedBarTilemap.py

RESDIR = res
MAPSDIR = staticres
ASSETSDIR = Assets

ifneq ($(OS),Windows_NT)
	# POSIX OSes
	RM_RF := rm -rf
	MKDIR_P := mkdir -p
else
	# Windows
	RM_RF := -del /q
	MKDIR_P := -mkdir
endif

all: road player policecar gameui explosion title font helicopter missile garage

road: $(RESDIR)/lines.2bpp $(RESDIR)/lines.tilemap $(RESDIR)/roadcollision.bin
player: $(RESDIR)/starterCar.2bpp $(RESDIR)/truck.2bpp
policecar: $(RESDIR)/policecar.2bpp $(RESDIR)/policecar.tilemap $(RESDIR)/policecarcol.bin
helicopter: $(RESDIR)/helicopter.2bpp $(RESDIR)/helicopterExplode.2bpp
missile: $(RESDIR)/missile.2bpp
gameui: $(RESDIR)/statusbar.2bpp $(RESDIR)/curvebar.tilemap $(RESDIR)/menubar.2bpp $(RESDIR)/menubar.tilemap
explosion: $(RESDIR)/explosion1.2bpp
title: $(RESDIR)/title.2bpp $(RESDIR)/title.tilemap $(RESDIR)/titleScreenBottom.2bpp $(RESDIR)/titleScreenBottom.tilemap
font: $(RESDIR)/font.2bpp
garage: $(RESDIR)/garage.2bpp $(RESDIR)/garage.tilemap $(RESDIR)/garageObjects.2bpp

$(RESDIR)/lines.2bpp $(RESDIR)/lines.tilemap: $(ASSETSDIR)/lines.png | $(RESDIR)
	$(GFX) -u -o $(RESDIR)/lines.2bpp -t $(RESDIR)/lines.tilemap $(ASSETSDIR)/lines.png
#	$(ADDOFFSET) $(RESDIR)/lines.tilemap $(RESDIR)/lines.tilemap 0

$(RESDIR)/starterCar.2bpp: $(ASSETSDIR)/starterCar.png | $(RESDIR)
	$(GFX) -h -o $(RESDIR)/starterCar.2bpp $(ASSETSDIR)/starterCar.png
$(RESDIR)/truck.2bpp: $(ASSETSDIR)/truck.png | $(RESDIR)
	$(GFX) -h -o $(RESDIR)/truck.2bpp $(ASSETSDIR)/truck.png

$(RESDIR)/policecar.2bpp $(RESDIR)/policecar.tilemap: $(ASSETSDIR)/policecar.png | $(RESDIR)
	$(GFX) -h -o $(RESDIR)/policecar.2bpp $(ASSETSDIR)/policecar.png
	$(ADDOFFSET) $(MAPSDIR)/policecar.tilemap $(RESDIR)/policecar.tilemap 16

$(RESDIR)/explosion1.2bpp: $(ASSETSDIR)/explosion1.png | $(RESDIR)
	$(GFX) -h -o $(RESDIR)/explosion1.2bpp $(ASSETSDIR)/explosion1.png

$(RESDIR)/policecarcol.bin: | $(RESDIR)
	$(CARCOLGEN) $(RESDIR)/policecarcol.bin 2.3

$(RESDIR)/helicopter.2bpp: $(ASSETSDIR)/helicopter.png | $(RESDIR)
	$(GFX) -h -o $(RESDIR)/helicopter.2bpp $(ASSETSDIR)/helicopter.png

$(RESDIR)/helicopterExplode.2bpp: $(ASSETSDIR)/helicopterExplode.png | $(RESDIR)
	$(GFX) -h -o $(RESDIR)/helicopterExplode.2bpp $(ASSETSDIR)/helicopterExplode.png

$(RESDIR)/missile.2bpp: $(ASSETSDIR)/missile.png | $(RESDIR)
	$(GFX) -h -o $(RESDIR)/missile.2bpp $(ASSETSDIR)/missile.png

$(RESDIR)/roadcollision.bin: $(RESDIR)/lines.tilemap | $(RESDIR)
	$(ROADCOLGEN) $(RESDIR)/roadcollision.bin $(RESDIR)/lines.tilemap

$(RESDIR)/statusbar.2bpp: $(ASSETSDIR)/statusbar.png | $(RESDIR)
	$(GFX) -x 3 -o $(RESDIR)/statusbar.2bpp $(ASSETSDIR)/statusbar.png

$(RESDIR)/curvebar.tilemap: | $(RESDIR)
	$(CURVEBARGEN) $(RESDIR)/curvebar.tilemap

$(RESDIR)/menubar.2bpp $(RESDIR)/menubar.tilemap: $(ASSETSDIR)/menubar.png | $(RESDIR)
	$(GFX) -u -o $(RESDIR)/menubar.2bpp -t $(RESDIR)/menubar.tilemap $(ASSETSDIR)/menubar.png

$(RESDIR)/title.2bpp $(RESDIR)/title.tilemap: $(ASSETSDIR)/title.png | $(RESDIR)
	$(GFX) -u -o $(RESDIR)/title.2bpp -t $(RESDIR)/title.tilemap $(ASSETSDIR)/title.png
	$(ADDOFFSET) $(RESDIR)/title.tilemap $(RESDIR)/title.tilemap 23

$(RESDIR)/titleScreenBottom.2bpp $(RESDIR)/titleScreenBottom.tilemap: $(ASSETSDIR)/titleScreenBottom.png | $(RESDIR)
	$(GFX) -u -o $(RESDIR)/titleScreenBottom.2bpp -t $(RESDIR)/titleScreenBottom.tilemap $(ASSETSDIR)/titleScreenBottom.png
	$(ADDOFFSET) $(RESDIR)/titleScreenBottom.tilemap $(RESDIR)/titleScreenBottom.tilemap -52

$(RESDIR)/garage.2bpp $(RESDIR)/garage.tilemap: $(ASSETSDIR)/garage.png | $(RESDIR)
	$(GFX) -u -o $(RESDIR)/garage.2bpp -t $(RESDIR)/garage.tilemap $(ASSETSDIR)/garage.png

$(RESDIR)/garageObjects.2bpp: $(ASSETSDIR)/garageObjects.png | $(RESDIR)
	$(GFX) -u -o $(RESDIR)/garageObjects.2bpp $(ASSETSDIR)/garageObjects.png

$(RESDIR)/font.2bpp: $(ASSETSDIR)/font.png | $(RESDIR)
	$(GFX) -x 13 -o $(RESDIR)/font.2bpp $(ASSETSDIR)/font.png

$(RESDIR):
	$(MKDIR_P) $(RESDIR)

clean:
	$(RM_RF) $(RESDIR)