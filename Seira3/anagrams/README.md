<h1>Problem: anagrams</h1>
Let there be two stacks and a register. Given an initial anagram in the first stack,
form the target anagram in the second stack. Print the series of moves needed. For the moves
let the initial stack be 1, the second stack 2 and the register 0. For example moving a letter
from the register to the first stack is denoted `01`

<h2>Input</h2>
Pass as arguements the initial and target anagram

<h2>Output</h2>
String of moves in C++, Java and ML; list of moves in Prolog. Note that there is not only
one correct sequence of moves.

<h2>Examples</h2>
In Prolog
`?- anagrams("rice", "cire", Moves).
Moves = ['10','12','12','12','02'].
?- anagrams("anagram", "mragana", Moves).
Moves = ['12','10','12','02','12','12','12','12'].
?- anagrams("mirror", "mirorr", Moves).
Moves = ['12','12','10','12','12','02','10','21','21','21','21','21','02','12','12',
’12','10','21','21','21','02','12','12','12','12’].`

In SML/NJ
`- anagrams ("rice", "cire");
 val it = "10-12-12-12-02" : string `

In C++, Java
`$ java Anagrams rice cire
10-12-12-12-02
$ ./a.out rice cire
10-12-12-12-02`

<h2>Solution </h2>
We will use the A\* algorithm. As a heuristic we use how many letters are not in position.
