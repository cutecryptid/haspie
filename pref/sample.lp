%This sample is the default configuration. Use it as reference.
%Any omitted field will use the same value specified here.
%To don't use a particular preference weight it 0

%Harmonization preferences
%-------------------------
%Order of relevance (higher means more relevant), all of them should be different
#const errorinstrongp = 3.
#const samechordp = 2.
#const errorinweakp = 1.

%How much does each occurence matter in terms of maxing/mining
#const errorinstrong_weight = 1.
#const samechord_weight = 1.
#const errorinweak_weight = 1.

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
#const note_errorinstrong_weight = 1.
#const unison_weight = 1.
#const repeatedgrade_weight = 1.
%Only if -M option is being used
#const melodicjump_weight = 1.
%Only if -6 option is being used
#const sixthlink_weight = 1.
%Only if -M option is being used
#const conttendency_weight = 1.
%Only if -M option is being used
#const sametendency_weight = 1.
#const note_errorinweak_weight = 1.