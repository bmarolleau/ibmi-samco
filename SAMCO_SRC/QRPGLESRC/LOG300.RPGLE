**FREE
//%METADATA                                                                          *
// %TEXT Add entry to log (fixed)                                                    *
//%EMETADATA                                                                         *
//   %XREF XREFTYPE(*OBJ)   OBJ(SAMLOG) OBJTYPE(*USRSPC)   USAGE(*UPD)

Ctl-Opt nomain;

/copy ../qprotosrc/apicall.rpgleinc
/copy ../qprotosrc/log.rpgleinc
Dcl-Pr init End-Pr;

Dcl-S pos             Int(10)         based(p1);
Dcl-S data            Char(600)       based(p2);
Dcl-S usrspc          Char(20);
Dcl-S inz             Ind;
Dcl-S User            Char(10)        inz(*USER);

Dcl-Proc AddLogEntry export;
  Dcl-Pi AddLogEntry;
    entry           Char(500)       value;
  End-Pi;

  Dcl-S data2           VarChar(500);
 if not inz;
   init();
 endif;
 p2 = p1 + pos;
 data2 = 'User: ' +user + ' * ';
 data2 += 'Date: '  + %char(%Timestamp()) + ' * ' ;
 data2 += 'Msg: '  + %trim(entry) + ' ***' ;
 data = data2;
 pos += %len(data2);

End-Proc AddLogEntry;

Dcl-Proc init;
  Dcl-Pi init End-Pi;

 usrspc = 'SAMLOG    *LIBL';
 inz = *on;
 rtvusrspcptr(usrspc:p1);

End-Proc init;