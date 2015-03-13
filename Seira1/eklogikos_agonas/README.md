<h1>Problem 1: Election Race</h1>
N candidates are placed in a circle of length L. N \<= 500000, L \< 5000000.
Each one has an integer starting position D~i~ (0 \<= D~i~ \<= L) and a double velocity V~i~ (0 \<= V~i~ \<= 5) 
with two digits right of the comma. When a candidate is overtaken he is disqualified from the race.
In this problem you must print the sequence of the disqualification by printing each candidates number.

<h2>Input</h2>
In the first line we read the two integers N and L.
N lines follow containing starting position and velocity for the i[sup]th[/sup] cadidate.

<h2>Output</h2>
The sequence of the numbers of the disqualified candidates.

<h2>Examples</h2>
`\> cat candidates1.txt
6 150
0 1.75
30 0.8
60 0.5
70 1
120 0.1
140 0.9`

| In C++ | In SML/NJ |
|---|---|
| `> ./agonas candidates1.txt` | `- agonas "candidates1.txt";`|
| `2 3 5 4 6` | `val it = [2,3,5,4,6] : int list` |



<h2>Solution </h2>
For every i we check if this candidate can overtake the next and if so, we add the ovetakee and the time
it will take to be eliminated in an AVL tree (multiset in C++, custom AVL in SML). Having counted how many
candidates run at max speed, we know how many will be eliminated. We iterate through the eliminations,
each time checking if the candidate at the leftmost of the tree is still in the race and if so, we eliminate
him and check if the previous candidate can overpass the next candidate. If so, we add a new object to our tree.

<h3>Analysis</h3>
Initially we need O(NlogN) to construct the elimination tree. In each of the aproximately N eliminations we need
O(logN) to add the new possible elimination. Hence, the total algorithmical complexity is O(NlogN).
