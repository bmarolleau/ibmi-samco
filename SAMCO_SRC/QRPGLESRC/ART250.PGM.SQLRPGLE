      *%METADATA                                                                          *
      * %TEXT Display Article                                                             *
      *%EMETADATA                                                                         *
       ctl-opt dftactgrp(*NO) bnddir('SAMPLE');

       Dcl-F  art250d workstn
         SFILE(SFL03:RRN03)
         Infds(Info)
         indds(indds);
       dcl-f  article1 disk keyed;
       dcl-f  artipro2 disk keyed;

      /copy qprotosrc,familly
      /copy qprotosrc,article
      /copy qprotosrc,vat

       dcl-pr Providers extpgm('ART201');
         id   like(arid);
       end-pr;

       Dcl-Ds indds;
         help            Ind             Pos(1);
         exit            Ind             Pos(3);
         prompt          Ind             Pos(4);
         refresh         Ind             Pos(5);
         DspProvider     Ind             Pos(7);
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
       Dcl-Ds info;
         lrrn            Int(5)          Pos(378);
       End-Ds;

       Dcl-S panel           Packed(3:0)     INZ(1);
       Dcl-S step01          Char(3)         inz(prp);
       Dcl-S step02          Char(3)         inz(prp);
       Dcl-S step03          Char(3)         inz(prp);
       dcl-s id              like(arid);
       dcl-s likeid          varchar(8);
       Dcl-S rrn03           Int(5);
       Dcl-S rrs03           Int(5);
       Dcl-S i               Int(5);
       Dcl-S err03           Ind;


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
       when panel = 3;
         exsr pnl03;
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
         id = arid;
       endsr;
       //--- command Keys  -----------------------------------------------------
       begsr S01key;
         select;
         when exit;
           panel  = 0;
           step01 = prp;
         when prompt;
           id = SltArticle(id);
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
         chain id article1;
         if not %found();
           panel = 3;
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
         step02 = dsp;
         fadesc = GetArtFamDesc(ARTIFA);
         VATINCL = CLCVat(ARVATCD:ARSALEPR);
         STOPRICE = ARSTOCK * ARWHSPR;
         info = GetArtInfo(arid);
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
         when dspProvider;
           step02 = prp;
           providers(arid);
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

       //- Subfiles  03 Subroutines --------------------------------------  ---
       begsr pnl03;
         select ;
         when step03 = prp ;
           exsr s03prp;
         when step03 = lod ;
           exsr s03lod;
         when step03 = dsp ;
           exsr s03dsp;
         when step03 = key ;
           exsr s03key;
         when step03 = chk ;
           exsr s03chk;
         when step03 = act ;
           exsr s03act ;
         endsl;
       endsr;
       //--- Clear Subfile  ----------------------------------------------------
       begsr s03prp;
         RRn03 = 0;
         sflclr = *on;
         write ctl03;
         sflclr = *off;
         likeId = '%' + %trim(id) + '%';
         exec sql declare c1 cursor for
           select ARID, ARDESC, artifa from article
             where arid like :likeId;
         exec sql open c1;
         step03 = lod;
         sflend = *off;
       endsr;
       //--- Load Subfile  -----------------------------------------------------
       begsr s03lod;
         exec sql fetch c1 into :arid, :ardesc, :artifa;
         if sqlcod = 0;
           RRb03 = RRn03 + 1;
           opt03 = 0;
           for i = 1 to 16;
             RRN03 = RRN03 + 1;
             write sfl03;
             if i < 16;
               exec sql fetch c1 into :arid, :ardesc, :artifa;
               if sqlcod <>  0;
                 sflend = *on;
                 leave;
               ENDIF;
             ENDIF;
           endfor;
           step03 = dsp;
         // if result = 0
         elseif rrn03 = 0;
           notFound = *on;
           errdata = id;
           step01 = dsp;
           panel = 1;
           step03 = prp;
           sflend = *on;
         else;
           sflend = *on;
         endif;
         if sflend;
           exec sql close c1;
         ENDIF;
       endsr;
       //--- Display Subfile  --------------------------------------------------
       begsr s03dsp;
         sfldspctl = *on;
         sfldsp = RRn03 > 0;

         write key03;
         exfmt ctl03;
         if LRRN <>0;
           RRb03 = LRRN;
         endif;
         step03 = key;
       endsr;
       //--- Command Keys  -----------------------------------------------------
       begsr s03key;
         select;
         when exit;
           panel  = 1;
           step03 = prp;
           arid = id;
           exec sql close c1;
         when cancel;
           step03 = prp;
           panel  = 1;
           arid = id;
           exec sql close c1;
         when pagedown;
           step03 = lod;
         other;
           step03 = chk;
         endsl;
       endsr;
       //--- Check Subfile  ----------------------------------------------------
       begsr s03chk;
         step03 = act;
         err03 = *off;
         sflnxtchg = *on;
         readc(e) sfl03;
         dow not %error and not %eof;
           if opt03 > 1;
             step03 = dsp;
             dspatr_ri = *on;
             sflmsg = *on;
             if not err03;
               rrb03 = rrn03;
               err03 = *on;
             endif;
           endif;
           update sfl03;
           dspatr_ri = *off;
           readc(e) sfl03;
         enddo;
         sflnxtchg = *off;
       endsr;
       //--- action Subfile  ---------------------------------------------------
       begsr s03act;
         readc(e) sfl03;
         select;
         when %error or %eof;
           step03 = dsp;
         when opt03 = 1;
           panel = 2;
           chain (arid) article1;
           step03 = prp;
         other;
         endsl;
       endsr;



       //--------INITIALIZATION ----------------------------------
       begsr *inzsr;
       endsr;
       //--------END SUBROUTINE ----------------------------------
       begsr pnl00;
         *inlr = *on;
       endsr;
