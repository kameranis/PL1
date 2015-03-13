<h1>Problem 2: buckets</h1>
We have two buckets k and k'. Each has a respective capacity of V~1~ and V~2~. Each time we can:
* 0k: fill bucket k to the brim from the sea
* k0: empty bucket k to the sea
* kk': pour water from k to k' until k is empty or k' is full

Find a series of moves, which is minimum in length, so that there are V~g~ liters of water in one bucket

<h2>Input</h2>
Pass as arguments three integers, V~1~, V~2~, V~g~.

<h2>Output</h2>
The sequence of moves as string.

<h2>Examples</h2>
| In SML/NJ | In Java |
| `- kouvadakia 3 4 1;` | `\> java Kouvadakia 3 4 1` |
| `val it = "02-21" : string` | `02-21` |
| `- kouvadakia 5 7 6;` | `\> java Kouvadakia 5 7 6` |
| `val it = "02-21-10-21-02-21-10-21-02-21" : string` | `02-21-10-21-02-21-10-21-02-21` |
| `- kouvadakia 4 2 1;` | `\> java Kouvadakia 4 2 1` |
| `val it = "impossible" : string` | `impossible`


<h2>Solution </h2>
We can prove that water should either go `0 -> 1 -> 2 -> 0` or `0 -> 2 -> 1 -> 0`
As a result knowing which way we go and how much water there is in each bucket, we have 4 cases
1. One of the buckets has V~g~ -> Return solution
2. The bucket that we fill from the sea is empty -> Fill from the sea
3. The bucket that we empty to the sea is full -> Empty to the sea
4. Pour from k to k'

We get the moves list for both directions and print the smallest

<h3>Analysis</h3>
Each move needs O(1). As a result the total algorithmical complexity is O(N), where N the number of moves
needed in the wrong direction
