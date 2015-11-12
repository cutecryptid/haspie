%{
#include <stdlib.h>
#include "mxml_asp.tab.h"
%}
note "note"
step "step"
rest "rest"
chord "chord"
octave "octave"
lyric "lyric"
optype "<type>"
cltype "</type>"
alteration "alteration"
part "part id="
doctype "DOCTYPE"
texttag "text"
beats "beats"
beattype "beat-type"
type "type"
text [-.A-Za-z0-9:\\]+
ques_montgomery [?]
excl [!]
open [<]
close [>]
manubrio [/]
equal [=]
kvothe [\"]
%%
{ques_montgomery} {return QUES;}
{excl} {return EXCL;}
{open} {return OPTAG;}
{close} {return CLTAG;}
{manubrio} {return SLASHTAG;}
{equal} {return EQUAL;}
{kvothe} {return KVOTHE;}
{chord} {return CHORD;}
{note} {return NOTE;}
{step} {return STEP;}
{octave} {return OCTA;}
{optype} {return OPTYPE;}
{cltype} {return CLTYPE;}
{alteration} {return ALTER;}
{part} {return PART_ID;}
{doctype} {return DOCTYPE;}
{rest} {return REST;}
{texttag} {return LYRICTEXT;}
{text} {yylval.valStr=strdup(yytext); return TEXT;}
{beats} {return BEATS;}
{beattype} {return BEATTYPE;}
{type} {return TYPE;}
. ;
\n ;
%%