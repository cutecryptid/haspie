% Sixths sequence (Sequence of second inversions of 4ths and 6ths)
1 { unary_chord(B,C) : pos_chord(C) } 1 :- beat(B).
unary_error(V,G,B) :- chord(T,C), out_grade(V,G,O,B), voice(V), not belongs(G,C), beat(B).

harmonic_step(V1,V2,S,B) :- out_grade(V1,G1,O1,B), out_grade(V2,G2,O2,B), out_note(V1,N1,B), out_note(V2,N2,B), N1 < N2,
							S = #abs(G2+(7*O2)+1-G1+(7*O1))\7, V1 != V2.

first_inversion(C,B) :-  harmonic_step(V1,V2,3,B), harmonic_step(V1,V3,5,B), beat(B), V2 != V3, unary_chord(B,C).
second_inversion(C,B) :- harmonic_step(V1,V2,4,B), harmonic_step(V1,V3,6,B), beat(B), V2 != V3, unary_chord(B,C).

sixth_link(B1,B2) :- beat(B1), beat(B1+1), B1+1 == B2, second_inversion(C1,B1), second_inversion(C2,B2).

#maximize[sixth_link(_,_) @ 5].