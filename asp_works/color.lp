node(1..6).

edge(1,2). edge(1,3). edge(1,4).
edge(2,4). edge(2,5). edge(2,6).
edge(3,1). edge(3,5).
edge(4,1). edge(4,2).
edge(5,3). edge(5,6).
edge(6,2). edge(6,3). edge(6,5).

col(r;g;b).


1 {color(X,C):col(C)} 1 :- node(X).
:- edge(X,Y), color(X,C), color(Y,C).

#hide.
#show color/2.
