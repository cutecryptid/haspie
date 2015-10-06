row(1..n).
col(1..n).

{queen(I,J):row(I):col(J)}.

:- not n{queen(I,J)}n.
:- queen(I,J), queen(I,JJ), J!=JJ.
:- queen(I,J), queen(II,J), I!=II.
:- queen(I,J), queen(II,JJ), (I,J)!=(II,JJ), I-J==II-JJ.
:- queen(I,J), queen(II,JJ), (I,J)!=(II,JJ), I+J==II-JJ.