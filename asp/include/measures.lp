%measure(2,4). measure(3,4). measure(4,4).
%measure(6,8). measure(9,8). measure(12,8).
%measure(3,2).

subdivision(2,B) :- real_measure(2,4,BP), harm_span(_), beat(B), B>=BP.

subdivision(3,B) :- real_measure(3,4,BP), harm_span(H), H<=4, beat(B), B>=BP.
subdivision(2,B) :- real_measure(3,4,BP), harm_span(8), beat(B), B>=BP.

subdivision(2,B) :- real_measure(4,4,BP), harm_span(_), beat(B), B>=BP.

subdivision(2,B) :- real_measure(6,8,BP), harm_span(H), H<=4, beat(B), B>=BP.
subdivision(3,B) :- real_measure(6,8,BP), harm_span(8), beat(B), B>=BP.

subdivision(3,B) :- real_measure(9,8,BP), harm_span(H), H<=4, beat(B), B>=BP.
subdivision(3,B) :- real_measure(9,8,BP), harm_span(8), beat(B), B>=BP.

subdivision(2,B) :- real_measure(12,8,BP), harm_span(H), H<=4, beat(B), B>=BP.
subdivision(3,B) :- real_measure(12,8,BP), harm_span(8), beat(B), B>=BP.

subdivision(3,B) :- real_measure(3,2,BP), harm_span(H), H<=4, beat(B), B>=BP.
subdivision(2,B) :- real_measure(3,2,BP), harm_span(8), beat(B), B>=BP.

%Assume always binary subdivision for a harm span of 16th or less
subdivision(2,B) :- real_measure(_,_,BP), harm_span(16), beat(B), B>=BP.

%First beat is always strong.
strong_beat(B) :- measure(BN,BP), B >= BP, ((B-1) \ BN) == 0, beat(B).

strong_beat(B) :- measure(BN,BP), B >= BP, (B \ 2) == 1, (BN \ 3) != 0, beat(B), subdivision(2,B).
strong_beat(B) :- measure(BN,BP), B >= BP, (B \ 3) == 1, (BN \ 2) != 0, beat(B), subdivision(3,B).

weak_beat(B) :- not strong_beat(B), beat(B).