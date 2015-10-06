net_element(c,l,t,p,sc,sl,st). row(0..1). column(0..1).

node(X,Y,c) :- row(X), row(Y),
				not node(X,Y,l), not node(X,Y,t), not node(X,Y,p),
				not node(X,Y,sc), not node(X,Y,sl), not node(X,Y,st).

node(X,Y,l) :- row(X), row(Y),
				not node(X,Y,c), not node(X,Y,t), not node(X,Y,p),
				not node(X,Y,sc), not node(X,Y,sl), not node(X,Y,st).

node(X,Y,t) :- row(X), row(Y),
				not node(X,Y,l), not node(X,Y,c), not node(X,Y,p),
				not node(X,Y,sc), not node(X,Y,sl), not node(X,Y,st).

node(X,Y,p) :- row(X), row(Y),
				not node(X,Y,l), not node(X,Y,t), not node(X,Y,c),
				not node(X,Y,sc), not node(X,Y,sl), not node(X,Y,st).

node(X,Y,sc) :- row(X), row(Y),
				not node(X,Y,l), not node(X,Y,t), not node(X,Y,p),
				not node(X,Y,c), not node(X,Y,sl), not node(X,Y,st).

node(X,Y,sl) :- row(X), row(Y),
				not node(X,Y,l), not node(X,Y,t), not node(X,Y,p),
				not node(X,Y,sc), not node(X,Y,c), not node(X,Y,st).

node(X,Y,st) :- row(X), row(Y),
				not node(X,Y,l), not node(X,Y,t), not node(X,Y,p),
				not node(X,Y,sc), not node(X,Y,sl), not node(X,Y,c).

node(_,_,sc) :- not node(_,_,sc), not node(_,_,sl), not node(_,_,st).
node(_,_,sl) :- not node(_,_,sc), not node(_,_,sl), not node(_,_,st).
node(_,_,st) :- not node(_,_,sc), not node(_,_,sl), not node(_,_,st).

#hide all.
#show node/3.
