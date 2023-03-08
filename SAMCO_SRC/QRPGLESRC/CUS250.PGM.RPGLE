      *%METADATA                                                                          *
      * %TEXT Display customer                                                            *
      *%EMETADATA                                                                         *
       ctl-opt dftactgrp(*NO) bnddir('SAMPLE');

       Dcl-F  cus250d workstn   indds(indds);
       dcl-f  custome1 disk keyed;

      /copy qprotosrc,customer
      /copy qprotosrc,country

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
         NotFound        Ind             Pos(40);
         sflend          Ind             Pos(80);
       End-Ds;

       Dcl-S panel           Packed(3:0)     INZ(1);
       Dcl-S step01          Char(3)         inz(prp);
       Dcl-S step02          Char(3)         inz(prp);
       dcl-s id              like(cuid);

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
       //--- Format 01 Subroutines ------------------------------------     ---
       begsr pnl01;
         select ;
         when step01 = prp ;
           exsr s01prp;
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
       //--- clear & Load ------------------------------------------------------
       begsr S01prp;
         clear fmt01;
         step01 = dsp;
       endsr;
       //--- Display  ----------------------------------------------------------
       begsr S01dsp;
         exfmt fmt01;
         step01 = key;
         id = cuid;
       endsr;
       //--- command Keys  -----------------------------------------------------
       begsr S01key;
         select;
         when exit;
           panel  = 0;
           step01 = prp;
         when prompt;
           id = SltCustomer(id);
           step01 = chk;
         when cancel;
           step01 = prp;
           panel  = panel  - 1;
         other;
           step01 = chk;
         endsl;
       endsr;
       //--- check -------------------------------------------------------------
       begsr S01chk;
         step01 = act;
         chain id custome1;
         if not %found();
           notFound = *on;
           ERRDATA = %editc(id:'Z');
           step01 = dsp;
         endif;

       endsr;
       //--- Action ------------------------------------------------------------
       begsr S01act;
         step01 = dsp;
         panel = 2;
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
         COUNTR = GetCountryName(CUCOUN);
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
         panel = 1;
         step02 = prp;
       endsr;



       //--------INITIALIZATION ----------------------------------
       begsr *inzsr;
       endsr;
       //--------END SUBROUTINE ----------------------------------
       begsr pnl00;
         *inlr = *on;
       endsr;
