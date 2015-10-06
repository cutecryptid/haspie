number(1..9). row(0..8). column(0..8).

square(0, X, Y) :- row(X), column(Y), X < 3, Y < 3.
square(1, X, Y) :- row(X), column(Y), X < 3, Y > 2, Y < 6.
square(2, X, Y) :- row(X), column(Y), X < 3, Y > 5.
square(3, X, Y) :- row(X), column(Y), X > 2, X < 6, Y < 3.
square(4, X, Y) :- row(X), column(Y), X > 2, X < 6, Y > 2, Y < 6.
square(5, X, Y) :- row(X), column(Y), X > 2, X < 6, Y > 5.
square(6, X, Y) :- row(X), column(Y), X > 5, Y < 3.
square(7, X, Y) :- row(X), column(Y), X > 5, Y > 2, Y < 6.
square(8, X, Y) :- row(X), column(Y), X > 5, Y > 5.

cell(X, Y, 1) :- row(X), column(Y),
				not cell(X,Y,2), not cell(X,Y,3), not cell(X,Y,4),
				not cell(X,Y,5),not cell(X,Y,6),not cell(X,Y,7),
				not cell(X,Y,8),not cell(X,Y,9).

cell(X, Y, 2) :- row(X), column(Y),
				not cell(X,Y,1), not cell(X,Y,3), not cell(X,Y,4),
				not cell(X,Y,5),not cell(X,Y,6),not cell(X,Y,7),
				not cell(X,Y,8),not cell(X,Y,9).

cell(X, Y, 3) :- row(X), column(Y),
				not cell(X,Y,1), not cell(X,Y,2), not cell(X,Y,4),
				not cell(X,Y,5),not cell(X,Y,6),not cell(X,Y,7),
				not cell(X,Y,8),not cell(X,Y,9).

cell(X, Y, 4) :- row(X), column(Y),
				not cell(X,Y,2), not cell(X,Y,3), not cell(X,Y,1),
				not cell(X,Y,5),not cell(X,Y,6),not cell(X,Y,7),
				not cell(X,Y,8),not cell(X,Y,9).

cell(X, Y, 5) :- row(X), column(Y),
				not cell(X,Y,1), not cell(X,Y,3), not cell(X,Y,4),
				not cell(X,Y,2),not cell(X,Y,6),not cell(X,Y,7),
				not cell(X,Y,8),not cell(X,Y,9).

cell(X, Y, 6) :- row(X), column(Y),
				not cell(X,Y,1), not cell(X,Y,2), not cell(X,Y,4),
				not cell(X,Y,5),not cell(X,Y,3),not cell(X,Y,7),
				not cell(X,Y,8),not cell(X,Y,9).
				
cell(X, Y, 7) :- row(X), column(Y),
				not cell(X,Y,2), not cell(X,Y,3), not cell(X,Y,4),
				not cell(X,Y,5),not cell(X,Y,6),not cell(X,Y,1),
				not cell(X,Y,8),not cell(X,Y,9).

cell(X, Y, 8) :- row(X), column(Y),
				not cell(X,Y,1), not cell(X,Y,3), not cell(X,Y,4),
				not cell(X,Y,5),not cell(X,Y,6),not cell(X,Y,7),
				not cell(X,Y,2),not cell(X,Y,9).

cell(X, Y, 9) :- row(X), column(Y),
				not cell(X,Y,1), not cell(X,Y,2), not cell(X,Y,4),
				not cell(X,Y,5),not cell(X,Y,6),not cell(X,Y,7),
				not cell(X,Y,8),not cell(X,Y,3).

:- cell(X,Y1,N), cell(X,Y2,N), Y1 != Y2.
:- cell(X1,Y,N), cell(X2,Y,N), X1 != X2.

in_square(S,N) :- cell (X,Y,N), square(S,X,Y).
				:- number (N), not in_square(S,N), square(S,_,_).

#hide.
#show cell/3.