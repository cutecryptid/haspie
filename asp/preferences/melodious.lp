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

melodic_jump(V,J,B1,B2) :- out_note(V,N1,B1), out_note(V,N2,B2), (B1+1) == B2, beat(B1+1), J = #abs(N1-N2).

#const melodicjumpw = 1.
#const conttendencyw = 1.
#const sametendency = 1.

#const note_errorinstrongp = 7.
#const unisonp = 6.
#const melodicjumpp = 5.
#const conttendencyp = 4.
#const sametendencyp = 3.
#const mote_errorinweakp = 2.
#const repeatedgradep = 1.

#minimize[melodic_jump(_,J,_,_) = (J * melodicjumpw) @ melodicjumpp].
#maximize[cont_tendency(_,_,_,_) = conttendencyp @ conttendencyp].
#maximize[same_tendency(_,_,_,_) = sametendencyp @ sametendencyp].