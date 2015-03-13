emptyQ(L-L).  /* Checks if queue is empty */

% returns the head of the list as the first arguement and
% the rest of the queue as the third arguement
popQ(Head,[Head|Tail]-X,Tail-X).

/* Pushes Element into Queue to create New_Queue */
pushQueue(Element,Queue,New_Queue) :-
    Last = [Element|T]-T, dapp(Queue,Last,New_Queue).

dapp(A-B,B-C,A-C).

main(Start, Goal, Moves):-
Queue = [[state(Start,[],[]),[]] | X]-X,
empty_assoc(Empty_open),
hash_term( state(Start,[],[]) , Value ),
put_assoc( Value, Empty_open, state(Start,[],[]), In1),
find1(Queue,In1,Goal,Moves),!.

/* Gets called when we still don't have moves*/
find1(Queue,Visited,Goal,Moves) :-
    popQ([state(S1,R0,S2),[]],Queue,Pop_Queue),
    add_pos(state(S1,R0,S2),[],Pop_Queue,Visited,'12',Queue_1,Visited_1),
    add_pos(state(S1,R0,S2),[],Queue_1,Visited_1,'10',Final_Queue,Final_Visited),
    find(Final_Queue,Final_Visited,Goal,Moves).

equ(I,I).

/* Base Case: Found solution */
find(Queue,_,Goal,Moves) :-
    popQ([state([],[],Goal),Moves],Queue,_), !.

/* Examines top state and updates Queue and Visited */
find(Queue,Visited,Goal,Moves):-
    popQ([state(S1,R0,S2),[I|Iteration]],Queue,Pop_Queue),

    (equ(I,'10') -> 
    (
    add_pos(state(S1,R0,S2),[I|Iteration],Pop_Queue,Visited,'12',Queue_1,Visited_1),
    add_pos(state(S1,R0,S2),[I|Iteration],Queue_1,Visited_1,'21',Final_Queue,Final_Visited));

    (equ(I,'12') ->
    (
    add_pos(state(S1,R0,S2),[I|Iteration],Pop_Queue,Visited,'10',Queue_1,Visited_1),
    add_pos(state(S1,R0,S2),[I|Iteration],Queue_1,Visited_1,'02',Queue_2,Visited_2),
    add_pos(state(S1,R0,S2),[I|Iteration],Queue_2,Visited_2,'12',Queue_3,Visited_3),
    add_pos(state(S1,R0,S2),[I|Iteration],Queue_3,Visited_3,'01',Final_Queue,Final_Visited));

    (I = '21' ->
    (
    add_pos(state(S1,R0,S2),[I|Iteration],Pop_Queue,Visited,'02',Queue_1,Visited_1),
    add_pos(state(S1,R0,S2),[I|Iteration],Queue_1,Visited_1,'21',Queue_2,Visited_2),
    add_pos(state(S1,R0,S2),[I|Iteration],Queue_2,Visited_2,'20',Queue_3,Visited_3),
    add_pos(state(S1,R0,S2),[I|Iteration],Queue_3,Visited_3,'01',Final_Queue,Final_Visited));

    (I = '02' -> 
    (
    add_pos(state(S1,R0,S2),[I|Iteration],Pop_Queue,Visited,'12',Queue_1,Visited_1),
    add_pos(state(S1,R0,S2),[I|Iteration],Queue_1,Visited_1,'10',Final_Queue,Final_Visited));
    
    (I = '01' -> 
    (
    add_pos(state(S1,R0,S2),[I|Iteration],Pop_Queue,Visited,'20',Queue_1,Visited_1),
    add_pos(state(S1,R0,S2),[I|Iteration],Queue_1,Visited_1,'21',Final_Queue,Final_Visited));
    
    (I = '20' -> 
    (
    add_pos(state(S1,R0,S2),[I|Iteration],Pop_Queue,Visited,'12',Queue_1,Visited_1),
    add_pos(state(S1,R0,S2),[I|Iteration],Queue_1,Visited_1,'21',Final_Queue,Final_Visited));fail)))))),

    find(Final_Queue,Final_Visited,Goal,Moves),!.

