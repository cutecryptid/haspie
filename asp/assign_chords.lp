#const base = 21.
#const span = 1.
#const extra_voices = 0.

% define the possible grades
pos_grade(1..7).

% translate note value into semitone value (skipping silences)
sem_tones(V,((N - base) \ 12),T) :- note(V,N,T), N >= 0.

% number of voices that play at least one note
% changing extra_voices constant, more blank voices can be specified
voice(V..(V+extra_voices)) :- grade(V,_,_).
% times in the score that contain a least one note
time(T/span) :- grade(_,_,T), T/span != 0.

% assign one chord to each time of the score where a note plays in at least one voice
1 { chord(T,C) : pos_chord(C) } 1 :- time(T).

% restrict solutions where assignated chords contain grades that are not present
% this is, grades that do not belong to them
error(V,G,T) :- chord(T,C), grade(V,G,T), time(T), voice(V), not belongs(G,C), time(T..(T+(span-1))).

% define the places where a note should be assignated
% maybe it'd be better to specify these points by hand (somehow)
busytime(V,T) :- time(T), voice(V), note(V,P,T), P >= -1.
freetime(V,T) :- not busytime(V,T), time(T), voice(V).

% place notes in the freetimes
1 { ex_grade(V,G,T) : pos_grade(G) } :- voice(V), time(T), freetime(V,T).

% don't allow notes that don't belong to the assignated chord in freetimes
:- ex_grade(V,G,T), not belongs(G,C), chord(T,C).

% notes that already play in other voice at the same time of the score
unison(V2,G,T) :- ex_grade(V1,G,T), grade(V2,G,T), voice(V1), voice(V2), V1 != V2.
% notes that already play in the same freetime but in other voice
unison(V2,G,T) :- ex_grade(V1,G,T), ex_grade(V2,G,T), voice(V1), voice(V2), V1 != V2.

#minimize[error(_,_,_)].
:- unison(_,_,_).

#hide.
#show chord/2.
#show error/3.
#show grade/3.
#show ex_grade/3.