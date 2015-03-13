<h1>Problem 2: anaptiksi</h1>
A road must be renovated. Each day the crew renovates from S~i~ to E~i~. This segment might contain
parts that have already been renovated. Find the first day that the largest consecutive unrenovated
segment is less than or equal to X. Else print -1

<h2>Input</h2>
In the first line there are 3 integers N, L, X. N is the number of days that the renovation will take place
L is the total length of the road. X is the limit that the largest segment must not supercede.

<h2>Output</h2>
Returns the first day that the largest segment does not supercede X, or -1 if there is no such day

<h2>Examples</h2>
| \> cat anaptyksi1.txt |\> cat anaptyksi2.txt |
| 4 30 6 | 4 30 1 |
| 1 5 | 1 5 |
| 11 27 | 11 27 |
| 2 14 | 2 14 |
| 18 28 | 18 28 |

| In C++ | In SML/NJ |
| \> ./dromoi anaptyksi1.txt | - dromoi "anaptyksi1.txt"; |
| 2 | val it = 2 : int |
| \> ./dromoi anaptyksi2.txt | - dromoi "anaptyksi2.txt"; |
| -1 | val it = ~1 : int |

<h2>Solution</h2>
For each day we create an object containing day, S~i~ and E~i~, adding (0, 0, 0) and (0, L, L). We sort in ascending S~i~ value.
Next we will do a binary search on the days. Let M be the middle day, we filter only the days less than M
and find the largest unrenovated segment in O(M). If at the end right == L then no day was found.

<h2>Analysis</h2>
Sorting the elements takes O(NlogN). Binary search takes O(logN) and each iteration in the binary search takes
O(N). Hence, the total algorithmical complexity is O(NlogN).
