/* Bats NTUA ECE PL1 spring semester 2014
 * In a rectangle there are bats (B), walls (-) and a spider (A)
 * Using only straight lines from one bat to another, without going through a wall
 * how far is the spider from (0,0)
 *
 * 2 decimals required
 */

import java.util.*;
import java.io.File;
import java.io.FileNotFoundException;

// Used to save bats, walls and spider
class Point {
    public int c, r;
    public char desc;

    int min(int a, int b) { return a < b ? a : b; }
    int max(int a, int b) { return a > b ? a : b; }

    // Constructors
    Point(int a, int b, char d) { r = a; c = b; desc = d; }
    Point() { c = r = 0; desc = ' '; }

    // Returns the distance between this and p
    public double dist(Point p) {
        return Math.sqrt((this.r-p.r)*(this.r-p.r)+(this.c-p.c)*(this.c-p.c)); 
    }

    // Finds if wall intesects in the line between this and other
    public boolean intersects(Point other, Point wall)
    {
        boolean up = false, down = false;
        double[][] pos = { {wall.r-0.5, wall.c-0.5}, {wall.r-0.5, wall.c+0.5}, {wall.r+0.5, wall.c+0.5}, {wall.r+0.5, wall.c-0.5} };
        for(int i = 0; i < 4; i++)
        {
            double where = (this.c-other.c)*pos[i][0]+(other.r-this.r)*pos[i][1]+this.r*other.c-this.c*other.r;
            if(where > 0) up = true;
            else if (where < 0) down = true;
            else return false;
        }
        return up^down;
    }

    // Finds if a line can be drawn between this and other 
    public boolean canSee(Point other, ArrayList<Point> walls)
    {
        int a = min(this.r, other.r);
        int b = max(this.r, other.r);
        int c = min(this.c, other.c);
        int d = max(this.c, other.c);
        for(Point w: walls)
        {
            if(w.r < a || w.r > b || w.c < c || w.c > d) continue;
            if(!this.intersects(other, w)) return false;
        }
        return true;
    }
}

/* This class is used by the priority queue to determine the next one
* in Djikstra.
* Holds the id number of the creature and its current tentative distance
* in respect to (0,0) */

class Interest implements Comparable<Interest> {
    public int id;
    public double dist;
    public double heur;

    @Override
    public int compareTo(Interest a)
    { 
        double i;
        if((i=this.heur-a.heur)!=0) return (int) i;
        else if((i=this.dist-a.dist)!=0) return (int) i;
        else return this.id-a.id;
    }

    @Override
    public boolean equals(Object other)
    {
        if(this == other) return true;
        if(other == null || (this.getClass() != other.getClass()))
        {
            return false;
        }
        Interest guest = (Interest) other;
        return (this.id == guest.id) && (this.dist == guest.dist) && (this.heur == guest.heur);
    }
    
    /* Constructors */
    Interest(int i, double d, double h) { id = i; dist = d; heur = h;}
    Interest() { id = 0; dist = 0; heur = 0;}
}

/* Main class */
public class bats {

    static int min(int a, int b) { return a < b ? a : b; }
    static int max(int a, int b) { return a > b ? a : b; }

    public static void main(String[] args) {

        /* Input */
        try {
            Scanner in = new Scanner(new File(args[0]));
            ArrayList<Point> creatures = new ArrayList<Point>();
            ArrayList<Point> walls = new ArrayList<Point>();
            Point Spider = new Point();
            int n = in.nextInt();   // Board rows
            int m = in.nextInt();   // Board columns
            int k = in.nextInt();   // Number of interesting points
            in.nextLine();          // Skip line feed

            /* Reading interesting points */
            for(int i = 0; i < k; i++)
            {
                int r = in.nextInt();
                int c = in.nextInt();
                String str = in.nextLine();
                Point p = new Point(r, c, str.charAt(1));
                if(p.desc == 'A') 
                {
                    Spider = p;
                    creatures.add(p);
                }
                else if(p.desc == 'B') creatures.add(p);    // Point is bat or spider
                else if(p.desc == '-') walls.add(p);                    // Point is wall
            }
            
            /* Initialize parameters */
            int l = creatures.size();
            double[][] adjust = new double[l][l];
            for(int i = 0; i < l; i++)
                for(int j = 0; j < l; j++)
                    adjust[i][j]=0;
            boolean can;

            // A*: Prints the tentative distance of (0,0) to spider
            PriorityQueue<Interest> queue = new PriorityQueue<Interest>();
            double[] distances = new double[creatures.size()];  // Holds current tentative distances of all creatures
            Arrays.fill(distances, Double.MAX_VALUE);           // Which at the start is inf
            distances[0] = 0;                                   // Except for the start

            double[] heuristics = new double[creatures.size()]; // Holds the current heuristic of all creatures
            Arrays.fill(heuristics, Double.MAX_VALUE);          // Which at the start is inf
            heuristics[0] = creatures.get(0).dist(Spider);      // Except for the start
            
            queue.add(new Interest(0, 0, creatures.get(0).dist(Spider)));
            while(queue.size() > 0)
            {
                Interest curr = queue.poll();       // Creature closest to the visited sub-graph
                if(creatures.get(curr.id).desc == 'A')    // Got a spider. Let's get out of here, babe
                {
                    System.out.printf("%.2f\n", curr.dist); // That's right, I like C
                    return;
                }
                for(int i = 0; i < l; i++) {    // Construct edges for i-th creature
                    /* Haven't tested it and they can see each other */
                    if(adjust[curr.id][i] == 0 && (can = creatures.get(curr.id).canSee(creatures.get(i), walls)))
                    {
                        adjust[curr.id][i]=creatures.get(curr.id).dist(creatures.get(i));
                    }
                    /* Haven't tested it and they can't see each other */
                    else if(adjust[curr.id][i] == 0)
                    {
                        adjust[curr.id][i] = Double.MAX_VALUE;
                    }
                    adjust[i][curr.id]=adjust[curr.id][i];  // Undirected graph
                    double newDist;
                    // Can see each other and this is a better path than previously thought
                    if(adjust[curr.id][i] != Double.MAX_VALUE && (newDist=curr.dist+adjust[curr.id][i]) < distances[i])
                    {
                        queue.remove(new Interest(i, distances[i], heuristics[i]));    // remove old knowledge
                        distances[i] = newDist;                         // Replace tentative distance
                        heuristics[i] = newDist + creatures.get(i).dist(Spider);
                        queue.add(new Interest(i, distances[i], heuristics[i]));       // add new knowledge to the priority queue
                    }
                }
            }
            System.out.println("impossible");   // A* ended and I can't get to the spider
        }
        // If file is not valid
        catch(FileNotFoundException e) {
            e.printStackTrace();
        }
    }
}       
