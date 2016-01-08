%{
#include <stdlib.h>
#include "mxml_asp.tab.h"
%}
note "note"
step "step"
rest "rest"
chord "chord"
octave "octave"
optype "<type>"
cltype "</type>"
opstaff "<staff>"
clstaff "</staff>"
gracetag "<grace/>"
alteration "alteration"
alter "alter"
part "part id="
scorepart "score-part"
instrument "instrument-name"
doctype "DOCTYPE"
texttag "text"
beats "beats"
beattype "beat-type"
time "time"
dot "dot"
harmony "harmony"
rootstep "root-step"
kind "kind"
fifths "fifths"
mode "mode"
notvisible "print-object=\"no\""
credit "credit-words"
justify "justify"
valign "valign"
text [-.A-Za-z0-9:\[\]\\]+
ques_montgomery [?]
excl [!]
open [<]
close [>]
manubrio [/]
equal [=]
kvothe [\"\']
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
{time} {return TIME;}
{alter} {return ALTER;}
{alteration} {return ALTER;}
{part} {return PART_ID;}
{scorepart} {return SCOREPART;}
{instrument} {return INSTRUMENT;}
{doctype} {return DOCTYPE;}
{rest} {return REST;}
{beats} {return BEATS;}
{beattype} {return BEATTYPE;}
{notvisible} {return NOTVISIBLE;}
{dot} {return DOT;}
{opstaff} {return OPSTAFF;}
{clstaff} {return CLSTAFF;}
{gracetag} {return GRACETAG;}
{harmony} {return HARMONY;}
{rootstep} {return ROOTSTEP;}
{kind} {return KIND;}
{fifths} {return FIFTHS;}
{mode} {return MODE;}
{credit} {return CREDIT;}
{justify} {return JUSTIFY;}
{valign} {return VALIGN;}
{text} {yylval.valStr=strdup(yytext); return TEXT;}
. ;
\n ;
%%