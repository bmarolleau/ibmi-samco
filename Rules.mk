# IBM i Bob Build Rules for SAMCO Application
# This file defines the build rules for all object types in the project

# Build library - can be overridden with BOB_BUILD_LIB environment variable
BUILDLIB ?= SAMCO

# Include path for copy books and prototypes
INCLUDES := SAMCO_SRC/QPROTOSRC

# Object library
OBJLIB := $(BUILDLIB)

#-------------------------------------------------------------------------------
# Physical Files (PF)
#-------------------------------------------------------------------------------
SAMCO_SRC/QDDSSRC/%.PF: SAMCO_SRC/QDDSSRC/%.PF
	system "CRTPF FILE($(OBJLIB)/$*) SRCFILE($(BUILDLIB)/QDDSSRC) SRCMBR($*) OPTION(*EVENTF) GENLVL(20)"

#-------------------------------------------------------------------------------
# Logical Files (LF)
#-------------------------------------------------------------------------------
SAMCO_SRC/QDDSSRC/%.LF: SAMCO_SRC/QDDSSRC/%.LF
	system "CRTLF FILE($(OBJLIB)/$*) SRCFILE($(BUILDLIB)/QDDSSRC) SRCMBR($*) OPTION(*EVENTF) GENLVL(20)"

#-------------------------------------------------------------------------------
# Display Files (DSPF)
#-------------------------------------------------------------------------------
SAMCO_SRC/QDDSSRC/%.DSPF: SAMCO_SRC/QDDSSRC/%.DSPF
	system "CRTDSPF FILE($(OBJLIB)/$*) SRCFILE($(BUILDLIB)/QDDSSRC) SRCMBR($*) OPTION(*EVENTF) RSTDSP(*YES)"

#-------------------------------------------------------------------------------
# Print Files (PRTF)
#-------------------------------------------------------------------------------
SAMCO_SRC/QDDSSRC/%.PRTF: SAMCO_SRC/QDDSSRC/%.PRTF
	system "CRTPRTF FILE($(OBJLIB)/$*) SRCFILE($(BUILDLIB)/QPRTFSRC) SRCMBR($*) OPTION(*EVENTF)"

#-------------------------------------------------------------------------------
# RPG Programs (Fixed Format)
#-------------------------------------------------------------------------------
SAMCO_SRC/QRPGSRC/%.RPG: SAMCO_SRC/QRPGSRC/%.RPG
	system "CRTRPGPGM PGM($(OBJLIB)/$*) SRCFILE($(BUILDLIB)/QRPGSRC) SRCMBR($*) OPTION(*EVENTF) DBGVIEW(*SOURCE)"

#-------------------------------------------------------------------------------
# RPGLE Programs (Free Format)
#-------------------------------------------------------------------------------
SAMCO_SRC/QRPGLESRC/%.PGM.RPGLE: SAMCO_SRC/QRPGLESRC/%.PGM.RPGLE
	system "CRTBNDRPG PGM($(OBJLIB)/$*) SRCFILE($(BUILDLIB)/QRPGLESRC) SRCMBR($*) OPTION(*EVENTF) DBGVIEW(*SOURCE) INCDIR('$(INCLUDES)')"

#-------------------------------------------------------------------------------
# SQL RPGLE Programs
#-------------------------------------------------------------------------------
SAMCO_SRC/QRPGLESRC/%.PGM.SQLRPGLE: SAMCO_SRC/QRPGLESRC/%.PGM.SQLRPGLE
	system "CRTSQLRPGI OBJ($(OBJLIB)/$*) SRCFILE($(BUILDLIB)/QRPGLESRC) SRCMBR($*) COMMIT(*NONE) OBJTYPE(*PGM) OPTION(*EVENTF) DBGVIEW(*SOURCE) COMPILEOPT('INCDIR(''$(INCLUDES)'')')"

#-------------------------------------------------------------------------------
# RPGLE Modules (for service programs)
#-------------------------------------------------------------------------------
SAMCO_SRC/QRPGLESRC/%.RPGLE: SAMCO_SRC/QRPGLESRC/%.RPGLE
	system "CRTRPGMOD MODULE($(OBJLIB)/$*) SRCFILE($(BUILDLIB)/QRPGLESRC) SRCMBR($*) OPTION(*EVENTF) DBGVIEW(*SOURCE) INCDIR('$(INCLUDES)')"

