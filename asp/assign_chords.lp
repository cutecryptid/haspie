#const base = 21.
#const span = 1.
#const subdiv = 4.

% define the possible grades
pos_grade(1..7).
pos_oct(0..8).

% number of voices that play at least one note
voice(V) :- grade(V,_,_).
htime(T/span) :- grade(_,_,T), T/span != 0.
htime(T/span) :- rest(_,T), T/span != 0.
beat(B) :- grade(_,_,B).
beat(B) :- rest(_,B).
harm_span(S) :- S=(subdiv/span).

% define the places where a note should be assignated
% maybe it'd be better to specify these points by hand (somehow)
busybeat(V,B) :- beat(B), voice(V), note(V,P,B).
busybeat(V,B) :- beat(B), voice(V), rest(V,B).
freebeat(V,B) :- not busybeat(V,B), beat(B), voice(V).

% assign one chord to each harmony time of the score where a note plays in at least one voice
1 { chord(HT,C) : pos_chord(C) } 1 :- htime(HT).

beat_belongs_htime(((((T-1)*span)+1)..(T*span)),T) :- htime(T).
error(V,G,B) :- chord(T,C), htime(T), grade(V,G,B), voice(V), not belongs(G,C), beat_belongs_htime(B,T), beat(B).
error(V,G,B) :- chord(T,C), htime(T), ex_grade(V,G,B), voice(V), not belongs(G,C), beat_belongs_htime(B,T).
error(V,G,B) :- grade(V,G,B), non_scale_grade(G), voice(V), beat(B).
error(V,G,B) :- ex_grade(V,G,B), non_scale_grade(G), voice(V), beat(B).
repeated_grade(V1,V2,B) :- out_grade(V1,G,O1,B), out_grade(V2,G,O2,B), voice(V1), voice(V2), V1 != V2.
unison(V1,V2,B) :- out_note(V1,N,B), out_note(V2,N,B), voice(V1), voice(V2), V1 != V2.
passing_note(V,N,B) :- chord(T,C), out_note(V,N,B), htime(T), out_grade(V,G,O,B), voice(V), not belongs(G,C),
						beat_belongs_htime(B,T), weak_beat(B).

error_in_strong(V,G,B) :- error(V,G,B), beat(B), strong_beat(B), out_note(V,N,B). %not support_note(V,N,B)
error_in_weak(V,G,B) :- error(V,G,B), beat(B), weak_beat(B), out_note(V,N,B).

out_error(V,FB) :- D{error(V,G,FB..FB+D-1)}D, figure(V,D,FB), error_in_strong(V,G,FB).
out_error_weak(V,FB) :- D{error(V,G,FB..FB+D-1)}D, figure(V,D,FB), error_in_weak(V,G,FB).

same_chord(HT1,HT2) :- htime(HT1), htime(HT2), htime(HT1+1), HT1+1 == HT2,
						chord(HT1,C1), chord(HT2,C2), C1 == C2, pos_chord(C1), pos_chord(C2).

#const chord_errorinstrongw = 1.
#const chord_samechordw = 1.
#const chord_errorinweakw = 1.

#const chord_errorinstrongp = 3.
#const chord_samechordp = 2.
#const chord_errorinweakp = 1.

#minimize[out_error(_,_)=chord_errorinstrongw @ chord_errorinstrongp].
#minimize[same_chord(_,_)=chord_samechordw @ chord_samechordp].
#minimize[out_error_weak(_,_)=chord_errorinweakw @ chord_errorinweakp].

#hide.
#show chord/2.
#show out_error/2.
#show out_error_weak/2.