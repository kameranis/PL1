(*
* Problem Election Race pl1 ECE NTUA earino 2014
*
* N candidates run on a circle with length L
* if one candidate overtakes someone else, the overtakee get eliminated
* Find the order in which the candidates are eliminated
*
* In case of draws, it does not matter the order of the two
* Konstantinos Ameranis 21.6.2014
* *)


(* DISCLAIMER: This code is from
* http://www.cs.cornell.edu/courses/cs312/2007sp/lectures/lec15.html *)

datatype 'a avltree = Empty | Node of int * 'a * 'a avltree * 'a avltree

(* Rep Invariant:
 * For each node Node(h, v, l, r):
 * (1) BST invariant: v is greater than all values in l,
 *                    and less than all values in r.
 * (2) h is the height of the node.
 * (3) Each node is balanced, i.e., abs(l.h - r.h) <= 1
 *)

local 
fun height (Empty) = 0
  | height (Node(h,_,_,_)) = h

fun bal_factor (Empty) = 0
  | bal_factor (Node(_,_,l,r)) = (height l) - (height r)

fun node(v, l, r) =
  Node(1+Int.max(height l, height r), v, l, r)

fun rotate_left t =
  case t 
    of Node(_, x, a, Node(_, y, b, c)) => node(y, node(x, a, b), c)
     | _ => t

fun rotate_right(t) =
  case t
    of Node(_, x, Node(_, y, a, b), c) => node(y, a, node(x, b, c))
     | _ => t

(* Returns: an AVL tree containing the same values as n.
 * Requires: The children of n satisfy the AVL invariant, and
 *           their heights differ by at most 2. *)
fun balance (n as Node(h, v, l, r)) =
  case (bal_factor n, bal_factor l, bal_factor r) 
    of ( 2, ~1, _) => rotate_right(node(v, rotate_left l, r))
     | ( 2, _, _)  => rotate_right(n)
     | (~2, _, 1)  => rotate_left (node(v, l, rotate_right r))
     | (~2, _, _)  => rotate_left (n)
     | _ => n

fun add comp t n =          (* return t with a node containing n *)
  case t
    of Empty => node(n, Empty, Empty)
     | Node(h, v, l, r) =>
         case (comp (n, v))
           of EQUAL => t
            | LESS => balance(node(v, add comp l n, r))
            | GREATER => balance(node(v, l, add comp r n))

fun remove comp (t, n) =    (* removes n from t *)
  let
    fun removeSuccessor(t) =
      case t
        of Empty => raise Fail "impossible"
         | Node(_, v, Empty, r) => (r, v)
         | Node(_, v, l, r) => let val (l', v') = removeSuccessor(l)
                               in (balance(node(v, l', r)), v') end
  in
    case t
      of Empty => raise Fail "value not in the tree"
       | Node (_, v, l, r) =>
           case comp(n, v)
             of LESS => balance(node(v, remove comp (l, n), r))
              | GREATER => balance(node(v, l, remove comp (r, n)))
              | EQUAL => case (l, r)
                           of (_, Empty) => l
                            | (Empty, _) => r
                            | _ => let val (r', v') = removeSuccessor(r)
                                   in balance(node(v', l, r')) end
  end

(* END OF DISCLAIMER *)
exception ma
  (* returns the leftmost and therefore minimum node. Must not be calles as "min Empty" *)
fun min (Node(_, a, Empty, _)) = a    
  | min (Node(_, _, l, _)) = min (l)
  | min (_) = raise ma


(* returns the rightmost and therefore maximum node. Must not be calledas "max Empty" *)
fun max (Node(_, a, _, Empty)) = a
  | max (Node(_, _, _, r)) = max (r)
  | max _ = raise ma


(* Checks if a is a member of an AVL tree *)  
fun member comp Empty a = false
  | member comp (Node(_, v, l, r)) a = 
    case comp (v, a)
      of LESS => member comp r a
       | GREATER => member comp l a
       | EQUAL => true

(* returns if a tree is empty *)
fun empty Empty = true
  | empty (Node(_, _, _, _)) = false

(* returns the size of a tree. Can also be written tail recursively *) 
fun size Empty = 0
  | size (Node(_, _, l, r)) = 1 + (size l) + (size r)


(* Finds the value that comes before a *)  
fun prev comp (Node(_, v, l, r)) a parent =
  case comp (v, a)
    of EQUAL => if l = Empty then parent
                else max l
     | LESS => prev comp r a v
     | GREATER => prev comp l a parent


(* Finds the value that comes after a *)     
fun next comp (Node(_, v, l, r)) a parent =
  case comp (v, a)
    of EQUAL => if r = Empty then parent
                else min r
     | LESS => next comp r a parent
     | GREATER => next comp l a v


(* parses the file and returns a (int * real) list containing positions and
* velocities *)
fun parse file =
    let
	(* a function to read an integer from an input stream *)
      fun next_int input =
	  Option.valOf (TextIO.scanStream (Int.scan StringCvt.DEC) input)
	(* a function to read a real that spans till the end of line *)
      fun next_real input =
	  Option.valOf (TextIO.inputLine input)
	(* open input file and read the two integers in the first line *)
      val stream = TextIO.openIn file
      val n = next_int stream
      val l = next_int stream
	  val _ = TextIO.inputLine stream
	(* a function to read the pair of integer & real in subsequent lines *)
      fun scanner 0 acc = acc
        | scanner i acc =
        let
          val pos = next_int stream
          val (SOME vel) = Real.fromString (next_real stream)
        in
          scanner (i - 1) ( (pos, vel) :: acc)
        end
    in
        (n, l, Array.fromList (rev(scanner n [])))
    end
    
fun ov_comp ( (a : int, b : real), (c,d) ) = 
  if b < d then LESS
  else if b > d then GREATER
  else 
    if a < c then LESS
    else if a > c then GREATER
    else EQUAL


(* Creates the initial trees
* stillIn: who are still in the race
* overtakes: who is a possible candidate for elimination by the one currently
* behind him and the time in which he will be eliminated
* maxCount: how many will survive *)

fun create n l (cand : (int * real) array) =
  let
    fun create_t i maxSpeed maxCount n l (cand : (int * real) array) stillIn overtakes =
      if i <> (n-1) then
        let
          val (a,b) = Array.sub (cand, i) (* cand[i] *)
          val (c,d) = Array.sub (cand, (i+1))
          val new_stillIn = add Int.compare stillIn i;
          val new_overtakes = if b > d then (add ov_comp overtakes (i+1, real (c-
          a)/(b-d))) else overtakes
          val (new_maxSpeed, new_maxCount) = if b > maxSpeed then (b, 1) else if
          maxSpeed > b then (maxSpeed, maxCount) else (maxSpeed, maxCount + 1)
        in
          create_t (i+1) new_maxSpeed new_maxCount n l cand new_stillIn
          new_overtakes
        end
      else
        let
          val (a,b) = Array.sub (cand, i)
          val (c,d) = Array.sub (cand, 0)
          val new_stillIn = add Int.compare stillIn i
          val new_overtakes = if b > d then (add ov_comp overtakes (0, (real (l -
          a + c) / (b-d)) )) else overtakes
          val (new_maxSpeed, new_maxCount) = if b > maxSpeed then (b, 1) else if
          maxSpeed > b then (maxSpeed, maxCount) else (maxSpeed, maxCount + 1)
        in
          (new_stillIn, new_overtakes, new_maxCount)
        end
  in
    create_t 0 0.0 0 n l cand Empty Empty
  end


(* while there are more candidates for elimination, gets the one
* with the minimum time and updates the "overtakes" and "stillIn" trees *)

fun killem stillIn overtakes n l cand acc =
  if (empty overtakes) then (rev acc)
  else
    let
      val (pos, t) = min overtakes
    in
      if (member Int.compare stillIn pos) then
        let
          val p = prev Int.compare stillIn pos (max stillIn) 
          val n = next Int.compare stillIn pos (min stillIn)
          val (a,b) = Array.sub (cand, p)
          val (c,d) = Array.sub (cand, n)
          val new_stillIn = remove Int.compare (stillIn, pos)
          val new_overtakes = remove ov_comp (overtakes, (pos,t))
          val dist = if p < n then (real (c-a)) else (real(l - a + c))
          val new_overtakes = if b > d then (add ov_comp overtakes (n,
          dist/(b-d) )) else overtakes
        in
          killem new_stillIn new_overtakes n l cand ( (pos+1)::acc) 
        end
      else
        let
          val new_overtakes = remove ov_comp (overtakes, (pos, t))
        in
          killem stillIn new_overtakes n l cand acc
        end
    end
in

(* One fuction to rule them all
* One function to call them all
* One function to bring them all
* and in program bind them *)

fun agonas file =
  let
    val (n, l, cand) = parse file
    val (stillIn, overtakes, maxCount) = create n l cand
  in
    killem stillIn overtakes n l cand []
  end
end
