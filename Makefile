ASM = rgbasm
LINK = rgblink
FIX = rgbfix

SRCDIR := src
BINDIR := bin
OBJDIR := obj

ifneq ($(OS),Windows_NT)
    # POSIX OSes
    RM_RF := rm -rf
    MKDIR_P := mkdir -p
else
    # Windows
    RM_RF := -del /q
    MKDIR_P := -mkdir
endif

SOURCES = $(wildcard $(SRCDIR)/*.asm)
INCDIRS  = $(SRCDIR)/ $(SRCDIR)/include/
WARNINGS = all extra
ASFLAGS  = -p $(PADVALUE) $(addprefix -i,$(INCDIRS)) $(addprefix -W,$(WARNINGS))
LDFLAGS  = -p $(PADVALUE)
FIXFLAGS = -p $(PADVALUE) -v -k "$(LICENSEE)" -l $(OLDLIC) -m $(MBC) -n $(VERSION) -r $(SRAMSIZE) -t $(TITLE)

include project.mk

all: makeAssets $(ROMNAME)

makeAssets:
	$(MAKE) -f assets.mk

$(ROMNAME): $(patsubst $(SRCDIR)/%.asm,$(OBJDIR)/%.o,$(SOURCES))
	$(LINK) $(LDFLAGS) -l layout.link -o $(BINDIR)/$@.$(ROMEXT) -m $(BINDIR)/$@.map -n $(BINDIR)/$@.sym $^
	$(FIX) $(FIXFLAGS) $(BINDIR)/$@.$(ROMEXT)

$(OBJDIR)/%.o: $(SRCDIR)/%.asm force | $(OBJDIR) $(BINDIR)
	$(ASM) $(ASFLAGS) -o $(OBJDIR)/$*.o $<

$(OBJDIR):
	$(MKDIR_P) $(OBJDIR)

$(BINDIR):
	$(MKDIR_P) $(BINDIR)

# this target does nothing. it is added as a requirement to the object file assembly
# to force recompile all the code every time
# needed because files that INCBIN asset files won't know if those files have changed
# so by default, they won't be compiled, and the asset changes are ignored in the build
# maybe should find a better solution for this later?
force: ;

clean:
	$(RM_RF) $(BINDIR)
	$(RM_RF) $(OBJDIR)
	$(MAKE) -f assets.mk clean

rebuild:
	$(MAKE) clean
	$(MAKE) all