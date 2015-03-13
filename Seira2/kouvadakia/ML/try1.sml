(* Kouvadakia NTUA ECE PL1 spring semester 2014
* We have two buckets with capacity A, B
* We want one of the buckets to hold exactly C
*
* Konstantios Ameranis: 03112177 *)

local
fun gcd 0 b = b
  | gcd a 0 = a
  | gcd a b = gcd ((Int.max (a, b)) mod (Int.min (a, b))) (Int.min (a, b))

fun move (from_c, from) (to_c, to) c n acc =
  
  (* Base case *)
  if from = c orelse to = c then String.concatWith "-" (rev acc)
  
  (* Get water from sea *)
  else if from = 0
  then move (from_c, from_c) (to_c, to) c n ("0"^Int.toString(n)::acc)
  
  (* Empty to the sea *)
  else if to = to_c
  then move (from_c, from) (to_c, 0) c n (Int.toString(3-n)^"0"::acc)
  
  (* n to 3-n *)
  else
  move (from_c, (from-Int.min (to_c-to, from))) (to_c, to+(Int.min (to_c-to,
  from))) c n
  (Int.toString(n)^Int.toString(3-n)::acc)

in

(* One fuction to rule them all
* One function to call them all
* One function to bring them all
* and in program bind them *)
fun kouvadakia a b c =
  if c>a andalso c>b then "impossible"
  else if c mod (gcd a b) <> 0 then "impossible"
  else 
    let
      val s1 = move (a, a) (b, 0) c 1 ["01"]
      val s2 = move (b, b) (a, 0) c 2 ["02"]
    in
      if (size s1) < (size s2) then s1
      else s2
    end
end
