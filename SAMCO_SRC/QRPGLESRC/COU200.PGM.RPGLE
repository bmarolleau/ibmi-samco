**FREE

//==============================================================================
// Program: COU200 - Work with Countries
// Description: Country maintenance program with subfile list and edit screen
// Converted from RPG to modern ILE RPGLE with free-format syntax
//==============================================================================

ctl-opt dftactgrp(*no) actgrp(*caller) option(*nodebugio:*srcstmt)
        bnddir('SAMPLE');

// File declarations
dcl-f COU200D workstn sfile(SFL01:RRN01) infds(screenInfo) indds(indicators);
dcl-f COUNTRY usage(*update:*delete:*output) keyed;

// Data structures
dcl-ds screenInfo;
  lastRRN int(5) pos(378);
end-ds;

dcl-ds indicators;
  exit ind pos(3);
  cancel ind pos(12);
  sflClear ind pos(30);
  sflDisplay ind pos(31);
  sflDisplayCtl ind pos(32);
  sflNextChg ind pos(33);
  optionError ind pos(34);
  msgError ind pos(35);
  sflEnd ind pos(80);
  notFound ind pos(98);
  endOfFile ind pos(99);
end-ds;

// Standalone variables
dcl-s panel int(10);
dcl-s step01 char(3);
dcl-s step02 char(3);
dcl-s RRN01 int(10);
dcl-s RRB01 int(10);
dcl-s hasError ind;
dcl-s continueProgram ind inz(*on);

// Constants
dcl-c STEP_PREPARE 'PRP';
dcl-c STEP_LOAD 'LOD';
dcl-c STEP_DISPLAY 'DSP';
dcl-c STEP_KEY 'KEY';
dcl-c STEP_CHECK 'CHK';
dcl-c STEP_ACTION 'ACT';
dcl-c PANEL_LIST 1;
dcl-c PANEL_EDIT 2;
dcl-c OPT_EDIT 2;

//==============================================================================
// Main program logic
//==============================================================================

initialize();

dow continueProgram;
  select;
    when panel = PANEL_LIST;
      processListPanel();
    when panel = PANEL_EDIT;
      processEditPanel();
    other;
      continueProgram = *off;
  endsl;
enddo;

*inlr = *on;
return;

//==============================================================================
// Initialize program
//==============================================================================
dcl-proc initialize;
  panel = PANEL_LIST;
  step01 = STEP_PREPARE;
  step02 = STEP_PREPARE;
end-proc;

//==============================================================================
// Process List Panel (Panel 1)
//==============================================================================
dcl-proc processListPanel;
  dcl-s done ind;
  
  done = *off;
  dow not done;
    select;
      when step01 = STEP_PREPARE;
        prepareSubfile();
      when step01 = STEP_LOAD;
        loadSubfile();
      when step01 = STEP_DISPLAY;
        displaySubfile();
      when step01 = STEP_KEY;
        done = processListKeys();
      when step01 = STEP_CHECK;
        checkSubfileOptions();
      when step01 = STEP_ACTION;
        done = processSubfileActions();
    endsl;
  enddo;
end-proc;

//==============================================================================
// Prepare subfile for loading
//==============================================================================
dcl-proc prepareSubfile;
  RRN01 = 0;
  sflClear = *on;
  write CTL01;
  sflClear = *off;
  step01 = STEP_LOAD;
end-proc;

//==============================================================================
// Load subfile with country records
//==============================================================================
dcl-proc loadSubfile;
  RRB01 = RRN01 + 1;
  
  setll *loval COUNTRY;
  read COUNTRY;
  endOfFile = %eof(COUNTRY);
  
  dow not endOfFile;
    RRN01 += 1;
    write SFL01;
    read COUNTRY;
    endOfFile = %eof(COUNTRY);
  enddo;
  
  step01 = STEP_DISPLAY;
end-proc;

//==============================================================================
// Display subfile
//==============================================================================
dcl-proc displaySubfile;
  sflDisplayCtl = *on;
  sflDisplay = (RRN01 > 0);
  
  write KEY01;
  exfmt CTL01;
  
  if lastRRN > 0;
    RRB01 = lastRRN;
  endif;
  
  step01 = STEP_KEY;
end-proc;

//==============================================================================
// Process function keys on list panel
//==============================================================================
dcl-proc processListKeys;
  dcl-s exitPanel ind;
  
  exitPanel = *off;
  
  select;
    when exit or cancel;
      continueProgram = *off;
      exitPanel = *on;
    other;
      step01 = STEP_CHECK;
  endsl;
  
  return exitPanel;
end-proc;

//==============================================================================
// Check subfile options for errors
//==============================================================================
dcl-proc checkSubfileOptions;
  step01 = STEP_ACTION;
  hasError = *off;
  sflNextChg = *on;
  
  readc SFL01;
  endOfFile = %eof(COU200D);
  
  dow not endOfFile;
    if OPT01 <> 0 and OPT01 <> OPT_EDIT;
      step01 = STEP_DISPLAY;
      optionError = *on;
      msgError = *on;
      
      if not hasError;
        RRB01 = RRN01;
        hasError = *on;
      endif;
    endif;
    
    update SFL01;
    optionError = *off;
    
    readc SFL01;
    endOfFile = %eof(COU200D);
  enddo;
  
  sflNextChg = *off;
end-proc;

//==============================================================================
// Process subfile actions
//==============================================================================
dcl-proc processSubfileActions;
  dcl-s exitPanel ind;
  
  exitPanel = *off;
  readc SFL01;
  endOfFile = %eof(COU200D);
  
  select;
    when endOfFile;
      step01 = STEP_DISPLAY;
    when OPT01 = OPT_EDIT;
      panel = PANEL_EDIT;
      step02 = STEP_PREPARE;
      OPT01 = 0;
      update SFL01;
      exitPanel = *on;
  endsl;
  
  return exitPanel;
end-proc;

//==============================================================================
// Process Edit Panel (Panel 2)
//==============================================================================
dcl-proc processEditPanel;
  dcl-s done ind;
  
  done = *off;
  dow not done;
    select;
      when step02 = STEP_PREPARE;
        prepareEdit();
      when step02 = STEP_DISPLAY;
        displayEdit();
      when step02 = STEP_KEY;
        done = processEditKeys();
      when step02 = STEP_CHECK;
        checkEditData();
      when step02 = STEP_ACTION;
        done = saveEditData();
    endsl;
  enddo;
end-proc;

//==============================================================================
// Prepare edit screen
//==============================================================================
dcl-proc prepareEdit;
  step02 = STEP_DISPLAY;
  chain COID COUNTRY;
  notFound = not %found(COUNTRY);
end-proc;

//==============================================================================
// Display edit screen
//==============================================================================
dcl-proc displayEdit;
  exfmt FMT02;
  step02 = STEP_KEY;
end-proc;

//==============================================================================
// Process function keys on edit panel
//==============================================================================
dcl-proc processEditKeys;
  dcl-s exitPanel ind;
  
  exitPanel = *off;
  
  select;
    when exit;
      continueProgram = *off;
      exitPanel = *on;
    when cancel;
      panel = PANEL_LIST;
      exitPanel = *on;
    other;
      step02 = STEP_CHECK;
  endsl;
  
  return exitPanel;
end-proc;

//==============================================================================
// Check edit data for errors
//==============================================================================
dcl-proc checkEditData;
  // Add validation logic here if needed
  step02 = STEP_ACTION;
end-proc;

//==============================================================================
// Save edited data
//==============================================================================
dcl-proc saveEditData;
  update FCOUN;
  panel = PANEL_LIST;
  return *on;
end-proc;