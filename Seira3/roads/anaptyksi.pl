% Problem Anaptyksi ECE PL1 spring 2013
% A road of length L needs to be renovated
% There are a total of N days of work
% Each day the part from start_i to end_i is renovated
% 
% Find the first day that the biggest continuous part of
% unrenovated road is less than X
%
% Konstantinos Ameranis: 03112177
% Revekka Palaiologou: 03110668

% The second predicate reads the information of an input file and returns
% it in the next three arguments: two integers and a list with day/3
% structures with the start, end and day of a segment, as in the example below:
% 
%   ?- read_and_return('anaptyksi1.txt', N, L, X, Segs).
%   L = 30,
%   X = 6,
%   Segs = [day(1, 5, 0), day(11, 27, 1), day(2, 14, 2), day(18, 28, 3)].
%
% To read the information of each of the days, it uses the auxiliary
% predicate read_days/4.
%

read_and_return(File, N, L, X, Days) :-
    open(File, read, Stream),
    read_line(Stream, [N, L, X]),
    read_days(Stream, N, N, Acc),
    Days = [day(0,0,-1),day(L,L,-1)|Acc],
    close(Stream).

read_days(Stream, N, I, Days) :-
    ( I > 0 ->
    Days = [Day|Rest],
        read_line(Stream, [S, E]), Curr is N-I,
    Day = day(S, E, Curr),
        N1 is I - 1,
        read_days(Stream, N, N1, Rest)
    ; I =:= 0 ->
    Days = []
    ).

%
% An auxiliary predicate that reads a line and returns the list of
% integers that the line contains.
%
read_line(Stream, List) :-
    read_line_to_codes(Stream, Line),
    atom_codes(A, Line),
    atomic_list_concat(As, ' ', A),
    maplist(atom_number, As, List).


maxi(A,B,Max) :- A>B -> Max is A; Max is B.

% filter(Days,N,New_Days) - New_Days are only the days numbered less than N
filter([],_,[]) :- !.
filter([day(Start,Finish,Day)|Days], N, [F|Fs]) :- Day =< N -> F = day(Start,Finish,Day), filter(Days,N,Fs); filter(Days,N,[F|Fs]).

% find_max(Days,Next_finish,Max) - Returns the biggest gap of unrenovated road in Days.
% Days must be sorted according to Start.
find_max([],_,0).
find_max([day(Start,Finish,_)|Days],Next_finish,Maxi) :- 
    Diff is Start - Next_finish, maxi(Next_finish,Finish,Next), find_max(Days,Next,M), maxi(M,Diff,Maxi).

% Binary(N,X,Left,Right,Days,Answer) - Does a binary search to find the first day out of N
% that the biggest part of unrenovated road is less than X.
binary(N,_,N,_,_,_) :- !,fail.
binary(N,X,Left,Right,Days,Answer) :-
    Mid is div((Left+Right),2), filter(Days,Mid,D), find_max(D,0,Maxi),
    (Left > Right -> (Maxi > X -> Answer is Mid+2; Answer is Mid+1); 
    (Maxi >= X -> Mid1 is Mid+1, binary(N,X,Mid1,Right,Days,Answer);
    Mid1 is Mid-1, binary(N,X,Left,Mid1,Days,Answer))).

% One fuction to rule them all
% % One function to call them all
% % One function to bring them all
% % and in program bind them
dromoi(File, Answer) :-
    read_and_return(File, N, L, X, D), sort(D, Days), N1 is N-1, binary(N,X,0,N1,Days,Answer).
