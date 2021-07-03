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

all: $(RESDIR)/tiles.2bpp

$(RESDIR)/tiles.2bpp: $(ASSETSDIR)/tiles.png | $(RESDIR)
	$(GFX) -u -o $(RESDIR)/tiles.2bpp $(ASSETSDIR)/tiles.png

$(RESDIR):
	$(MKDIR_P) $(RESDIR)

clean:
	$(RM_RF) $(RESDIR)