(* Problem Anaptiksi ECE pl1 earino 2014
* A road of length L needs to be renovated
* There are a total of N days of work
* Each day the part from start_i to end_i is renovated
* 
* Find the first day that the biggest continuous part of
* unrenovated road is less than X
*
* Konstantinos Ameranis
*)

local
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
      val x = next_int stream
	  val _ = TextIO.inputLine stream
	(* a function to read the pair of integer & integer in subsequent lines *)
      fun scanner 0 acc = acc
        | scanner i acc =
        let
          val start = next_int stream
          val finish = next_int stream
          val _ = TextIO.inputLine stream
        in
          scanner (i - 1) ( (n-i, start, finish) :: acc)
        end
    in
        (n, l, x, (~1, l, l)::(~1, 0, 0)::rev(scanner n []))
    end

fun comp ((_, a, b), (_, d, e)) = a > d 


(* returns a list containing only work done in the first m days *)
local
  fun mdays_t m [] acc = rev acc
    | mdays_t m ((x as (a,b,c))::xs) acc = mdays_t m xs (if a <= m then x::acc else acc)
in
  fun mdays m days = mdays_t m days []
end


(* Finds max road not renovated on the m-th day *)
local 
  fun findMax_t max _ [] = max
    | findMax_t max next_finish ((x as (a,b,c))::xs) =
    let 
      val diff = b - next_finish
    in
      findMax_t (if max > diff then max else diff) (if c>next_finish then c else
        next_finish) xs
    end
in
  fun findMax m days = findMax_t 0 0 (mdays m days)
end

(* Does a binary search on days *)
fun binsearch (n, x, left, right, days) = 
  if left = n then ~1
  else
    let
      val mid = (left + right) div 2
      val max = findMax mid days
    in
      if left > right then (if max > x then mid + 2
        else mid + 1)
      else
        if max <= x then binsearch (n, x, left, mid-1, days)
        else binsearch (n, x, mid+1, right, days)
    end
in
(* Solves *)
fun dromoi file = 
  let
    val (n, l, x, days) = parse file
  in
    binsearch (n, x, 0, n-1, ListMergeSort.sort comp days)
  end
end
