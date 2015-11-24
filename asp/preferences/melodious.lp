% Possible tendencies are positive, negative and still
pos_tendency(pos;neg;still).

% Music Tendency 
% We can imitate the tendency or not, also we can go against the tendency
tendency(pos,V,B1,B2) :- out_note(V,N1,B1), out_note(V,N2,B2), N1 < N2, beat(B1), beat(B1+1), beat(B2), B1+1==2.
tendency(neg,V,B1,B2) :- out_note(V,N1,B1), out_note(V,N2,B2), N1 > N2, beat(B1), beat(B1+1), beat(B2), B1+1==2.
tendency(still,V,B1,B2) :- out_note(V,N1,B1), out_note(V,N2,B2), N1 == N2, beat(B1), beat(B1+1), beat(B2), B1+1==2.

same_tendency(V1,V2,B1,B2) :- voice(V1), voice(V2), V1 != V2, tendency(T,V1,B1,B2), tendency(T,V2,B1,B2),
							beat(B1), beat(B2), pos_tendency(T). 
cont_tendency(V1,V2,B1,B2) :- voice(V1), voice(V2), V1 != V2, tendency(pos,V1,B1,B2), tendency(neg,V2,B1,B2),
							beat(B1), beat(B2).

% Sixths sequence (Sequence of second inversions of 4ths and 6ths)
1 { unary_chord(B,C) : pos_chord(C) } 1 :- beat(B).
unary_error(V,G,B) :- chord(T,C), out_grade(V,G,O,B), voice(V), not belongs(G,C), beat(B).
:- unary_error(V,G,B), voice(V), out_grade(V,G,O,B), beat(B).

harmonic_step(V1,V2,S,B) :- out_grade(V1,G1,O1,B), out_grade(V2,G2,O2,B), out_note(V1,N1,B), out_note(V2,N2,B), N1 < N2,
							S = #abs(G2+(7*O2)+1-G1+(7*O1))\7, V1 != V2.

first_inversion(C,B) :-  harmonic_step(V1,V2,3,B), harmonic_step(V1,V3,5,B), beat(B), V2 != V3, unary_chord(B,C).
second_inversion(C,B) :- harmonic_step(V1,V2,4,B), harmonic_step(V1,V3,6,B), beat(B), V2 != V3, unary_chord(B,C).

sixth_link(B1,B2) :- beat(B1), beat(B1+1), B1+1 == B2, first_inversion(C,B1), second_inversion(C,B2).
sixth_link(B1,B2) :- beat(B1), beat(B1+1), B1+1 == B2, second_inversion(C,B1), first_inversion(C,B2).
sixth_link(B1,B2) :- beat(B1), beat(B1+1), B1+1 == B2, second_inversion(C1,B1), second_inversion(C2,B2).

% Melody Smoothing
#minimize[melodic_jump(_,J,_,_) = J @ 6].
#maximize[sixth_link(_,_) @ 5].
#maximize[cont_tendency(_,_,_,_) @ 4].
#maximize[same_tendency(_,_,_,_) @ 3].