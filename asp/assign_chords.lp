#const base = 21.
#const span = 1.
#const subdiv = 4.
#const extra_voices = 0.

% define the possible grades
pos_grade(1..7).
pos_oct(0..8).

% number of voices that play at least one note
% changing extra_voices constant, more blank voices can be specified
voice(V..(V+extra_voices)) :- grade(V,_,_).
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

% place new grades in the freebeats
1 { ex_grade(V,G,B) : pos_grade(G) } 1 :- voice(V), beat(B), freebeat(V,B).
% place new octaves in the freetimes
1 { ex_octave(V,O,B) : pos_oct(O) } 1 :- voice(V), beat(B), freebeat(V,B).

error(V,G,B) :- chord(T,C), htime(T), ex_grade(V,G,B), voice(V), not belongs(G,C), beat_belongs_htime(B,T).
repeated_grade(V1,V2,B) :- out_grade(V1,G,O1,B), out_grade(V2,G,O2,B), voice(V1), voice(V2), V1 != V2.
unison(V1,V2,B) :- out_note(V1,N,B), out_note(V2,N,B), voice(V1), voice(V2), V1 != V2.
passing_note(V,N,B) :- chord(T,C), out_note(V,N,B), htime(T), out_grade(V,G,O,B), voice(V), not belongs(G,C),
						beat_belongs_htime(B,T), weak_beat(B).

error_in_strong(V,G,B) :- error(V,G,B), beat(B), strong_beat(B), out_note(V,N,B). %not support_note(V,N,B)
error_in_weak(V,G,B) :- error(V,G,B), beat(B), weak_beat(B), not passing_note(V,N,B), out_note(V,N,B).

melodic_jump(V,J,B1,B2) :- out_grade(V,G1,O1,B1), out_grade(V,G2,O2,B2), (B1+1) == B2, beat(B1+1),
							J = #abs(G2+(7*O2)+1-G1+(7*O1))\7.

% Passing notes are notes in weak beats that bridge two notes by small melodic jumps, not considered errors despite
% belonging or not to the present chord.
passing_note(V,N,B) :- out_note(V,N,B), out_grade(V,G,O,B), weak_beat(B), beat(B), beat(B+1), beat(B-1),
						melodic_jump(V,JA,BA,B), melodic_jump(V,JP,B,BP), BA+1 == B, BP-1 == B, JA <= 3, JP <= 3.
						%not belongs(G,C), chord(HT,C), beat_belongs_htime(B,HT).

% Support notes are notes that take the strong time and let the right note for the time next to them, usually shorter
% (Not working since the duration of the support note is really important)
% support_note(V,N,B) :- out_note(V,N,B), out_grade(V,G,O,B), out_grade(V,G1,O1,B1), B+1 == B1, beat(B+1), belongs(G1,C1).

% octave_jump and no_jump are special cases of melodic_jump and need to be specified
octave_jump(V,B1,B2) :- out_note(V,N1,B1), out_note(V,N2,B2), (B1+1) == B2, N2 > (N1+12), beat(B1+1).
octave_jump(V,B1,B2) :- out_note(V,N1,B1), out_note(V,N2,B2), (B1+1) == B2, N2 < (N1-12), beat(B1+1).

same_chord(HT1,HT2) :- htime(HT1), htime(HT2), htime(HT1+1), HT1+1 == HT2,
						chord(HT1,C1), chord(HT2,C2), C1 == C2, pos_chord(C1), pos_chord(C2).

:- voice(V), voice_type(V, VT), voice_low(VT, VL), voice_high(VT, VH), out_note(V, N, B), beat(B), N < VL, N > VH.

:- octave_jump(_,_,_).

out_figure(V,N,D,FB) :- out_note(V,N,B), figure(V,D,FB), B >= FB, B < FB + D.
out_figure(V,-1,D,FB) :- rest(V,B), figure(V,D,FB), B >= FB, B < FB + D.

out_error(V,FB) :- error_in_strong(V,G,B), figure(V,D,FB), B >= FB, B < FB + D.
out_passing(V,FB) :- passing_note(V,N,B), figure(V,D,FB), B >= FB, B < FB + D.

#minimize[error_in_strong(_,_,_) @ 9].
#minimize[unison(_,_,_) @ 8].
#minimize[same_chord(_,_) @ 7].
% Minimization of priority 6 is the melodious smoothing
% Maximization of priority 5 is the 4th-6th inversion linking.
% Maximization of priority 4 is the same tendency
% Maximization of priority 3 is the contrary tendency
#minimize[error_in_weak(_,_,_) @ 2].
#minimize[repeated_grade(_,_,_) @ 1].

#hide.
#show chord/2.
#show real_measure/3.
#show out_figure/4.
#show out_error/2.
#show out_passing/2.