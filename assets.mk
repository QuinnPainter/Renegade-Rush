GFX = rgbgfx
PYTHON = python
ADDOFFSET = $(PYTHON) scripts/AddBinaryOffset.py
SWAPATTR = $(PYTHON) scripts/SwapFlipBits.py
ROADCOLGEN = $(PYTHON) scripts/GenRoadCollision.py
CARCOLGEN = $(PYTHON) scripts/GenCarCollision.py

RESDIR = res

ifneq ($(OS),Windows_NT)
	# POSIX OSes
	RM_RF := rm -rf
	MKDIR_P := mkdir -p
else
	# Windows
	RM_RF := -del /q
	MKDIR_P := -mkdir
endif

ASSETSDIR = Assets

all: road player policecar $(RESDIR)/statusbar.2bpp

road: $(RESDIR)/lines.2bpp $(RESDIR)/lines.tilemap $(RESDIR)/roadcollision.bin

player: $(RESDIR)/player.2bpp $(RESDIR)/player.tilemap $(RESDIR)/player.attrmap

policecar: $(RESDIR)/policecar.2bpp $(RESDIR)/policecar.tilemap $(RESDIR)/policecar.attrmap $(RESDIR)/policecarcol.bin

$(RESDIR)/lines.2bpp $(RESDIR)/lines.tilemap: $(ASSETSDIR)/lines.png | $(RESDIR)
	$(GFX) -u -o $(RESDIR)/lines.2bpp -t $(RESDIR)/lines.tilemap $(ASSETSDIR)/lines.png
	$(ADDOFFSET) $(RESDIR)/lines.tilemap -128

$(RESDIR)/player.2bpp $(RESDIR)/player.tilemap $(RESDIR)/player.attrmap: $(ASSETSDIR)/player.png | $(RESDIR)
	$(GFX) -u -m -o $(RESDIR)/player.2bpp -t $(RESDIR)/player.tilemap -a $(RESDIR)/player.attrmap $(ASSETSDIR)/player.png
	$(SWAPATTR) $(RESDIR)/player.attrmap

$(RESDIR)/policecar.2bpp $(RESDIR)/policecar.tilemap $(RESDIR)/policecar.attrmap: $(ASSETSDIR)/policecar.png | $(RESDIR)
	$(GFX) -u -m -o $(RESDIR)/policecar.2bpp -t $(RESDIR)/policecar.tilemap -a $(RESDIR)/policecar.attrmap $(ASSETSDIR)/policecar.png
	$(SWAPATTR) $(RESDIR)/policecar.attrmap
	$(ADDOFFSET) $(RESDIR)/policecar.tilemap 10

$(RESDIR)/policecarcol.bin: | $(RESDIR)
	$(CARCOLGEN) $(RESDIR)/policecarcol.bin 2.3

$(RESDIR)/roadcollision.bin: $(RESDIR)/lines.tilemap | $(RESDIR)
	$(ROADCOLGEN) $(RESDIR)/roadcollision.bin $(RESDIR)/lines.tilemap

$(RESDIR)/statusbar.2bpp: $(ASSETSDIR)/statusbar.png | $(RESDIR)
	$(GFX) -x 5 -o $(RESDIR)/statusbar.2bpp $(ASSETSDIR)/statusbar.png

$(RESDIR):
	$(MKDIR_P) $(RESDIR)

clean:
	$(RM_RF) $(RESDIR)