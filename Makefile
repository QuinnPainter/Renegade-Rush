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

all: $(ROMNAME)

$(ROMNAME): $(patsubst $(SRCDIR)/%.asm,$(OBJDIR)/%.o,$(SOURCES))
	$(LINK) $(LDFLAGS) -o $(BINDIR)/$@.$(ROMEXT) -m $(BINDIR)/$@.map -n $(BINDIR)/$@.sym $^
	$(FIX) $(FIXFLAGS) $(BINDIR)/$@.$(ROMEXT)

$(OBJDIR)/%.o: $(SRCDIR)/%.asm | $(OBJDIR) $(BINDIR)
	$(ASM) $(ASFLAGS) -o $(OBJDIR)/$*.o $<

$(OBJDIR):
	$(MKDIR_P) $(OBJDIR)

$(BINDIR):
	$(MKDIR_P) $(BINDIR)

clean:
	$(RM_RF) $(BINDIR)
	$(RM_RF) $(OBJDIR)