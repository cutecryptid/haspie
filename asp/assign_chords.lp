#const base = 21.
#const span = 1.

% define the possible grades
pos_grade(1..7).

% translate note value into semitone value (skipping silences)
sem_tones(V,((N - base) \ 12),T) :- note(V,N,T), N >= 0.

% number of voices that play at least one note
voice(V) :- grade(V,_,_).
% times in the score that contain a least one note
time(T/span) :- grade(_,_,T), T/span != 0.

% assign one chord to each time of the score where a note plays in at least one voice
1 { chord(T,C) : pos_chord(C) } 1 :- time(T).

% restrict solutions where assignated chords contain grades that are not present
% this is, grades that do not belong to them
error(V,G,T) :- chord(T,C), grade(V,G,T), time(T), voice(V), not belongs(G,C), time(T..(T+(span-1))).	

#minimize[error(_,_,_)].

#hide.
#show chord/2.
#show error/3.