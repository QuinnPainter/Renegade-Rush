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

all: road player policecar gameui explosion title font helicopter

road: $(RESDIR)/lines.2bpp $(RESDIR)/lines.tilemap $(RESDIR)/roadcollision.bin
player: $(RESDIR)/player.2bpp
policecar: $(RESDIR)/policecar.2bpp $(RESDIR)/policecar.tilemap $(RESDIR)/policecarcol.bin
helicopter: $(RESDIR)/helicopter.2bpp
gameui: $(RESDIR)/statusbar.2bpp $(RESDIR)/curvebar.tilemap $(RESDIR)/menubar.2bpp $(RESDIR)/menubar.tilemap
explosion: $(RESDIR)/explosion1.2bpp
title: $(RESDIR)/title.2bpp $(RESDIR)/title.tilemap $(RESDIR)/titleScreenBottom.2bpp $(RESDIR)/titleScreenBottom.tilemap
font: $(RESDIR)/font.2bpp

$(RESDIR)/lines.2bpp $(RESDIR)/lines.tilemap: $(ASSETSDIR)/lines.png | $(RESDIR)
	$(GFX) -u -o $(RESDIR)/lines.2bpp -t $(RESDIR)/lines.tilemap $(ASSETSDIR)/lines.png
#	$(ADDOFFSET) $(RESDIR)/lines.tilemap $(RESDIR)/lines.tilemap 0

$(RESDIR)/player.2bpp: $(ASSETSDIR)/player.png | $(RESDIR)
	$(GFX) -h -o $(RESDIR)/player.2bpp $(ASSETSDIR)/player.png

$(RESDIR)/policecar.2bpp $(RESDIR)/policecar.tilemap: $(ASSETSDIR)/policecar.png | $(RESDIR)
	$(GFX) -h -o $(RESDIR)/policecar.2bpp $(ASSETSDIR)/policecar.png
	$(ADDOFFSET) $(MAPSDIR)/policecar.tilemap $(RESDIR)/policecar.tilemap 12

$(RESDIR)/explosion1.2bpp: $(ASSETSDIR)/explosion1.png | $(RESDIR)
	$(GFX) -h -o $(RESDIR)/explosion1.2bpp $(ASSETSDIR)/explosion1.png

$(RESDIR)/policecarcol.bin: | $(RESDIR)
	$(CARCOLGEN) $(RESDIR)/policecarcol.bin 2.3

$(RESDIR)/helicopter.2bpp: $(ASSETSDIR)/helicopter.png | $(RESDIR)
	$(GFX) -h -o $(RESDIR)/helicopter.2bpp $(ASSETSDIR)/helicopter.png

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

$(RESDIR)/font.2bpp: $(ASSETSDIR)/font.png | $(RESDIR)
	$(GFX) -x 15 -o $(RESDIR)/font.2bpp $(ASSETSDIR)/font.png

$(RESDIR):
	$(MKDIR_P) $(RESDIR)

clean:
	$(RM_RF) $(RESDIR)