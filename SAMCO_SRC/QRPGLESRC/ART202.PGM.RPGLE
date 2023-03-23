**FREE
//%METADATA                                                                          *
// %TEXT Work with article                                                           *
//%EMETADATA                                                                         *

Ctl-Opt dftactgrp(*no) bnddir('SAMPLE');

Dcl-F artiprov   Usage(*Update:*Delete:*Output) Keyed;
Dcl-F art202d    WORKSTN
                         indds(indds)
                         sfile(sfl01:rrn01)
                         Infds(Info);

/copy ../QPROTOSRC/PROVIDER.RPGLEINC
/copy ../QPROTOSRC/ARTICLE.RPGLEINC

Dcl-Pr art202;
  prid            like(apprid);
End-Pr;

Dcl-Pi art202;
  prid            like(apprid);
End-Pi;

Dcl-Ds indds;
  help            Ind             Pos(1);
  exit            Ind             Pos(3);
  prompt          Ind             Pos(4);
  refresh         Ind             Pos(5);
  cancel          Ind             Pos(12);
  morekeys        Ind             Pos(24);
  pagedown        Ind             Pos(25);
  sflclr          Ind             Pos(30);
  sfldsp          Ind             Pos(31);
  sfldspctl       Ind             Pos(32);
  sflnxtchg       Ind             Pos(33);
  dspatr_ri       Ind             Pos(34);
  sflmsg          Ind             Pos(35);
  errFamilly      Ind             Pos(40);
  errDesc         Ind             Pos(41);
  sflend          Ind             Pos(80);
End-Ds;

Dcl-Ds info;
  lrrn            Int(5)          Pos(378);
End-Ds;

Dcl-S rrn01           Int(5);
Dcl-S rrs01           Int(5);
Dcl-S err01           Ind;

Dcl-S panel           Int(3)          INZ(1);
Dcl-S step01          Char(3)         inz(prp);
Dcl-S step02          Char(3)         inz(prp);
Dcl-S savId           like(prid);
Dcl-S User            Char(10)        inz(*user);
Dcl-S count           Int(3);
Dcl-S mode            Char(3);

Dcl-C crt             'CRT';
Dcl-C upd             'UPD';
Dcl-C prp             'prp';
Dcl-C lod             'lod';
Dcl-C dsp             'dsp';
Dcl-C key             'key';
Dcl-C chk             'chk';
Dcl-C chkctl          'chc';
Dcl-C actctl          'acc';
Dcl-C act             'act';
select;
when panel = 1;
  exsr pnl01;
when panel = 2;
  exsr pnl02;
other;
  exsr pnl00;
endsl;
//- Subfiles  01 Subroutines --------------------------------------  ---
begsr pnl01;
  select ;
  when step01 = prp ;
    exsr s01prp;
  when step01 = lod ;
    exsr s01lod;
  when step01 = dsp ;
    exsr s01dsp;
  when step01 = key ;
    exsr s01key;
  when step01 = chk ;
    exsr s01chk;
  when step01 = act ;
    exsr s01act ;
  endsl;
endsr;
//--- Clear Subfile  ----------------------------------------------------
begsr s01prp;
  RRn01 = 0;
  sflclr = *on;
  write ctl01;
  sflclr = *off;
  provnm = GetProName(prid);
  step01 = lod;
endsr;
//--- Load Subfile  -----------------------------------------------------
begsr s01lod;
  RRb01 = RRn01 + 1;
  opt01 = 0;
  setll prid artiprov;
  reade(n) prid artiprov;
  dow not %eof(artiprov);
    ardesc = GetArtDesc(aparid);
    RRN01 += 1;
    write sfl01;
    reade(n) prid artiprov;
  enddo;
  sflend = *on ;
  step01 = dsp;
endsr;
//--- Display Subfile  --------------------------------------------------
begsr s01dsp;
  sfldspctl = *on;
  sfldsp = RRn01 > 0;

  write key01;
  exfmt ctl01;
  if LRRN <>0;
    RRb01 = LRRN;
  endif;
  step01 = key;
endsr;
//--- Command Keys  -----------------------------------------------------
begsr s01key;
  select;
  when exit;
    panel  = 0;
    step01 = prp;
  when cancel;
    step01 = prp;
    panel  = panel  - 1;
  other;
    step01 = chk;
  endsl;
endsr;
//--- Check Subfile  ----------------------------------------------------
begsr s01chk;
  step01 = act;
  err01 = *off;
  sflnxtchg = *on;
  readc(e) sfl01;
  dow not %error and not %eof;
    if opt01 <> 0 and opt01 <> 2;
      step01 = dsp;
      dspatr_ri = *on;
      sflmsg = *on;
      if not err01;
        rrb01 = rrn01;
        err01 = *on;
      endif;
    endif;
    update sfl01;
    dspatr_ri = *off;
    readc(e) sfl01;
  enddo;
  sflnxtchg = *off;
endsr;
//--- action Subfile  ---------------------------------------------------
begsr s01act;
  readc(e) sfl01;
  select;
  when %error or %eof;
    step01 = dsp;
  when opt01 = 2;
    panel = 2;
    step02 = prp;
    opt01 = 0;
    update sfl01;
  other;

  endsl;
endsr;


//--- Format 02 Subroutines ------------------------------------     ---
begsr pnl02;
  select ;
  when step02 = prp ;
    exsr s02prp;
  when step02 = dsp ;
    exsr s02dsp;
  when step02 = key ;
    exsr s02key;
  when step02 = chk ;
    exsr s02chk;
  when step02 = act ;
    exsr s02act ;
  endsl;

endsr;
//--- clear & Load ------------------------------------------------------
begsr S02prp;
  chain (prid: aparid) artiprov;
  step02 = dsp;
endsr;
//--- Display  ----------------------------------------------------------
begsr S02dsp;
  exfmt fmt02;
  step02 = key;
endsr;
//--- command Keys  -----------------------------------------------------
begsr S02key;
  select;
  when exit;
    panel  = 1;
    step02 = prp;
  when cancel;
    step02 = prp;
    panel  = panel  - 1;
  other;
    step02 = chk;
  endsl;
endsr;
//--- check -------------------------------------------------------------
begsr S02chk;
  step02 = act;

endsr;
//--- Action ------------------------------------------------------------
begsr S02act;
  step02 = prp;
  if mode = upd;
    apmod = %timestamp();
    apmodid = user;
    update farpr;
  endif;
  panel = 1;
endsr;

//--------INITIALIZATION ----------------------------------
begsr *inzsr;
endsr;
//--------END SUBROUTINE ----------------------------------
begsr pnl00;
  *inlr = *on;
endsr;