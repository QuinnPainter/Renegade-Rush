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

road: $(RESDIR)/lines.2bpp $(RESDIR)/lines.tilemap $(RESDIR)/roadcollision.bin $(RESDIR)/lines2.2bpp $(RESDIR)/lines3.2bpp $(RESDIR)/lines4.2bpp
player: $(RESDIR)/starterCar.2bpp $(RESDIR)/truck.2bpp
policecar: $(RESDIR)/policecar.2bpp $(RESDIR)/policecar.tilemap $(RESDIR)/policecarcol.bin
helicopter: $(RESDIR)/helicopter.2bpp $(RESDIR)/helicopterExplode.2bpp
missile: $(RESDIR)/missile.2bpp
gameui: $(RESDIR)/statusbar.2bpp $(RESDIR)/curvebar.tilemap $(RESDIR)/menubar.2bpp $(RESDIR)/menubar.tilemap
explosion: $(RESDIR)/explosion1.2bpp
title: $(RESDIR)/title.2bpp $(RESDIR)/title.tilemap $(RESDIR)/titleScreenBottom.2bpp $(RESDIR)/titleScreenBottom.tilemap
font: $(RESDIR)/font.2bpp $(RESDIR)/fontPSwap.2bpp
garage: $(RESDIR)/garage.2bpp $(RESDIR)/garage.tilemap $(RESDIR)/garageObjects.2bpp

$(RESDIR)/lines.2bpp $(RESDIR)/lines.tilemap: $(ASSETSDIR)/road/lines.png | $(RESDIR)
	$(GFX) -u -o $(RESDIR)/lines.2bpp -t $(RESDIR)/lines.tilemap $(ASSETSDIR)/road/lines.png
$(RESDIR)/lines2.2bpp: $(ASSETSDIR)/road/lines2.png | $(RESDIR)
	$(GFX) -u -o $(RESDIR)/lines2.2bpp $(ASSETSDIR)/road/lines2.png
$(RESDIR)/lines3.2bpp: $(ASSETSDIR)/road/lines3.png | $(RESDIR)
	$(GFX) -u -o $(RESDIR)/lines3.2bpp $(ASSETSDIR)/road/lines3.png
$(RESDIR)/lines4.2bpp: $(ASSETSDIR)/road/lines4.png | $(RESDIR)
	$(GFX) -u -o $(RESDIR)/lines4.2bpp $(ASSETSDIR)/road/lines4.png

$(RESDIR)/starterCar.2bpp: $(ASSETSDIR)/gameobjs/starterCar.png | $(RESDIR)
	$(GFX) -h -o $(RESDIR)/starterCar.2bpp $(ASSETSDIR)/gameobjs/starterCar.png
$(RESDIR)/truck.2bpp: $(ASSETSDIR)/gameobjs/truck.png | $(RESDIR)
	$(GFX) -h -o $(RESDIR)/truck.2bpp $(ASSETSDIR)/gameobjs/truck.png

$(RESDIR)/policecar.2bpp $(RESDIR)/policecar.tilemap: $(ASSETSDIR)/gameobjs/policecar.png | $(RESDIR)
	$(GFX) -h -o $(RESDIR)/policecar.2bpp $(ASSETSDIR)/gameobjs/policecar.png
	$(ADDOFFSET) $(MAPSDIR)/policecar.tilemap $(RESDIR)/policecar.tilemap 16

$(RESDIR)/explosion1.2bpp: $(ASSETSDIR)/gameobjs/explosion1.png | $(RESDIR)
	$(GFX) -h -o $(RESDIR)/explosion1.2bpp $(ASSETSDIR)/gameobjs/explosion1.png

$(RESDIR)/policecarcol.bin: | $(RESDIR)
	$(CARCOLGEN) $(RESDIR)/policecarcol.bin 2.3

