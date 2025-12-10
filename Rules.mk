# SAMCO Application Build Rules for Bob
# Based on IBM i Bob best practices

# Physical Files
$(PREPATH)/%.FILE: qddssrc/%.PF
	liblist -a $(LIBL);\
	system "CRTPF FILE($(BIN_LIB)/$*) SRCFILE($(BIN_LIB)/QDDSSRC) SRCMBR($*) OPTION(*EVENTF) GENLVL(20)" | tee -a .logs/$*.splf

# Logical Files
$(PREPATH)/%.FILE: qddssrc/%.LF
	liblist -a $(LIBL);\
	system "CRTLF FILE($(BIN_LIB)/$*) SRCFILE($(BIN_LIB)/QDDSSRC) SRCMBR($*) OPTION(*EVENTF) GENLVL(20)" | tee -a .logs/$*.splf

# Display Files
$(PREPATH)/%.FILE: qddssrc/%.DSPF
	liblist -a $(LIBL);\
	system "CRTDSPF FILE($(BIN_LIB)/$*) SRCFILE($(BIN_LIB)/QDDSSRC) SRCMBR($*) OPTION(*EVENTF) RSTDSP(*YES)" | tee -a .logs/$*.splf

# Print Files
$(PREPATH)/%.FILE: qddssrc/%.PRTF
	liblist -a $(LIBL);\
	system "CRTPRTF FILE($(BIN_LIB)/$*) SRCFILE($(BIN_LIB)/QDDSSRC) SRCMBR($*) OPTION(*EVENTF)" | tee -a .logs/$*.splf

# RPGLE Modules
$(PREPATH)/%.MODULE: qrpglesrc/%.RPGLE
	liblist -a $(LIBL);\
	system "CRTRPGMOD MODULE($(BIN_LIB)/$*) SRCFILE($(BIN_LIB)/QRPGLESRC) SRCMBR($*) OPTION(*EVENTF) DBGVIEW(*SOURCE) INCDIR('/QOpenSys/QIBM/ProdData/OPS/tools/include' '$(INCDIR)' 'SAMCO_SRC/QPROTOSRC')" | tee -a .logs/$*.splf

# SQL RPGLE Modules
$(PREPATH)/%.MODULE: qrpglesrc/%.SQLRPGLE
	liblist -a $(LIBL);\
	system "CRTSQLRPGI OBJ($(BIN_LIB)/$*) SRCFILE($(BIN_LIB)/QRPGLESRC) SRCMBR($*) COMMIT(*NONE) OBJTYPE(*MODULE) OPTION(*EVENTF) DBGVIEW(*SOURCE) COMPILEOPT('INCDIR(''/QOpenSys/QIBM/ProdData/OPS/tools/include'' ''$(INCDIR)'' ''SAMCO_SRC/QPROTOSRC'')')" | tee -a .logs/$*.splf

# RPGLE Programs (bound)
$(PREPATH)/%.PGM: qrpglesrc/%.PGM.RPGLE
	liblist -a $(LIBL);\
	system "CRTBNDRPG PGM($(BIN_LIB)/$*) SRCFILE($(BIN_LIB)/QRPGLESRC) SRCMBR($*) OPTION(*EVENTF) DBGVIEW(*SOURCE) INCDIR('/QOpenSys/QIBM/ProdData/OPS/tools/include' '$(INCDIR)' 'SAMCO_SRC/QPROTOSRC')" | tee -a .logs/$*.splf

# SQL RPGLE Programs (bound)
$(PREPATH)/%.PGM: qrpglesrc/%.PGM.SQLRPGLE
	liblist -a $(LIBL);\
	system "CRTSQLRPGI OBJ($(BIN_LIB)/$*) SRCFILE($(BIN_LIB)/QRPGLESRC) SRCMBR($*) COMMIT(*NONE) OBJTYPE(*PGM) OPTION(*EVENTF) DBGVIEW(*SOURCE) COMPILEOPT('INCDIR(''/QOpenSys/QIBM/ProdData/OPS/tools/include'' ''$(INCDIR)'' ''SAMCO_SRC/QPROTOSRC'')')" | tee -a .logs/$*.splf

# RPG Programs (fixed format)
$(PREPATH)/%.PGM: qrpgsrc/%.RPG
	liblist -a $(LIBL);\
	system "CRTRPGPGM PGM($(BIN_LIB)/$*) SRCFILE($(BIN_LIB)/QRPGSRC) SRCMBR($*) OPTION(*EVENTF) DBGVIEW(*SOURCE)" | tee -a .logs/$*.splf

# CL Programs
$(PREPATH)/%.PGM: qclsrc/%.PGM.CLLE
	liblist -a $(LIBL);\
	system "CRTBNDCL PGM($(BIN_LIB)/$*) SRCFILE($(BIN_LIB)/QCLSRC) SRCMBR($*) OPTION(*EVENTF) DBGVIEW(*SOURCE)" | tee -a .logs/$*.splf

$(PREPATH)/%.PGM: qclsrc/%.CLLE
	liblist -a $(LIBL);\
	system "CRTBNDCL PGM($(BIN_LIB)/$*) SRCFILE($(BIN_LIB)/QCLSRC) SRCMBR($*) OPTION(*EVENTF) DBGVIEW(*SOURCE)" | tee -a .logs/$*.splf