#-------------------------------------------------------------------------------
# SQL RPGLE Modules
#-------------------------------------------------------------------------------
SAMCO_SRC/QRPGLESRC/%.SQLRPGLE: SAMCO_SRC/QRPGLESRC/%.SQLRPGLE
	system "CRTSQLRPGI OBJ($(OBJLIB)/$*) SRCFILE($(BUILDLIB)/QRPGLESRC) SRCMBR($*) COMMIT(*NONE) OBJTYPE(*MODULE) OPTION(*EVENTF) DBGVIEW(*SOURCE) COMPILEOPT('INCDIR(''$(INCLUDES)'')')"

#-------------------------------------------------------------------------------
# CL Programs
#-------------------------------------------------------------------------------
SAMCO_SRC/QCLSRC/%.PGM.CLLE: SAMCO_SRC/QCLSRC/%.PGM.CLLE
	system "CRTBNDCL PGM($(OBJLIB)/$*) SRCFILE($(BUILDLIB)/QCLSRC) SRCMBR($*) OPTION(*EVENTF) DBGVIEW(*SOURCE)"

SAMCO_SRC/QCLSRC/%.CLLE: SAMCO_SRC/QCLSRC/%.CLLE
	system "CRTBNDCL PGM($(OBJLIB)/$*) SRCFILE($(BUILDLIB)/QCLSRC) SRCMBR($*) OPTION(*EVENTF) DBGVIEW(*SOURCE)"

#-------------------------------------------------------------------------------
# COBOL Programs
#-------------------------------------------------------------------------------
SAMCO_SRC/QCBLSRC/%.CBL: SAMCO_SRC/QCBLSRC/%.CBL
	system "CRTBNDCBL PGM($(OBJLIB)/$*) SRCFILE($(BUILDLIB)/QCBLSRC) SRCMBR($*) OPTION(*EVENTF) DBGVIEW(*SOURCE)"

#-------------------------------------------------------------------------------
# Commands
#-------------------------------------------------------------------------------
SAMCO_SRC/QCMDSRC/%.CMD: SAMCO_SRC/QCMDSRC/%.CMD
	system "CRTCMD CMD($(OBJLIB)/$*) PGM($(OBJLIB)/$*) SRCFILE($(BUILDLIB)/QCMDSRC) SRCMBR($*)"

#-------------------------------------------------------------------------------
# Service Programs
#-------------------------------------------------------------------------------
SAMCO_SRC/QSRVSRC/%.BND: SAMCO_SRC/QSRVSRC/%.BND
	system "CRTSRVPGM SRVPGM($(OBJLIB)/$*) MODULE($(OBJLIB)/$*) SRCFILE($(BUILDLIB)/QSRVSRC) SRCMBR($*) OPTION(*EVENTF) ACTGRP(*CALLER) BNDDIR($(OBJLIB)/SAMPLE)"

#-------------------------------------------------------------------------------
# Binding Directories
#-------------------------------------------------------------------------------
SAMCO_SRC/QBNDSRC/%.BNDDIR: SAMCO_SRC/QBNDSRC/%.BNDDIR
	-system "DLTBNDDIR BNDDIR($(OBJLIB)/$*)"
	system "CRTBNDDIR BNDDIR($(OBJLIB)/$*)"

#-------------------------------------------------------------------------------
# Message Files
#-------------------------------------------------------------------------------
SAMCO_SRC/QMSGFSRC/%.MSGF: SAMCO_SRC/QMSGFSRC/%.MSGF
	-system "DLTMSGF MSGF($(OBJLIB)/$*)"
	system "CRTMSGF MSGF($(OBJLIB)/$*)"

#-------------------------------------------------------------------------------
# Panel Groups
#-------------------------------------------------------------------------------
SAMCO_SRC/QPNLSRC/%.PNLGRP: SAMCO_SRC/QPNLSRC/%.PNLGRP
	system "CRTPNLGRP PNLGRP($(OBJLIB)/$*) SRCFILE($(BUILDLIB)/QPNLSRC) SRCMBR($*) OPTION(*EVENTF)"

#-------------------------------------------------------------------------------
# Menus
#-------------------------------------------------------------------------------
SAMCO_SRC/QPNLSRC/%.MENU: SAMCO_SRC/QPNLSRC/%.MENU
	system "CRTMNU MENU($(OBJLIB)/$*) TYPE(*UIM) SRCFILE($(BUILDLIB)/QPNLSRC) SRCMBR($*)"