$(RESDIR)/helicopter.2bpp: $(ASSETSDIR)/gameobjs/helicopter.png | $(RESDIR)
	$(GFX) -h -o $(RESDIR)/helicopter.2bpp $(ASSETSDIR)/gameobjs/helicopter.png

$(RESDIR)/helicopterExplode.2bpp: $(ASSETSDIR)/gameobjs/helicopterExplode.png | $(RESDIR)
	$(GFX) -h -o $(RESDIR)/helicopterExplode.2bpp $(ASSETSDIR)/gameobjs/helicopterExplode.png

$(RESDIR)/missile.2bpp: $(ASSETSDIR)/gameobjs/missile.png | $(RESDIR)
	$(GFX) -h -o $(RESDIR)/missile.2bpp $(ASSETSDIR)/gameobjs/missile.png

$(RESDIR)/roadcollision.bin: $(RESDIR)/lines.tilemap | $(RESDIR)
	$(ROADCOLGEN) $(RESDIR)/roadcollision.bin $(RESDIR)/lines.tilemap

$(RESDIR)/statusbar.2bpp: $(ASSETSDIR)/interface/statusbar.png | $(RESDIR)
	$(GFX) -x 3 -o $(RESDIR)/statusbar.2bpp $(ASSETSDIR)/interface/statusbar.png

$(RESDIR)/curvebar.tilemap: | $(RESDIR)
	$(CURVEBARGEN) $(RESDIR)/curvebar.tilemap

$(RESDIR)/menubar.2bpp $(RESDIR)/menubar.tilemap: $(ASSETSDIR)/interface/menubar.png | $(RESDIR)
	$(GFX) -u -o $(RESDIR)/menubar.2bpp -t $(RESDIR)/menubar.tilemap $(ASSETSDIR)/interface/menubar.png

$(RESDIR)/title.2bpp $(RESDIR)/title.tilemap: $(ASSETSDIR)/interface/title.png | $(RESDIR)
	$(GFX) -u -o $(RESDIR)/title.2bpp -t $(RESDIR)/title.tilemap $(ASSETSDIR)/interface/title.png
	$(ADDOFFSET) $(RESDIR)/title.tilemap $(RESDIR)/title.tilemap 23

$(RESDIR)/titleScreenBottom.2bpp $(RESDIR)/titleScreenBottom.tilemap: $(ASSETSDIR)/interface/titleScreenBottom.png | $(RESDIR)
	$(GFX) -u -o $(RESDIR)/titleScreenBottom.2bpp -t $(RESDIR)/titleScreenBottom.tilemap $(ASSETSDIR)/interface/titleScreenBottom.png
	$(ADDOFFSET) $(RESDIR)/titleScreenBottom.tilemap $(RESDIR)/titleScreenBottom.tilemap -52

$(RESDIR)/garage.2bpp $(RESDIR)/garage.tilemap: $(ASSETSDIR)/interface/garage.png | $(RESDIR)
	$(GFX) -u -o $(RESDIR)/garage.2bpp -t $(RESDIR)/garage.tilemap $(ASSETSDIR)/interface/garage.png

$(RESDIR)/garageObjects.2bpp: $(ASSETSDIR)/interface/garageObjects.png | $(RESDIR)
	$(GFX) -u -o $(RESDIR)/garageObjects.2bpp $(ASSETSDIR)/interface/garageObjects.png

$(RESDIR)/font.2bpp: $(ASSETSDIR)/interface/font.png | $(RESDIR)
	$(GFX) -x 11 -o $(RESDIR)/font.2bpp $(ASSETSDIR)/interface/font.png

$(RESDIR)/fontPSwap.2bpp: $(ASSETSDIR)/interface/fontPSwap.png | $(RESDIR)
	$(GFX) -x 6 -o $(RESDIR)/fontPSwap.2bpp $(ASSETSDIR)/interface/fontPSwap.png

$(RESDIR):
	$(MKDIR_P) $(RESDIR)

clean:
	$(RM_RF) $(RESDIR)