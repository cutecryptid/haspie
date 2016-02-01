%This sample is the default configuration. Use it as reference.
%Any omitted field will use the same value specified here.
%To don't use a particular preference weight it 0

%Harmonization preferences
%-------------------------
%Order of relevance (higher means more relevant), all of them should be different
#const chord_errorinstrongp = 3.
#const chord_samechordp = 2.
#const chord_errorinweakp = 1.

%How much does each occurence matter in terms of maxing/mining
%Use 0 to turn an optimization off
#const chord_errorinstrongw = 1.
#const chord_samechordw = 1.
#const chord_errorinweakw = 1.

%Score completion preferences
%----------------------------
%Order of relevance (higher means more relevant), all of them should be different
#const note_errorinstrong = 8.
#const note_repeatedgrade = 7.
#const unison = 6.
%Only if -M option is being used
#const melodicjump = 5.
%Only if -6 option is being used
#const sixthlink = 4.
%Only if -M option is being used
#const conttendency = 3.
%Only if -M option is being used
#const sametendency = 2.
#const errorinweak = 1.


%How much does each occurence matter in terms of maxing/mining
%Use 0 to turn an optimization off
#const note_errorinstrongw = 1.
#const unisonw = 1.
#const repeatedgradew = 1.
%Only if -M option is being used
#const melodicjumpw = 1.
%Only if -6 option is being used
#const sixthlinkw = 1.
%Only if -M option is being used
#const conttendencyw = 1.
%Only if -M option is being used
#const sametendencyw = 1.
#const note_errorinweakw = 1.