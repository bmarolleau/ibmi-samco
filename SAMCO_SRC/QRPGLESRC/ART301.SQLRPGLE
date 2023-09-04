**FREE
//%METADATA                                                                          *
// %TEXT Function Select an article                                                  *
//%EMETADATA                                                                         *
Ctl-Opt nomain;

Dcl-F art301d    WORKSTN
                         INFDS(INFO)
                         SFILE(SFL01:RRN01)
                         indds(indds);
Dcl-Ds INFO;
  LRRN            BinDec(4:0)     Pos(378);
End-Ds;

/copy qprotosrc,article
/copy qprotosrc,familly

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
  dspatrri        Ind             Pos(34);
  InvalidOpt      Ind             Pos(35);
  OneSelect       Ind             Pos(36);
  bydesc          Ind             Pos(40);
  InvalidOptC     Ind             Pos(41);
  NotAvail        Ind             Pos(42);
  sflend          Ind             Pos(80);
End-Ds;

Dcl-Ds data inz;
  arid            Char(6);
  ardesc          Char(50);
  artifa          Char(3);
  arsalePr        Zoned(7:2);
End-Ds;

Dcl-S rrn01           Int(5);

Dcl-C prp             'prp';
Dcl-C lod             'lod';
Dcl-C dsp             'dsp';
Dcl-C key             'key';
Dcl-C chk             'chk';
Dcl-C act             'act';


//=============================================
Dcl-Proc sltarticle export;
  Dcl-Pi sltarticle Char(6);
    pcod            Char(6)         value;
  End-Pi;

  Dcl-Ds savData likeds(data);

  Dcl-S dft             like(arid      );
  Dcl-S step01          Char(3)         inz(prp);
  Dcl-S in08            Ind;
  Dcl-S sts01           Ind;
  Dcl-S rrs01           Int(5);
  Dcl-S teller          Int(5);
  Dcl-S err01           Ind;
  Dcl-S slt01           Ind;
  Dcl-S savDesc         Char(10);
  Dcl-S savFam          like(artifa     );
  Dcl-S stm             VarChar(500);
if not %open(art301d   );
  open art301d    ;
endif;
dft = pcod;
famdesc = '<F4> to select.';
dow step01 <> ' ';
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
enddo;
exec sql close c1;
return dft;
//--- Clear Subfile  -----------------------------------------------------

begsr s01prp;
  RRS01 = 0;
  sflclr = *on;
  sfldsp = *off;
  sfldspctl = *off;
  write CTL01;
  sflclr = *off;
  stm =  'SELECT arid, ardesc, artifa, arsalepr FROM article ';
  if srchDesc <> ' ' and srchFam <> ' ';
    stm +=  ' WHERE artifa = ''' + srchfam +
            ''' AND UPPER(arDesc) like ''%' + %trim(srchDesc) +
           '%'' ';
  elseif srchDesc <> ' ' ;
    stm += ' WHERE UPPER(arDesc) like ''%' + %trim(srchDesc) +
           '%'' ';
  elseif srchFam <> ' ';
    stm +=  ' WHERE artifa = ''' + srchfam + ''' ';
  endif;
  stm += ' ORDER BY arDesc';
  SAVDesc = srchDesc;
  SAVFam  = srchFam ;
  Step01 = lod;
  exec sql prepare s1 from :stm;
  exec sql declare C1 cursor for s1;
  exec sql open c1;
  exec sql fetch c1 into :data;
  savData = data;
endsr;
//--- Load Subfile  -----------------------------------------------------
begsr S01lod;
  RRN01 = RRS01;
  Data = Savdata;
  RRB01 = RRS01 + 1;
  TELLER = 0;
  OPT01 = 0;
  SflNxtChg = *OFF;
  dow sqlcod = 0
        and TELLER < 14;
    RRN01 = RRN01 + 1;
    TELLER = TELLER + 1;
    write SFL01;
    exec sql fetch c1 into :data;
  enddo;
  sflend = sqlcod <> 0;
  savData = data;
  RRS01 = RRN01;
  Step01 = dsp;
endsr;
//--- Display Subfile  --------------------------------------------------
begsr S01dsp;
  sfldsp = rrs01 > 0;
  sfldspctl = *on;
  write KEY01;
  exfmt CTL01;
  RRB01 = LRRN;
  Step01 = key;
endsr;
//--- Command Keys  -----------------------------------------------------
begsr S01key;
  select;
  when exit;
    step01 = ' ';
  when cancel ;
    Step01 = ' ';
  when PageDown;
    Step01 = lod;
  when prompt;
    srchfam = sltArtFam(SrchFam);
    famdesc = getArtFamDesc(SrchFam);
    exec sql close c1;
    step01 = prp;
  other;
    Step01 = chk;
  endsl;
endsr;
//--- Check Subfile  ----------------------------------------------------
begsr S01chk;
  // SET FLAG SELECTION MADE OFF
  SLT01 = *OFF;
  // SET FLAG OPTION  MADE OFF
  STS01 = *OFF;
  // SET FLAG ERROR   MADE OFF
  ERR01 = *OFF;
  Step01 = act;
  readc(E) SFL01;
  SflNxtChg = *ON;
  dow not %error and not %eof;
    select;
    when OPT01 = 0;
      // NO ERROR
    when OPT01 <>1;
      STS01 = *ON;
      Step01 = dsp;
      dspatrRi = *on;
      InvalidOpt= *on;
      if ERR01 = *OFF;
        RRB01 = RRN01;
        ERR01 = *ON;
      endif;
      //OPTION = 1 BUT SELECTION ALREADY MADE
    when SLT01 = *ON;
      Step01 = dsp;
      dspatrRi = *on;
      OneSelect = *on;
      if ERR01 = *OFF;
        RRB01 = RRN01;
        ERR01 = *ON;
      endif;
    other;
      //OPTION = 1
      SLT01 = *ON;
      STS01 = *ON;
    endsl;
    update SFL01;
    dspatrRi = *off;
    readc SFL01;
  enddo;
endsr;
//--- Write Subfile  ----------------------------------------------------
begsr S01act;
  Step01 = dsp;
  select;
  when savDesc <> srchDesc or savfam  <> srchfam ;
    Step01 = prp;
    exec sql close c1;
  other;
    readc(E) SFL01;
    dow not %error and not %eof;
      if OPT01 = 1;
        exec sql close c1;
        return arid      ;
      endif;
      readc SFL01;
    enddo;
  endsl;
endsr;
                                                                                // 
End-Proc sltarticle;