# COBOL Programs
$(PREPATH)/%.PGM: qcblsrc/%.CBL
	liblist -a $(LIBL);\
	system "CRTBNDCBL PGM($(BIN_LIB)/$*) SRCFILE($(BIN_LIB)/QCBLSRC) SRCMBR($*) OPTION(*EVENTF) DBGVIEW(*SOURCE)" | tee -a .logs/$*.splf

# Service Programs
$(PREPATH)/%.SRVPGM: $(PREPATH)/%.MODULE qsrvsrc/%.BND
	liblist -a $(LIBL);\
	system "CRTSRVPGM SRVPGM($(BIN_LIB)/$*) MODULE($(BIN_LIB)/$*) SRCFILE($(BIN_LIB)/QSRVSRC) SRCMBR($*) OPTION(*EVENTF) ACTGRP(*CALLER) BNDDIR($(BIN_LIB)/SAMPLE)" | tee -a .logs/$*.splf

# ILE Programs (from modules)
$(PREPATH)/%.PGM: $(PREPATH)/%.MODULE
	liblist -a $(LIBL);\
	system "CRTPGM PGM($(BIN_LIB)/$*) MODULE($(BIN_LIB)/$*) ACTGRP(*NEW) BNDDIR($(BIN_LIB)/SAMPLE)" | tee -a .logs/$*.splf

# Commands
$(PREPATH)/%.CMD: qcmdsrc/%.CMD
	liblist -a $(LIBL);\
	system "CRTCMD CMD($(BIN_LIB)/$*) PGM($(BIN_LIB)/$*) SRCFILE($(BIN_LIB)/QCMDSRC) SRCMBR($*)" | tee -a .logs/$*.splf

# Binding Directories
$(PREPATH)/%.BNDDIR: qbndsrc/%.BNDDIR
	-system -q "DLTBNDDIR BNDDIR($(BIN_LIB)/$*)"
	system "CRTBNDDIR BNDDIR($(BIN_LIB)/$*)" | tee -a .logs/$*.splf

# Message Files
$(PREPATH)/%.MSGF: qmsgfsrc/%.MSGF
	-system -q "DLTMSGF MSGF($(BIN_LIB)/$*)"
	system "CRTMSGF MSGF($(BIN_LIB)/$*)" | tee -a .logs/$*.splf

# Panel Groups
$(PREPATH)/%.PNLGRP: qpnlsrc/%.PNLGRP
	liblist -a $(LIBL);\
	system "CRTPNLGRP PNLGRP($(BIN_LIB)/$*) SRCFILE($(BIN_LIB)/QPNLSRC) SRCMBR($*) OPTION(*EVENTF)" | tee -a .logs/$*.splf

# Menus
$(PREPATH)/%.MENU: qpnlsrc/%.MENU
	liblist -a $(LIBL);\
	system "CRTMNU MENU($(BIN_LIB)/$*) TYPE(*UIM) SRCFILE($(BIN_LIB)/QPNLSRC) SRCMBR($*)" | tee -a .logs/$*.splf

# Data Areas
$(PREPATH)/%.DTAARA: qdtasrc/%.DTAARA
	-system -q "DLTDTAARA DTAARA($(BIN_LIB)/$*)"
	system "CRTDTAARA DTAARA($(BIN_LIB)/$*) TYPE(*CHAR) LEN(10) VALUE('0000000000')" | tee -a .logs/$*.splf

# SQL Tables
$(PREPATH)/%.TABLE: qsqlsrc/%.TABLE
	liblist -a $(LIBL);\
	system "RUNSQLSTM SRCFILE($(BIN_LIB)/QSQLSRC) SRCMBR($*) COMMIT(*NONE) NAMING(*SQL)" | tee -a .logs/$*.splf

# SQL Views
$(PREPATH)/%.VIEW: qsqlsrc/%.VIEW
	liblist -a $(LIBL);\
	system "RUNSQLSTM SRCFILE($(BIN_LIB)/QSQLSRC) SRCMBR($*) COMMIT(*NONE) NAMING(*SQL)" | tee -a .logs/$*.splf

# SQL Procedures
$(PREPATH)/%.SQLPRC: qsqlsrc/%.SQLPRC
	liblist -a $(LIBL);\
	system "RUNSQLSTM SRCFILE($(BIN_LIB)/QSQLSRC) SRCMBR($*) COMMIT(*NONE) NAMING(*SQL)" | tee -a .logs/$*.splf

# SQL Triggers
$(PREPATH)/%.SQLTRG: qsqlsrc/%.SQLTRG
	liblist -a $(LIBL);\
	system "RUNSQLSTM SRCFILE($(BIN_LIB)/QSQLSRC) SRCMBR($*) COMMIT(*NONE) NAMING(*SQL)" | tee -a .logs/$*.splf

# SQL UDFs
$(PREPATH)/%.SQLUDF: qsqlsrc/%.SQLUDF
	liblist -a $(LIBL);\
	system "RUNSQLSTM SRCFILE($(BIN_LIB)/QSQLSRC) SRCMBR($*) COMMIT(*NONE) NAMING(*SQL)" | tee -a .logs/$*.splf

# SQL Sequences
$(PREPATH)/%.SQLSEQ: qsqlsrc/%.SQLSEQ
	liblist -a $(LIBL);\
	system "RUNSQLSTM SRCFILE($(BIN_LIB)/QSQLSRC) SRCMBR($*) COMMIT(*NONE) NAMING(*SQL)" | tee -a .logs/$*.splf

# Made with Bob
