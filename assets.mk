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

all: road player policecar gameui explosion

road: $(RESDIR)/lines.2bpp $(RESDIR)/lines.tilemap $(RESDIR)/roadcollision.bin

player: $(RESDIR)/player.2bpp $(RESDIR)/player.tilemap $(RESDIR)/player.attrmap

policecar: $(RESDIR)/policecar.2bpp $(RESDIR)/policecar.tilemap $(RESDIR)/policecar.attrmap $(RESDIR)/policecarcol.bin

gameui: $(RESDIR)/statusbar.2bpp $(RESDIR)/curvebar.tilemap $(RESDIR)/menubar.2bpp $(RESDIR)/menubar.tilemap

explosion: $(RESDIR)/explosion1.2bpp $(RESDIR)/explosion1.tilemap

$(RESDIR)/lines.2bpp $(RESDIR)/lines.tilemap: $(ASSETSDIR)/lines.png | $(RESDIR)
	$(GFX) -u -o $(RESDIR)/lines.2bpp -t $(RESDIR)/lines.tilemap $(ASSETSDIR)/lines.png
#	$(ADDOFFSET) $(RESDIR)/lines.tilemap $(RESDIR)/lines.tilemap 0

$(RESDIR)/player.2bpp $(RESDIR)/player.tilemap $(RESDIR)/player.attrmap: $(ASSETSDIR)/player.png | $(RESDIR)
	$(GFX) -h -o $(RESDIR)/player.2bpp $(ASSETSDIR)/player.png

$(RESDIR)/policecar.2bpp $(RESDIR)/policecar.tilemap $(RESDIR)/policecar.attrmap: $(ASSETSDIR)/policecar.png | $(RESDIR)
	$(GFX) -h -o $(RESDIR)/policecar.2bpp $(ASSETSDIR)/policecar.png
	$(ADDOFFSET) $(MAPSDIR)/policecar.tilemap $(RESDIR)/policecar.tilemap 12

$(RESDIR)/explosion1.2bpp $(RESDIR)/explosion1.tilemap: $(ASSETSDIR)/explosion1.png | $(RESDIR)
	$(GFX) -h -o $(RESDIR)/explosion1.2bpp $(ASSETSDIR)/explosion1.png

$(RESDIR)/policecarcol.bin: | $(RESDIR)
	$(CARCOLGEN) $(RESDIR)/policecarcol.bin 2.3

$(RESDIR)/roadcollision.bin: $(RESDIR)/lines.tilemap | $(RESDIR)
	$(ROADCOLGEN) $(RESDIR)/roadcollision.bin $(RESDIR)/lines.tilemap

$(RESDIR)/statusbar.2bpp: $(ASSETSDIR)/statusbar.png | $(RESDIR)
	$(GFX) -x 3 -o $(RESDIR)/statusbar.2bpp $(ASSETSDIR)/statusbar.png

$(RESDIR)/curvebar.tilemap: | $(RESDIR)
	$(CURVEBARGEN) $(RESDIR)/curvebar.tilemap

$(RESDIR)/menubar.2bpp $(RESDIR)/menubar.tilemap: $(ASSETSDIR)/menubar.png | $(RESDIR)
	$(GFX) -u -o $(RESDIR)/menubar.2bpp -t $(RESDIR)/menubar.tilemap $(ASSETSDIR)/menubar.png

$(RESDIR):
	$(MKDIR_P) $(RESDIR)

clean:
	$(RM_RF) $(RESDIR)