/* This is where the magic happens
 * If the move is not allowed, we return Queue and Visited unchanged
 * Otherwise, we update them given that we have not Visited the State created after the move */
add_pos(state(_,[],_),_,Queue,Visited,'01',Queue,Visited) :- !.
add_pos(state(A,[B],C),Iteration,Queue,Visited,'01',New_Queue,Visited_1) :-
    State = state([B|A],[],C),
    hash_term(State,Key),
    get_assoc(Key,Visited,_) -> 
    (New_Queue = Queue, Visited_1 = Visited);
    (State = state([B|A],[],C),hash_term(State,Key),put_assoc(Key,Visited,State,Visited_1), pushQueue([State,['01'|Iteration]],Queue,New_Queue)).

add_pos(state(_,[],_),_,Queue,Visited,'02',Queue,Visited) :- !.
add_pos(state(A,[B],C),Iteration,Queue,Visited,'02',New_Queue,Visited_1) :-
    State = state(A,[],[B|C]),
    hash_term(State,Key),
    get_assoc(Key,Visited,_) -> 
    (New_Queue = Queue, Visited_1 = Visited);
    (State = state(A,[],[B|C]),hash_term(State,Key),put_assoc(Key,Visited,State,Visited_1), pushQueue([State,['02'|Iteration]],Queue,New_Queue)).

add_pos(state([],_,_),_,Queue,Visited,'10',Queue,Visited) :- !.
add_pos(state(_,[_],_),_,Queue,Visited,'10',Queue,Visited) :- !.
add_pos(state([A|As],[],C),Iteration,Queue,Visited,'10',New_Queue,Visited_1) :-
    State = state(As,[A],C),
    hash_term(State,Key),
    get_assoc(Key,Visited,_) -> 
    (New_Queue = Queue, Visited_1 = Visited);
    (State = state(As,[A],C),hash_term(State,Key),put_assoc(Key,Visited,State,Visited_1), pushQueue([State,['10'|Iteration]],Queue,New_Queue)).

add_pos(state([],_,_),_,Queue,Visited,'12',Queue,Visited) :- !.
add_pos(state([A|As],B,C),Iteration,Queue,Visited,'12',New_Queue,Visited_1) :-
    State = state(As,B,[A|C]),
    hash_term(State,Key),
    get_assoc(Key,Visited,_) -> 
    (New_Queue = Queue, Visited_1 = Visited);
    (State = state(As,B,[A|C]),hash_term(State,Key),put_assoc(Key,Visited,State,Visited_1), pushQueue([State,['12'|Iteration]],Queue,New_Queue)).

add_pos(state(_,_,[]),_,Queue,Visited,'21',Queue,Visited) :- !.
add_pos(state(A,B,[C|Cs]),Iteration,Queue,Visited,'21',New_Queue,Visited_1) :-
    State = state([C|A],B,Cs),
    hash_term(State,Key),
    get_assoc(Key,Visited,_) -> 
    (New_Queue = Queue, Visited_1 = Visited);
    (State = state([C|A],B,Cs),hash_term(State,Key),put_assoc(Key,Visited,State,Visited_1), pushQueue([State,['21'|Iteration]],Queue,New_Queue)).

add_pos(state(_,_,[]),_,Queue,Visited,'20',Queue,Visited) :- !.
add_pos(state(_,[_],_),_,Queue,Visited,'20',Queue,Visited) :- !.
add_pos(state(A,[],[C|Cs]),Iteration,Queue,Visited,'20',New_Queue,Visited_1) :-
    State = state(A,[C],Cs),
    hash_term(State,Key),
    get_assoc(Key,Visited,_) -> 
    (New_Queue = Queue, Visited_1 = Visited);
    (State = state(A,[C],Cs),hash_term(State,Key),put_assoc(Key,Visited,State,Visited_1), pushQueue([State,['20'|Iteration]],Queue,New_Queue)).


/* One fuction to rule them all
* One function to call them all
* One function to bring them all
* and in program bind them */
anagrams(A, B, Moves):- 
    reverse(A,Begin),reverse(B,End),!,main(Begin, End, Moves1 ), reverse(Moves1,Moves).
