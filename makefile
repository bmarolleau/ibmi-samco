# SAMCO Application Makefile
# This makefile uses IBM i Bob (makei) to build the entire application

# Include the build rules
include Rules.mk

# Shell to use
SHELL=/QOpenSys/pkgs/bin/bash

# Default target library (can be overridden with: make BUILDLIB=MYLIB)
BUILDLIB ?= SAMCO

# All source files by type
PF_SOURCES := $(wildcard SAMCO_SRC/QDDSSRC/*.PF)
LF_SOURCES := $(wildcard SAMCO_SRC/QDDSSRC/*.LF)
DSPF_SOURCES := $(wildcard SAMCO_SRC/QDDSSRC/*.DSPF)
PRTF_SOURCES := $(wildcard SAMCO_SRC/QDDSSRC/*.PRTF)
RPG_SOURCES := $(wildcard SAMCO_SRC/QRPGSRC/*.RPG)
RPGLE_PGM_SOURCES := $(wildcard SAMCO_SRC/QRPGLESRC/*.PGM.RPGLE)
SQLRPGLE_PGM_SOURCES := $(wildcard SAMCO_SRC/QRPGLESRC/*.PGM.SQLRPGLE)
RPGLE_MOD_SOURCES := $(filter-out %.PGM.RPGLE %.PGM.SQLRPGLE,$(wildcard SAMCO_SRC/QRPGLESRC/*.RPGLE))
SQLRPGLE_MOD_SOURCES := $(filter-out %.PGM.SQLRPGLE,$(wildcard SAMCO_SRC/QRPGLESRC/*.SQLRPGLE))
CL_SOURCES := $(wildcard SAMCO_SRC/QCLSRC/*.CLLE) $(wildcard SAMCO_SRC/QCLSRC/*.PGM.CLLE)
CBL_SOURCES := $(wildcard SAMCO_SRC/QCBLSRC/*.CBL)
CMD_SOURCES := $(wildcard SAMCO_SRC/QCMDSRC/*.CMD)
BND_SOURCES := $(wildcard SAMCO_SRC/QSRVSRC/*.BND)
BNDDIR_SOURCES := $(wildcard SAMCO_SRC/QBNDSRC/*.BNDDIR)
MSGF_SOURCES := $(wildcard SAMCO_SRC/QMSGFSRC/*.MSGF)
PNLGRP_SOURCES := $(wildcard SAMCO_SRC/QPNLSRC/*.PNLGRP)
MENU_SOURCES := $(wildcard SAMCO_SRC/QPNLSRC/*.MENU)
TABLE_SOURCES := $(wildcard SAMCO_SRC/QSQLSRC/*.TABLE)
VIEW_SOURCES := $(wildcard SAMCO_SRC/QSQLSRC/*.VIEW)
SQLPRC_SOURCES := $(wildcard SAMCO_SRC/QSQLSRC/*.SQLPRC)
SQLTRG_SOURCES := $(wildcard SAMCO_SRC/QSQLSRC/*.SQLTRG)
SQLUDF_SOURCES := $(wildcard SAMCO_SRC/QSQLSRC/*.SQLUDF)
SQLSEQ_SOURCES := $(wildcard SAMCO_SRC/QSQLSRC/*.SQLSEQ)
SYSTRG_SOURCES := $(wildcard SAMCO_SRC/QTRGSRC/*.SYSTRG)
DTAARA_SOURCES := $(wildcard SAMCO_SRC/QDTASRC/*.DTAARA)
ILEPGM_SOURCES := $(wildcard SAMCO_SRC/QILESRC/*.ILEPGM)
ILESRVPGM_SOURCES := $(wildcard SAMCO_SRC/QILESRVSRC/*.ILESRVPGM)

# Default target - build everything
.PHONY: all
all: database programs

# Build in proper order
.PHONY: database
database: binding-dirs message-files data-areas physical-files logical-files display-files print-files sql-objects

.PHONY: programs
programs: modules service-programs bound-programs commands menus

# Individual build targets
.PHONY: binding-dirs
binding-dirs: $(BNDDIR_SOURCES)

.PHONY: message-files
message-files: $(MSGF_SOURCES)

.PHONY: data-areas
data-areas: $(DTAARA_SOURCES)

.PHONY: physical-files
physical-files: $(PF_SOURCES)

.PHONY: logical-files
logical-files: $(LF_SOURCES)

.PHONY: display-files
display-files: $(DSPF_SOURCES)

.PHONY: print-files
print-files: $(PRTF_SOURCES)

.PHONY: sql-objects
sql-objects: $(TABLE_SOURCES) $(VIEW_SOURCES) $(SQLSEQ_SOURCES) $(SQLUDF_SOURCES) $(SQLPRC_SOURCES)

.PHONY: modules
modules: $(RPGLE_MOD_SOURCES) $(SQLRPGLE_MOD_SOURCES)

.PHONY: service-programs
service-programs: $(BND_SOURCES) $(ILESRVPGM_SOURCES)

.PHONY: bound-programs
bound-programs: $(RPG_SOURCES) $(RPGLE_PGM_SOURCES) $(SQLRPGLE_PGM_SOURCES) $(CL_SOURCES) $(CBL_SOURCES) $(ILEPGM_SOURCES)

.PHONY: commands
commands: $(CMD_SOURCES)

.PHONY: menus
menus: $(PNLGRP_SOURCES) $(MENU_SOURCES)

.PHONY: triggers
triggers: $(SQLTRG_SOURCES) $(SYSTRG_SOURCES)

# Clean target (optional - removes objects from library)
.PHONY: clean
clean:
	@echo "To clean, manually delete objects from library $(BUILDLIB)"

# Help target
.PHONY: help
help:
	@echo "SAMCO Application Build System"
	@echo "=============================="
	@echo ""
	@echo "Usage: make [target] [BUILDLIB=library]"
	@echo ""
	@echo "Targets:"
	@echo "  all              - Build entire application (default)"
	@echo "  database         - Build database objects only"
	@echo "  programs         - Build programs only"
	@echo "  binding-dirs     - Build binding directories"
	@echo "  message-files    - Build message files"
	@echo "  data-areas       - Build data areas"
	@echo "  physical-files   - Build physical files"
	@echo "  logical-files    - Build logical files"
	@echo "  display-files    - Build display files"
	@echo "  print-files      - Build print files"
	@echo "  sql-objects      - Build SQL objects (tables, views, etc.)"
	@echo "  modules          - Build RPGLE modules"
	@echo "  service-programs - Build service programs"
	@echo "  bound-programs   - Build bound programs"
	@echo "  commands         - Build commands"
	@echo "  menus            - Build menus and panel groups"
	@echo "  triggers         - Build triggers"
	@echo "  help             - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  makei                    # Build everything to SAMCO library"
	@echo "  makei BUILDLIB=SAMCODEV  # Build to SAMCODEV library"
	@echo "  makei database           # Build only database objects"
	@echo "  makei programs           # Build only programs"