% Kouvadakia NTUA ECE PL1 Spring Semester 2014
% We have two buckets with capacity A, B
% We want one of the buckets to hold exactly C
% 
% Konstantios Ameranis: 03112177 
% Revekka Palaiologou: 03110668

% Base case
buckets_aux(_,_,C,C,_,[],_).
buckets_aux(_,_,C,_,C,[],_).

% Must fill from bucket
buckets_aux(A,B,C,0,Bc,[M|Moves],N) :- atom_number(Str,N), string_concat('0',Str,M), buckets_aux(A,B,C,A,Bc,Moves,N), !.

% Must empty to bucket
buckets_aux(A,B,C,Ac,B,[M|Moves],N) :- 
    N3 is 3-N, atom_number(Str,N3), string_concat(Str,'0',M), 
    buckets_aux(A,B,C,Ac,0,Moves,N), !.

% Move water from bucket to bucket
buckets_aux(A,B,C,Ac,Bc,[M|Moves],N) :-
    N3 is 3-N, atom_number(Str1,N), atom_number(Str2,N3), string_concat(Str1,Str2,M),
    H is B-Bc, X is min(Ac,H), An is Ac - X, Bn is Bc + X, buckets_aux(A,B,C,An,Bn,Moves,N), !.


% One fuction to rule them all
% One function to call them all
% One function to bring them all
% and in program bind them
kouvadakia(A,B,C,Answer) :-
    (A >= C; B >= C), G is gcd(A,B), 0 is mod(C,G) -> buckets_aux(A,B,C,A,0,Moves1,1),buckets_aux(B,A,C,B,0,Moves2,2),
    M1 = ['01'|Moves1], M2 = ['02'|Moves2],length(M1,L1), length(M2,L2), (L1 < L2 -> Answer = M1; Answer = M2);
    fail.

% We use ample cuts to only produce one solution very, very, very fast.
