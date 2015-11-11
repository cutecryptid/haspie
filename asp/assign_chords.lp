#const base = 21.
#const span = 1.
#const extra_voices = 0.

% define the possible grades
pos_grade(1..7).
pos_oct(0..8).

% number of voices that play at least one note
% changing extra_voices constant, more blank voices can be specified
voice(V..(V+extra_voices)) :- grade(V,_,_).
htime(T/span) :- grade(_,_,T), T/span != 0.
beat(T) :- grade(_,_,T).

% assign one chord to each harmony time of the score where a note plays in at least one voice
1 { chord(T,C) : pos_chord(C) } 1 :- htime(T).

error(V,G,T) :- chord(HT,C), grade(V,G,T), htime(HT), voice(V), not belongs(G,C), beat(T..(T+(span-1))).

% define the places where a note should be assignated
% maybe it'd be better to specify these points by hand (somehow)
busybeat(V,T) :- beat(T), voice(V), note(V,P,T), P >= -1.
freebeat(V,T) :- not busybeat(V,T), beat(T), voice(V).

% place new grades in the freebeats
1 { ex_grade(V,G,T) : pos_grade(G) } 1 :- voice(V), beat(T), freebeat(V,T).
% place new octaves in the freetimes
1 { ex_octave(V,O,T) : pos_oct(O) } 1 :- voice(V), beat(T), freebeat(V,T).

error(V,G,T) :- ex_grade(V,G,T), not belongs(G,C), chord(T,C).
repeated_grade(V1,V2,T) :- out_grade(V1,G,O1,T), out_grade(V2,G,O2,T), voice(V1), voice(V2), V1 != V2.
unison(V1,V2,T) :- out_note(V1,N,T), out_note(V2,N,T), voice(V1), voice(V2), V1 != V2.

fifth_jump(V,T1,T2) :- out_grade(V,G1,O1,T1), out_grade(V,G2,O2,T2), (T1+1) == T2, G2 == ((G1+5)\7), G2 == ((G1-5)\7), beat(T1+1).
octave_jump(V,T1,T2) :- out_note(V,N1,T1), out_note(V,N2,T2), (T1+1) == T2, N2 >= (N1+12), N2 <= (N1-12), beat(T1+1).

% don't allow octave jumping
:- octave_jump(V,T1,T2).

#minimize[error(_,_,_) @ 4].
#minimize[unison(_,_,_) @ 3].
#minimize[fifth_jump(_,_,_) @ 2].
#minimize[repeated_grade(_,_,_) @ 1].

#hide.
#show chord/2.
#show error/3.
#show out_note/3.