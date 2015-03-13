(* creatures NTUA ECE PL1 spring semester 2014
* Starting from top left only going in straight lines
* from one bat (B) to the next, without touching any 
* walls (-) find the minimum distance to the spider (A)
*
* Konstantios Ameranis: 03112177 *)

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

(* Parses the file and returns primarily the creatures and walls *)
fun parse file =
    let
	(* a function to read an integer from an input stream *)
      fun next_int input =
	  Option.valOf (TextIO.scanStream (Int.scan StringCvt.DEC) input)
	(* a function to read a real that spans till the end of line *)
      fun next_real input =
	  Option.valOf (TextIO.inputLine input)
	(* open input file and read the three integers in the first line *)
      val stream = TextIO.openIn file
      val n = next_int stream   (* lines *)
      val m = next_int stream   (* rows  *)
      val k = next_int stream   (* Points of Interest *)
	  val _ = TextIO.inputLine stream   (* Get rid of newline *)
	(* a function to read the pair of integer & integer in subsequent lines *)
      fun scanner 0 spider creatures walls = (spider, creatures, walls)
        | scanner i spider creatures walls =
        let
          val x = next_int stream
          val y = next_int stream
          val d = valOf (TextIO.inputLine stream)
        in
          (* If creature *)
          if String.sub(d, 1) = #"A" then
            scanner (i - 1) (x, y, String.sub(d, 1)) ((x, y, String.sub(d, 1))::creatures) walls
          else if String.sub(d, 1) = #"B" then
            scanner (i - 1) spider ( (x, y, String.sub(d, 1)) :: creatures) walls
          (* Wall *)
          else scanner (i - 1) spider creatures ((x, y)::walls)
        end

      val (spider, creatures, walls) = scanner k (0, 0, #"A") [] []
    in
        (n, m, k, spider, rev creatures, rev walls)
    end

(* compares 2 creatures for our tree:
* Primary key: heuristic, distance
* Secondary keys: line, row difference *)
fun comp ((a, b, dist_a, heur_a, _:char), (x, y, dist_b, heur_b, _)) = 
  if (heur_a > heur_b orelse heur_a < heur_b) then Real.compare(heur_a, heur_b)
  else if (dist_a > dist_b orelse dist_a < dist_b) then Real.compare(dist_a, dist_b)
  else if a<>x then Int.compare(a, x)
  else Int.compare(b, y)

(* Returns the relative position of (x,y) to the line 
* defined by A(x1, y1), B(x2, y2) *)
fun line (x1:real, y1) (x2, y2) (x, y) = (y2-y1)*x+(x1-x2)*y+x2*y1-y2*x1

(* Returns if creatures A, B can see each other through obstacles walls *)
fun canSee _ _ [] = true    (* No more walls *)
  | canSee (r_a, c_a, desc_a) (r_b, c_b, desc_b) ((x,y)::walls) =
  let
    val (a, b) = (real x, real y)
    val pos = map (line (real r_a, real c_a) (real r_b, real c_b)) [(a-0.5, b-0.5), (a-0.5, b+0.5), (a+0.5, b+0.5), (a+0.5, b-0.5)]
  in
    (* Is within the rectangle of A,B *)
    if (x >= Int.min(r_a, r_b) andalso x <= Int.max(r_a, r_b) andalso y >=
    Int.min(c_a, c_b) andalso y <= Int.max(c_a, c_b)) then 
      (* and all edges of current wall are on the same side of the line *)
      if (List.all (fn x => x>0.0) pos) orelse (List.all (fn x => x<0.0) pos) then
        canSee (r_a, c_a, desc_a) (r_b, c_b, desc_b) walls
      else false
    else canSee (r_a, c_a, desc_a) (r_b, c_b, desc_b) walls
  end

(* Return the Euclidean distance of two points *)
fun dist (a, b) (x, y) = Math.sqrt(real((a-x)*(a-x)+(b-y)*(b-y)))

(* Creates a list that contains a n times *)
fun replicate _ 0 acc = acc
  | replicate a n acc = replicate a (n-1) (a::acc)

(* Constructs Graph in O(n^3) *)
fun addPos [] _ _ queue _ _ _ = queue
  | addPos ((a, b, d)::creatures) walls distances queue (x_sp, y_sp, d_sp) (x, y, so_far, h, desc:char) n =
    if(canSee (x, y, desc) (a, b, d) walls) then
      (* can see and is closer than previously thought *)
      if (so_far+(dist (x, y) (a, b))) < (Array.sub (distances, n)) then
        let
          (* update queue and array *)
          val queue = if member comp queue (a, b, (Array.sub (distances, n)), h, d)
            then remove comp (queue, (a, b, (Array.sub (distances, n)), h, d))
            else queue
          val _ = Array.update (distances, n, so_far+(dist (x, y) (a, b)))
          val heur = (Array.sub (distances, n)) + (dist (x, y) (x_sp, y_sp))
          val queue = add comp queue (a, b, (Array.sub (distances, n)), heur, d)
        in
          addPos creatures walls distances queue (x_sp, y_sp, d_sp) (x, y, so_far, h, desc) (n+1)
        end
      else addPos creatures walls distances queue (x_sp, y_sp, d_sp) (x, y, so_far, h, desc) (n+1)
    else addPos creatures walls distances queue (x_sp, y_sp, d_sp) (x, y, so_far, h, desc) (n+1)

(* djikstra: solves the problem
* Finds next possibles from current until it reaches the spider *)
fun djikstra creatures walls spider distances Empty = 0.0 
  | djikstra creatures walls spider distances queue =
  let
    val (curr as (x, y, d, h, desc:char)) = min queue
    val queue = remove comp (queue, curr)
    val queue = addPos creatures walls distances queue spider curr 0
  in
    if desc = #"A" then (real (round (d*100.0)))/100.0
    else djikstra creatures walls spider distances queue
  end

in
(* One fuction to rule them all
* One function to call them all
* One function to bring them all
* and in program bind them *)

fun bats file = 
  let
    val (n, m, k, spider as (x_sp, y_sp, d_sp), creatures, walls) = parse file    (* Input *)
    val (x, y, _) = hd creatures
  in
    djikstra creatures walls spider (Array.fromList (replicate (1.0/0.0) (length
    creatures) [])) (add comp Empty (x, y, 0.0, dist (0,0) (x_sp, y_sp), #"B"))
  end
end