#-------------------------------------------------------------------------------
# SQL Tables
#-------------------------------------------------------------------------------
SAMCO_SRC/QSQLSRC/%.TABLE: SAMCO_SRC/QSQLSRC/%.TABLE
	system "RUNSQLSTM SRCFILE($(BUILDLIB)/QSQLSRC) SRCMBR($*) COMMIT(*NONE) NAMING(*SQL)"

#-------------------------------------------------------------------------------
# SQL Views
#-------------------------------------------------------------------------------
SAMCO_SRC/QSQLSRC/%.VIEW: SAMCO_SRC/QSQLSRC/%.VIEW
	system "RUNSQLSTM SRCFILE($(BUILDLIB)/QSQLSRC) SRCMBR($*) COMMIT(*NONE) NAMING(*SQL)"

#-------------------------------------------------------------------------------
# SQL Procedures
#-------------------------------------------------------------------------------
SAMCO_SRC/QSQLSRC/%.SQLPRC: SAMCO_SRC/QSQLSRC/%.SQLPRC
	system "RUNSQLSTM SRCFILE($(BUILDLIB)/QSQLSRC) SRCMBR($*) COMMIT(*NONE) NAMING(*SQL)"

#-------------------------------------------------------------------------------
# SQL Triggers
#-------------------------------------------------------------------------------
SAMCO_SRC/QSQLSRC/%.SQLTRG: SAMCO_SRC/QSQLSRC/%.SQLTRG
	system "RUNSQLSTM SRCFILE($(BUILDLIB)/QSQLSRC) SRCMBR($*) COMMIT(*NONE) NAMING(*SQL)"

#-------------------------------------------------------------------------------
# SQL UDFs
#-------------------------------------------------------------------------------
SAMCO_SRC/QSQLSRC/%.SQLUDF: SAMCO_SRC/QSQLSRC/%.SQLUDF
	system "RUNSQLSTM SRCFILE($(BUILDLIB)/QSQLSRC) SRCMBR($*) COMMIT(*NONE) NAMING(*SQL)"

#-------------------------------------------------------------------------------
# SQL Sequences
#-------------------------------------------------------------------------------
SAMCO_SRC/QSQLSRC/%.SQLSEQ: SAMCO_SRC/QSQLSRC/%.SQLSEQ
	system "RUNSQLSTM SRCFILE($(BUILDLIB)/QSQLSRC) SRCMBR($*) COMMIT(*NONE) NAMING(*SQL)"

#-------------------------------------------------------------------------------
# System Triggers
#-------------------------------------------------------------------------------
SAMCO_SRC/QTRGSRC/%.SYSTRG: SAMCO_SRC/QTRGSRC/%.SYSTRG
	system "ADDPFTRG FILE($(OBJLIB)/$*) TRGTIME(*AFTER) TRGEVENT(*INSERT *UPDATE *DELETE) PGM($(OBJLIB)/$*) RPLTRG(*YES)"

#-------------------------------------------------------------------------------
# Data Areas
#-------------------------------------------------------------------------------
SAMCO_SRC/QDTASRC/%.DTAARA: SAMCO_SRC/QDTASRC/%.DTAARA
	-system "DLTDTAARA DTAARA($(OBJLIB)/$*)"
	system "CRTDTAARA DTAARA($(OBJLIB)/$*) TYPE(*CHAR) LEN(10) VALUE('0000000000')"

#-------------------------------------------------------------------------------
# ILE Programs (from QILESRC)
#-------------------------------------------------------------------------------
SAMCO_SRC/QILESRC/%.ILEPGM: SAMCO_SRC/QILESRC/%.ILEPGM
	system "CRTPGM PGM($(OBJLIB)/$*) MODULE($(OBJLIB)/$*) ACTGRP(*NEW) BNDDIR($(OBJLIB)/SAMPLE)"

#-------------------------------------------------------------------------------
# ILE Service Programs (from QILESRVSRC)
#-------------------------------------------------------------------------------
SAMCO_SRC/QILESRVSRC/%.ILESRVPGM: SAMCO_SRC/QILESRVSRC/%.ILESRVPGM
	system "CRTSRVPGM SRVPGM($(OBJLIB)/$*) MODULE($(OBJLIB)/$*) SRCFILE($(BUILDLIB)/QSRVSRC) ACTGRP(*CALLER) BNDDIR($(OBJLIB)/SAMPLE)"

# Made with Bob
