**FREE
//%METADATA                                                                          *
// %TEXT Work with Customer Orders                                                   *
//%EMETADATA                                                                         *

Ctl-Opt dftactgrp(*no) bnddir('SAMPLE');

Dcl-F order1     Usage(*Update:*Delete) Keyed;
Dcl-F detord1    Usage(*Update:*Delete) Keyed;
Dcl-F custome1   Keyed;
Dcl-F ord200d    WORKSTN
                         indds(indds)
                         sfile(sfl01:rrn01)
                         Infds(Info);

Dcl-Pr ord200;
  cuid            like(orcuid);
End-Pr;

Dcl-Pi ord200;
  cuid            like(orcuid);
End-Pi;

Dcl-Pr Updord extpgm('ORD101');
  x               like(orid);
End-Pr;

Dcl-Pr dspord extpgm('ORD202');
  x               like(orid);
End-Pr;

Dcl-Pr Prtord extpgm('ORD500');
  x               like(orid);
End-Pr;

Dcl-Pr NewOrder extpgm('ORD100C');
  x               like(cuid);
End-Pr;

Dcl-Ds indds;
  help            Ind             Pos(1);
  exit            Ind             Pos(3);
  prompt          Ind             Pos(4);
  refresh         Ind             Pos(5);
  create          Ind             Pos(6);
  cancel          Ind             Pos(12);
  morekeys        Ind             Pos(24);
  pagedown        Ind             Pos(25);
  sflclr          Ind             Pos(30);
  sfldsp          Ind             Pos(31);
  sfldspctl       Ind             Pos(32);
  sflnxtchg       Ind             Pos(33);
  dspatr_ri       Ind             Pos(34);
  sflmsg          Ind             Pos(35);
  sflmsg2         Ind             Pos(36);
  sflmsg3         Ind             Pos(37);
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
Dcl-S savId           like(cuid);
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
Dcl-C act             'act';
Dcl-C datBlank        d'1940-01-01';
select;
when panel = 1;
  exsr pnl01;
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
  exec sql declare c1 cursor for
    SELECT ORID, ORYEAR,
           ISOTODATE40(ORDATE) AS DATORD,
           ISOTODATE40(ORDATDEL) AS DATLIV,
           ISOTODATE40( ORDATCLO) AS DATCLO ,
           Totval
    FROM Ordercus
    Where orcuid  = :cuid
    order by datord desc;
  exec sql open c1;
  step01 = lod;
endsr;
//--- Load Subfile  -----------------------------------------------------
begsr s01lod;
  RRb01 = RRn01 + 1;
  opt01 = 0;
  exec sql fetch c1 into :orid, :oryear, :datord,
                         :datliv, :datclo, :sumord;
  dow sqlcod = 0;
    RRN01 += 1;
    write sfl01;
    exec sql fetch c1 into :orid, :oryear, :datord,
                         :datliv, :datclo, :sumord;
  enddo;
  exec sql close c1;
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
  when create;
    newOrder(cuid);
    step01 = prp;
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
    if opt01 = 1  or opt01 = 3  or  opt01  > 8;
      step01 = dsp;
      dspatr_ri = *on;
      sflmsg = *on;
      if not err01;
        rrb01 = rrn01;
        err01 = *on;
      endif;
    endif;
    if opt01 = 7 and datclo > datBlank
      or opt01 = 8 and datliv > datBlank;
      step01 = dsp;
      dspatr_ri = *on;
      sflmsg = *on;
      if not err01;
        rrb01 = rrn01;
        err01 = *on;
      endif;
    endif;
    if opt01 = 2 or opt01 = 4 and datclo > datBlank;
      step01 = dsp;
      dspatr_ri = *on;
      sflmsg2 = *on;
      if not err01;
        rrb01 = rrn01;
        err01 = *on;
      endif;
    endif;
    if opt01 = 4;
      setll orid detord1;
      reade(n) orid detord1;
      dow not %eof();
        if odqtyliv > 0;
          step01 = dsp;
          dspatr_ri = *on;
          sflmsg3 = *on;
          if not err01;
            rrb01 = rrn01;
            err01 = *on;
          endif;
          leave;
        endif;
        reade(n) orid detord1;
      enddo;
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
    Updord(orid);
    opt01 = 0;
    update sfl01;
  when opt01 = 4;
    delete orid order1;
    dou not %found();
      delete orid detord1;
    enddo;
    opt01 = 0;
    update sfl01;
  when opt01 = 5;
    dspord(orid);
    opt01 = 0;
    update sfl01;
  when opt01 = 6;
    Prtord(orid);
    opt01 = 0;
    update sfl01;
  when opt01 = 7;
    chain (orid) order1;
    if ordatdel = 0;
      ordatdel = %dec(%date():*iso);
      datliv = %date();
    endif;
    ordatclo = %dec(%date():*iso);
    update forde;
    datclo = %date();
    opt01 = 0;
    update sfl01;
  when opt01 = 8;
    chain (orid) order1;
    ordatdel = %dec(%date():*iso);
    datliv = %date();
    update forde;
    setll orid detord1;
    reade orid detord1;
    dow not %eof();
      if odqtyliv = 0;
        odqtyliv = odqty;
        update fdeto;
      else;
        unlock detord1;
      endif;
      reade orid detord1;
    enddo;
    opt01 = 0;
    update sfl01;
  other;

  endsl;
endsr;

//--------INITIALIZATION ----------------------------------
begsr *inzsr;
  datord = datBlank;
  datclo = datBlank;
  datliv = datBlank;
  chain cuid custome1;
endsr;
//--------END SUBROUTINE ----------------------------------
begsr pnl00;
  *inlr = *on;
endsr;