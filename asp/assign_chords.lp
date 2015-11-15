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
beat(B) :- grade(_,_,B).

% define the places where a note should be assignated
% maybe it'd be better to specify these points by hand (somehow)
busybeat(V,B) :- beat(B), voice(V), note(V,P,B).
busybeat(V,B) :- beat(B), voice(V), rest(V,B).
freebeat(V,B) :- not busybeat(V,B), beat(B), voice(V).

strong_beat(B) :- measure(BN,BP), B >= BP, ((B-1) \ BN) == 0, beat(B).
semistrong_beat(B) :- measure(BN,BP), B >= BP, (B \ 2) == 1, (BN \ 3) != 0, not strong_beat(B), beat(B).
weak_beat(B) :- not strong_beat(B), not semistrong_beat(B), beat(B).

% assign one chord to each harmony time of the score where a note plays in at least one voice
1 { chord(HT,C) : pos_chord(C) } 1 :- htime(HT).

beat_belongs_htime(((((T-1)*span)+1)..(T*span)),T) :- htime(T).
error(V,G,B) :- chord(T,C), htime(T), grade(V,G,B), voice(V), not belongs(G,C), beat_belongs_htime(B,T), beat(B).

% place new grades in the freebeats
1 { ex_grade(V,G,B) : pos_grade(G) } 1 :- voice(V), beat(B), freebeat(V,B).
% place new octaves in the freetimes
1 { ex_octave(V,O,B) : pos_oct(O) } 1 :- voice(V), beat(B), freebeat(V,B).

error(V,G,B) :- chord(T,C), htime(T), ex_grade(V,G,B), voice(V), not belongs(G,C), beat_belongs_htime(B,T).
repeated_grade(V1,V2,B) :- out_grade(V1,G,O1,B), out_grade(V2,G,O2,B), voice(V1), voice(V2), V1 != V2.
unison(V1,V2,B) :- out_note(V1,N,B), out_note(V2,N,B), voice(V1), voice(V2), V1 != V2.
passing_note(V,N,B) :- chord(T,C), out_note(V,N,B), htime(T), out_grade(V,G,O,B), voice(V), not belongs(G,C), beat_belongs_htime(B,T), weak_beat(B).

error_in_strong(V,G,B) :- error(V,G,B), beat(B), strong_beat(B).
error_in_semistrong(V,G,B) :- error(V,G,B), beat(B), semistrong_beat(B).
error_in_weak(V,G,B) :- error(V,G,B), beat(B), weak_beat(B).

fifth_jump(V,B1,B2) :- out_grade(V,G1,O1,B1), out_grade(V,G2,O2,B2), (B1+1) == B2, G2 == ((G1-5)\7), beat(B1+1).
fifth_jump(V,B1,B2) :- out_grade(V,G1,O1,B1), out_grade(V,G2,O2,B2), (B1+1) == B2, G2 == ((G1+5)\7), beat(B1+1).
octave_jump(V,B1,B2) :- out_note(V,N1,B1), out_note(V,N2,B2), (B1+1) == B2, N2 >= (N1+12), beat(B1+1).
octave_jump(V,B1,B2) :- out_note(V,N1,B1), out_note(V,N2,B2), (B1+1) == B2, N2 >= (N1-12), beat(B1+1).

% don't allow octave jumping
%:- octave_jump(V,B1,B2).

#minimize[error_in_strong(_,_,_) @ 5].
#minimize[unison(_,_,_) @ 4].
#minimize[repeated_grade(_,_,_) @ 4].
#minimize[error_in_semistrong(_,_,_) @ 4].
#minimize[octave_jump(_,_,_) @ 3].
#minimize[fifth_jump(_,_,_) @ 3].
#minimize[error_in_weak(_,_,_) @ 2].

#hide.
#show chord/2.
#show rest/2.
#show error/3.
#show out_note/3.
#show octave_jump/3.