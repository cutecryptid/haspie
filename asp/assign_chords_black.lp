#const base = 21.

% define the possible grades
pos_grade(1..7).
pos_chord(G\7,(G+2)\7,(G+4)\7) :- pos_grade(G).
% note that seventh grade will be 0 because modulo reasons

% translate note value into semitone value (skipping silences)
sem_tones(V,((N - base) \ 12),T) :- note(V,N,T), N > 0.

% translate semitone value to chord (major mode)
grade(V,1,T) :- sem_tones(V,3,T).
grade(V,2,T) :- sem_tones(V,5,T).
grade(V,3,T) :- sem_tones(V,7,T).
grade(V,4,T) :- sem_tones(V,8,T).
grade(V,5,T) :- sem_tones(V,10,T).
grade(V,6,T) :- sem_tones(V,0,T).
grade(V,0,T) :- sem_tones(V,2,T).

% number of voices that play at least one note
voice(V) :- grade(V,_,_).
% times in the score that contain a least one note
time(T) :- grade(_,_,T).

% assign one chord to each time of the score where a note plays in at least one voice
1 { chord(G1,G2,G3,T) : pos_chord(G1,G2,G3) } 1 :- time(T).

% playing chord must contain only playing grades that are playing at that given time
% in other words prohibit chords that don't contain all the playing grades
:- chord(G1,G2,G3,T), grade(V,G,T), G!=G1, G!=G2, G!=G3, voice(V), time(T). 

% project the chords 
chord(G1,T) :- chord(G1,_,_,T).

#hide.
#show chord/2.