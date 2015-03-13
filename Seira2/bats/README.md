<h1>Problem 2: Bats</h1>
Let there be a maze with a bat in the upper left corner, walls and other bats in various points
inside the maze and a single spider. Each bat can alert any other bat that it can see directly
(no walls are in the way) in time equal to the euclidean distance between the bats. Find the 
minimum time needed for the upper left bat to alert the spider.

<h2>Input</h2>
In the first line we read three integers N, M and K.
K lines follow containing a point of interest in the form `i j d` where i, j are the coordinates
and d stands for description B=Bat, A=Spider, -=Wall.

<h2>Output</h2>
Minimum time needed to alert the Spider

<h2>Examples</h2>
Are better shown in the exercise [description](http://courses.softlab.ntua.gr/pl1/Exercises/exerc14-2.pdf)

<h2>Solution </h2>
I have implemented the Djikstra algorithm, though A\* would be a much better choice. To determine if two bats 
can see each other, we check that each wall has all its edges on one side of the line created by bat~1~ and bat~2~.
A better choice would be to check if the line passes through a wall using the extended Bresenham algorithm

<h3>Analysis</h3>
Djikstra needs O(K) to finish. Each iteration needs O(K[sup]2[/sup]) to determine where it can continue next.
All in all the algorithmical complexity is O(K[sup]3[/sup]). Which is pretty bad...
