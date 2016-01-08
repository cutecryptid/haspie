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
newvoicebeat(V,B) :- not busybeat(V,B), not freebeat(V,B), beat(B), voice(V).
freefigure(V,D,B) :- figure(V,D,B), freebeat(V,B).

% place new grades in the freebeats
1 { ex_grade(V,G,B) : pos_grade(G) } 1 :- voice(V), beat(B), freebeat(V,B).
% place new octaves in the freetimes
1 { ex_octave(V,O,B) : pos_oct(O) } 1 :- voice(V), beat(B), freebeat(V,B).

:- freefigure(V,D,FB), ex_grade(V,G1,B1), ex_grade(V,G2,B2), B1 >= FB, B2 >= FB, B1 < FB+D, B2 < FB+D, B1 != B2, G1 != G2.
:- freefigure(V,D,FB), ex_octave(V,O1,B1), ex_octave(V,O2,B2), B1 >= FB, B2 >= FB, B1 < FB+D, B2 < FB+D, B1 != B2, O1 != O2.

1 { newvoicefigure(V,N,1,FB) : N=VL..VH } 1 :- newvoicebeat(V,FB), voice_limit_low(V,VL), voice_limit_high(V,VH).

beat_belongs_htime(((((T-1)*span)+1)..(T*span)),T) :- htime(T).
error(V,G,B) :- chord(T,C), htime(T), ex_grade(V,G,B), voice(V), not belongs(G,C), beat_belongs_htime(B,T).
repeated_grade(V1,V2,B) :- out_grade(V1,G,O1,B), out_grade(V2,G,O2,B), voice(V1), voice(V2), V1 != V2.
unison(V1,V2,B) :- out_note(V1,N,B), out_note(V2,N,B), voice(V1), voice(V2), V1 != V2.

octave_jump(V,B1,B2) :- out_note(V,N1,B1), out_note(V,N2,B2), (B1+1) == B2, N2 > (N1+12), beat(B1+1).
octave_jump(V,B1,B2) :- out_note(V,N1,B1), out_note(V,N2,B2), (B1+1) == B2, N2 < (N1-12), beat(B1+1).

:- octave_jump(_,_,_).

same_chord(HT1,HT2) :- htime(HT1), htime(HT2), htime(HT1+1), HT1+1 == HT2,
						chord(HT1,C1), chord(HT2,C2), C1 == C2, pos_chord(C1), pos_chord(C2).

error_in_strong(V,G,B) :- error(V,G,B), beat(B), strong_beat(B), out_note(V,N,B).
error_in_weak(V,G,B) :- error(V,G,B), beat(B), weak_beat(B), out_note(V,N,B).

out_figure(V,N,D,FB) :- out_note(V,N,B), figure(V,D,FB), B >= FB, B < FB + D.
out_figure(V,N,D,FB) :- newvoicefigure(V,N,D,FB).
out_figure(V,-1,D,FB) :- rest(V,B), figure(V,D,FB), B >= FB, B < FB + D.

voice_limit_low(V,VL) :-  voice(V), voice_type(V, VT), voice_low(VT, VL).
voice_limit_high(V,VH) :-  voice(V), voice_type(V, VT), voice_high(VT, VH).

out_error(V,FB) :- error_in_strong(V,G,B), figure(V,D,FB), B >= FB, B < FB + D.
out_error_weak(V,FB) :- error_in_weak(V,G,B), figure(V,D,FB), B >= FB, B < FB + D.

out_passing(V,N,D,B) :- out_error_weak(V,B), out_figure(V,N,D,B), out_figure(V,N2,D2,B2), B2 = B+D, beat(B+D), 
						out_grade(V,G2,O2,B+D), belongs(G2,C), chord(HT,C), beat_belongs_htime(B+D,HT).

#const note_errorinstrongw = 1.
#const unisonw = 1.
#const note_errorinweakw = 1.
#const repeatedgradew = 1.

#const note_errorinstrongp = 4.
#const unisonp = 3.
#const note_errorinweakp = 2.
#const repeatedgradep = 1.

#minimize[error_in_strong(_,_,_) = note_errorinstrongw @ note_errorinstrongp].
#minimize[unison(_,_,_) = unisonw @ unisonp].
#minimize[error_in_weak(_,_,_) = note_errorinweakw @ note_errorinweakp].
#minimize[repeated_grade(_,_,_) = repeatedgradew @ repeatedgradep].

#hide.
#show chord/2.
#show voice_type/2.
#show real_measure/3.
#show out_figure/4.
#show out_error/2.
#show out_passing/2.