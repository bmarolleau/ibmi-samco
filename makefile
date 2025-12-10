# SAMCO Application Makefile for Bob (Better Object Builder)
# Based on IBM i Bob best practices from ibmi-company_system

BIN_LIB=SAMCO
LIBL=$(BIN_LIB)

INCDIR=""
PREPATH=/QSYS.LIB/$(BIN_LIB).LIB
SHELL=/QOpenSys/usr/bin/qsh

# Include the build rules
include Rules.mk

# All targets - build everything
all: .logs .evfevent library database programs

# Create log directories
.logs:
	mkdir .logs

.evfevent:
	mkdir .evfevent

# Create library
library:
	-system -q "CRTLIB LIB($(BIN_LIB)) TEXT('SAMCO Application')"

# Database objects (files, tables, views)
database: $(PREPATH)/SAMPLE.BNDDIR \
	$(PREPATH)/SAMMSGF.MSGF \
	$(PREPATH)/LASTORDNO.DTAARA \
	$(PREPATH)/ADDRESS.FILE \
	$(PREPATH)/ARTICLE.FILE \
	$(PREPATH)/ARTIPROV.FILE \
	$(PREPATH)/COUNTRY.FILE \
	$(PREPATH)/CUSTADRE.FILE \
	$(PREPATH)/CUSTOMER.FILE \
	$(PREPATH)/DETORD.FILE \
	$(PREPATH)/FAMILLY.FILE \
	$(PREPATH)/ORDER.FILE \
	$(PREPATH)/PARAMETER.FILE \
	$(PREPATH)/PROVIDER.FILE \
	$(PREPATH)/SAMREF.FILE \
	$(PREPATH)/VATDEF.FILE \
	$(PREPATH)/ARTICLE1.FILE \
	$(PREPATH)/ARTICLE2.FILE \
	$(PREPATH)/ARTIPRO1.FILE \
	$(PREPATH)/ARTIPRO2.FILE \
	$(PREPATH)/COUNTR1.FILE \
	$(PREPATH)/CUSTOME1.FILE \
	$(PREPATH)/CUSTOME2.FILE \
	$(PREPATH)/DETORD1.FILE \
	$(PREPATH)/FAMILL1.FILE \
	$(PREPATH)/ORDER1.FILE \
	$(PREPATH)/ORDER2.FILE \
	$(PREPATH)/ORDER3.FILE \
	$(PREPATH)/PROVIDE1.FILE \
	$(PREPATH)/PROVIDE2.FILE \
	$(PREPATH)/ART200D.FILE \
	$(PREPATH)/ART201D.FILE \
	$(PREPATH)/ART202D.FILE \
	$(PREPATH)/ART250D.FILE \
	$(PREPATH)/ART301D.FILE \
	$(PREPATH)/COU200D.FILE \
	$(PREPATH)/COU301D.FILE \
	$(PREPATH)/CUS200D.FILE \
	$(PREPATH)/CUS250D.FILE \
	$(PREPATH)/CUS301D.FILE \
	$(PREPATH)/FAM301D.FILE \
	$(PREPATH)/ORD100D.FILE \
	$(PREPATH)/ORD101D.FILE \
	$(PREPATH)/ORD200D.FILE \
	$(PREPATH)/ORD201D.FILE \
	$(PREPATH)/ORD202D.FILE \
	$(PREPATH)/PAR200D.FILE \
	$(PREPATH)/PRO200D.FILE \
	$(PREPATH)/PRO201D.FILE \
	$(PREPATH)/PRO202D.FILE \
	$(PREPATH)/PRO250D.FILE \
	$(PREPATH)/PRO301D.FILE \
	$(PREPATH)/ORD500O.FILE \
	$(PREPATH)/SAMHELP.PNLGRP \
	$(PREPATH)/SAMMNU.MENU

# Programs and modules
programs: $(PREPATH)/LOG300.MODULE \
	$(PREPATH)/ART300.MODULE \
	$(PREPATH)/ART301.MODULE \
	$(PREPATH)/ART302.MODULE \
	$(PREPATH)/COU300.MODULE \
	$(PREPATH)/COU301.MODULE \
	$(PREPATH)/CUS300.MODULE \
	$(PREPATH)/CUS301.MODULE \
	$(PREPATH)/FAM300.MODULE \
	$(PREPATH)/FAM301.MODULE \
	$(PREPATH)/PAR300.MODULE \
	$(PREPATH)/PRO200.MODULE \
	$(PREPATH)/PRO202.MODULE \
	$(PREPATH)/PRO300.MODULE \
	$(PREPATH)/PRO301.MODULE \
	$(PREPATH)/VAT300.MODULE \
	$(PREPATH)/FARTICLE.SRVPGM \
	$(PREPATH)/FCOUNTRY.SRVPGM \
	$(PREPATH)/FCUSTOMER.SRVPGM \
	$(PREPATH)/FFAMILLY.SRVPGM \
	$(PREPATH)/FPARAMETER.SRVPGM \
	$(PREPATH)/FPROVIDER.SRVPGM \
	$(PREPATH)/FVAT.SRVPGM \
	$(PREPATH)/LOG.SRVPGM \
	$(PREPATH)/ART200.PGM \
	$(PREPATH)/ART201.PGM \
	$(PREPATH)/ART202.PGM \
	$(PREPATH)/ART250.PGM \
	$(PREPATH)/COU200.PGM \
	$(PREPATH)/CUS200.PGM \
	$(PREPATH)/CUS250.PGM \
	$(PREPATH)/DAT001.PGM \
	$(PREPATH)/DAT002.PGM \
	$(PREPATH)/LOG100.PGM \
	$(PREPATH)/ORD100.PGM \
	$(PREPATH)/ORD101.PGM \
	$(PREPATH)/ORD200.PGM \
	$(PREPATH)/ORD201.PGM \
	$(PREPATH)/ORD202.PGM \
	$(PREPATH)/ORD500.PGM \
	$(PREPATH)/ORD700.PGM \
	$(PREPATH)/ORD900.PGM \
	$(PREPATH)/ORD901.PGM \
	$(PREPATH)/PAR200.PGM \
	$(PREPATH)/PAR201.PGM \
	$(PREPATH)/PRO201.PGM \
	$(PREPATH)/PRO203.PGM \
	$(PREPATH)/PRO250.PGM \
	$(PREPATH)/ORD100C.PGM \
	$(PREPATH)/ORD100C2.PGM \
	$(PREPATH)/ORD500C.PGM \
	$(PREPATH)/CRTORD.CMD \
	$(PREPATH)/CVTSPLPDF.CMD

# Build command
build: all

# Compile specific files
compile:
	@echo "Use: makei compile -f <file>"

# Help target
help:
	@echo "SAMCO Application Build System (Bob)"
	@echo "====================================="
	@echo ""
	@echo "Usage: makei [target] [BIN_LIB=library]"
	@echo ""
	@echo "Targets:"
	@echo "  all      - Build entire application (default)"
	@echo "  build    - Same as 'all'"
	@echo "  library  - Create library only"
	@echo "  database - Build database objects"
	@echo "  programs - Build programs and service programs"
	@echo "  compile  - Compile specific files with -f option"
	@echo "  help     - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  makei                    # Build everything to SAMCO library"
	@echo "  makei BIN_LIB=SAMCODEV   # Build to SAMCODEV library"
	@echo "  makei database           # Build only database objects"
	@echo "  makei compile -f qrpglesrc/COU200.PGM.RPGLE"