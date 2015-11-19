% Possible tendencies are positive, negative and still
pos_tendency(pos;neg;still).

% Music Tendency 
% We can imitate the tendency or not, also we can go against the tendency
tendency(pos,V,B1,B2) :- out_note(V,N1,B1), out_note(V,N2,B2), N1 < N2, beat(B1), beat(B1+1), beat(B2), B1+1==2.
tendency(neg,V,B1,B2) :- out_note(V,N1,B1), out_note(V,N2,B2), N1 > N2, beat(B1), beat(B1+1), beat(B2), B1+1==2.
tendency(still,V,B1,B2) :- out_note(V,N1,B1), out_note(V,N2,B2), N1 == N2, beat(B1), beat(B1+1), beat(B2), B1+1==2.

same_tendency(V1,V2,B1,B2) :- voice(V1), voice(V2), V1 != V2, tendency(T,V1,B1,B2), tendency(T,V2,B1,B2),
							beat(B1), beat(B2), pos_tendency(T). 

% Sixths sequence


% Melody Smoothing
#minimize[melodic_jump(_,J,_,_) = J @ 4].
#maximize[same_tendency(_,_,_,_) @ 3].