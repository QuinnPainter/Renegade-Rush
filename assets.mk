GFX = rgbgfx

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

all: $(RESDIR)/lines.2bpp $(RESDIR)/lines.tilemap $(RESDIR)/player.2bpp $(RESDIR)/player.tilemap $(RESDIR)/player.attrmap

$(RESDIR)/lines.2bpp $(RESDIR)/lines.tilemap: $(ASSETSDIR)/lines.png | $(RESDIR)
	$(GFX) -u -o $(RESDIR)/lines.2bpp -t $(RESDIR)/lines.tilemap $(ASSETSDIR)/lines.png

$(RESDIR)/player.2bpp $(RESDIR)/player.tilemap $(RESDIR)/player.attrmap: $(ASSETSDIR)/player.png | $(RESDIR)
	$(GFX) -u -m -o $(RESDIR)/player.2bpp -t $(RESDIR)/player.tilemap -a $(RESDIR)/player.attrmap $(ASSETSDIR)/player.png

$(RESDIR):
	$(MKDIR_P) $(RESDIR)

clean:
	$(RM_RF) $(RESDIR)