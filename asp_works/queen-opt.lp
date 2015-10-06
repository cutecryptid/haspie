1 { queen(I,1..n) } 1 :- I = 1..n.
1 { queen(1..n,J) } 1 :- J = 1..n.
:- 2 { queen(D-J,J) }, D = 2..2*n.
:- 2 { queen(D+J,J) }, D = 1-n..n-1.

"Yo voy a llevar gatetes explosivos ( http://www.explodingkittens.com ), pero necesito saber que habrá una mesa libre o liberable donde jugar. La otra vez lo de mesas libres no se llevaba mucho."