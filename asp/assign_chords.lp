#const base = 21.
#const span = 1.

% define the possible grades
pos_grade(1..7).
pos_chord(G\7,(G+2)\7,(G+4)\7) :- pos_grade(G).
% note that seventh grade will be 0 because modulo reasons

% translate note value into semitone value (skipping silences)
sem_tones(V,((N - base) \ 12),T) :- note(V,N,T), N >= 0.

% number of voices that play at least one note
voice(V) :- grade(V,_,_).
% times in the score that contain a least one note
time(T/span) :- grade(_,_,T), T/span != 0.

% assign one chord to each time of the score where a note plays in at least one voice
1 { chord(G1,G2,G3,T) : pos_chord(G1,G2,G3) } 1 :- time(T).

% playing chord must contain only playing grades that are playing at that given time
% in other words prohibit chords that don't contain all the playing grades
:- chord(G1,G2,G3,T), grade(V,G,T), G!=G1, G!=G2, G!=G3, voice(V), time(T..(T+(span-1))).

% project the chords 
chord(T,G1) :- chord(G1,_,_,T).

#hide.
#show chord/2.