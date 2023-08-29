**FREE
//%METADATA                                                                          *
// %TEXT Function Article                                                            *
//%EMETADATA                                                                         *
Ctl-Opt nomain;

Dcl-F ARTICLE1   Keyed usropn;

/copy ../qprotosrc/ARTICLE.RPGLEINC

Dcl-Pr chainARTICLE1;
  P_ARID          Char(6)         value;
End-Pr;

Dcl-S K_ARID          LIKE(ARID);

//=============================================
Dcl-Proc GetArtDesc export;
  Dcl-Pi GetArtDesc like(ardesc);
    P_ARID          Char(6)         value;
  End-Pi;
  chainARTICLE1(P_ARID
        );
  return ARDESC;
End-Proc GetArtDesc;
//=============================================
Dcl-Proc GetArtRefSalPrice export;
  Dcl-Pi GetArtRefSalPrice like(arsalepr);
    P_ARID          Char(6)         value;
  End-Pi;
  chainARTICLE1(P_ARID
        );
  return ARSALEPR;
End-Proc;
//=============================================
Dcl-Proc GetArtStockPrice export;
  Dcl-Pi GetArtStockPrice like(arwhspr);
    P_ARID          Char(6)         value;
  End-Pi;
  chainARTICLE1(P_ARID
        );
  return ARWHSPR;
End-Proc;
//=============================================
Dcl-Proc GetArtFam export;
  Dcl-Pi GetArtFam like(artifa);
    P_ARID          Char(6)         value;
  End-Pi;
  chainARTICLE1(P_ARID
        );
  return ARTIFA;
End-Proc GetArtFam;
//=============================================
Dcl-Proc GetArtStock export;
  Dcl-Pi GetArtStock like(arstock);
    P_ARID          Char(6)         value;
  End-Pi;
  chainARTICLE1(P_ARID
        );
  return ARSTOCK;
End-Proc GetArtStock;
//=============================================
Dcl-Proc GetArtMinStock export;
  Dcl-Pi GetArtMinStock like(arminqty);
    P_ARID          Char(6)         value;
  End-Pi;
  chainARTICLE1(P_ARID
        );
  return ARMINQTY;
End-Proc GetArtMinStock;
//=============================================
Dcl-Proc GetArtVatCode export;
  Dcl-Pi GetArtVatCode like(arvatcd);
    P_ARID          Char(6)         value;
  End-Pi;
  chainARTICLE1(P_ARID
        );
  return ARvatcd ;
End-Proc GetArtVatCode;
//=============================================
Dcl-Proc ExistArt export;
  Dcl-Pi ExistArt Ind;
    P_ARID          Char(6)         value;
  End-Pi;
  chainARTICLE1(P_ARID
        );
  return %found(article1) and ardel <> 'X';
End-Proc ExistArt;

//=============================================
Dcl-Proc IsArtDeleted export;
  Dcl-Pi IsArtDeleted Ind;
    P_ARID          Char(6)         value;
  End-Pi;
  chainARTICLE1(P_ARID
        );
  return ArDEL = 'X';
End-Proc IsArtDeleted;

Dcl-Proc chainARTICLE1;
  Dcl-Pi chainARTICLE1;
    P_ARID          Char(6)         value;
  End-Pi;
 if not %open(ARTICLE1);
   open ARTICLE1;
 endif;
  if P_ARID <> ARID;
    K_ARID =  P_ARID;
    clear *all FARTI;
    chain K_ARID ARTICLE1;
  endif;
End-Proc chainARTICLE1;

Dcl-Proc closeARTICLE1;
  Dcl-Pi closeARTICLE1 End-Pi;
 if %open(ARTICLE1);
   close ARTICLE1;
 endif;
End-Proc closeARTICLE1;