node(1..7).

edge(1,2;3;6;7). edge(2,1;3;6;7). edge(3,1;2;4;5;6;7).
edge(4,3;5;6). edge(5,3;4;6;7). edge(6,1;2;3;4;5;6;7).
edge(7,1;2;3;5;6).

cost(1,2,2). cost(1,3,4). cost(1,6,6). cost(1,6,5).
cost(2,3,2). cost(2,6,4). cost(2,7,6).
cost(3,4,2). cost(3,5,3). cost(3,6,2). cost(3,7,4).
cost(4,5,1). cost(4,6,3).
cost(5,6,3). cost(5,7,8).
cost(6,7,2).

cost(N1, N2, C) :- cost(N2,N1,C).

1{cycle(N1,N2):edge(N1,N2)}1 :- node(N1).
1{cycle(N1,N2):edge(N1,N2)}1 :- node(N2).

reached(N2) :- cycle(1,N2).
reached(N2) :- cycle(N1,N2), reached(N1).

:- node(N2), not reached(N2).

#minimize[cycle(N1,N2) = C : cost(N1,N2,C)].

#hide.
#show cycle/2.
