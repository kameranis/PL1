/*
 * EklogikoSagonas ECE pl1 earino 2014
 * N candidates run on a cycle of length L
 * Each candidate has a starting position and a velocity
 * If candidate i overtakes candidate j, j is eliminated
 *
 * This program finds the order in which the candidates get eliminated
 *
 */

#include <cstdio>
#include <cstdlib>
#include <algorithm>
#include <multiset>
#include <iterator>
using namespace std;

// Class elim is used for storing both the candidates and their number/overtake order

class elim
{
    public:
    double val;
    int pos;

    elim() {}   

    elim(int i, double x)
    {
        val = x;
        pos = i;
    }

    bool operator>(const elim &other) const
    {
        if(this -> val > other.val) return true;
        if(this -> val == other.val) return this->pos > other.pos;
        return false;
    }

    bool operator<(const elim &other) const
    {
        if(this -> val < other.val) return true;
        if(this -> val == other.val) return this->pos < other.pos;
        return false;
    }

    bool operator==(const elim &other) const
    {
        if((this -> val == other.val) && (this -> pos == other.pos)) return true;
        return false;
    }

    void multiset_values(int x, double y)
    {
        pos = x;
        val = y;
    }

    void print_values() const
    {
        printf("%d %lf\n", pos, val);
    }

};

multiset<int>::iterator prev_it(multiset<int>::iterator it) { return --it; }
multiset<int>::iterator next_it(multiset<int>::iterator it) { return ++it; }

int main(int argc, char *argv[])
{
    if(argc > 1 && !freopen(argv[1], "r", stdin)) exit(1);
    if(!stdin) exit(1);

    int N, L;
    if(scanf("%d %d", &N, &L) != 2) exit(2);

    double maxspeed = 0, x; // maxspeed is the speed of the fastest candidate
    int speedcount = 0, num;    // speedcount stores how many candidates have maxspeed
    elim *data = new elim[N];               // starting posisions/velocities

    for(int i = 0; i < N; i++)
    {   
        if(scanf("%d %lf", &num, &x) != 2) exit(2);
        data[i].multiset_values(num, x);     // input

        if(data[i].val > maxspeed)      // new maxspeed
        {   
            maxspeed = data[i].val;
            speedcount = 1;
        }   
        else if(data[i].val == maxspeed) speedcount += 1;   // another with maxspeed
    }

    multiset<int> stillin;
    multiset<elim> overtakes;
    for(int i = 0; i < N; i++)
    {
        int j = (i+1) % N;
        stillin.insert(i);
        if(data[i] > data[j] && data[i].pos != data[j].pos)
        {
            double time;
            if(i != N-1) time = (data[j].pos-data[i].pos) / (data[i].val-data[j].val);
            else time = (L+data[j].pos-data[i].pos) / (data[i].val-data[j].val);
            overtakes.insert(elim(j, time));
        }
    }
    // printf("done reading\n");
    int i = 0;
    // for(multiset<elim>::iterator it = overtakes.begin(); it != overtakes.end(); it++) it->print_values(); 
    for(; i < N - speedcount;)
    {
        multiset<elim>::iterator it = overtakes.begin();
        int x = it->pos;
        multiset<int>::iterator isin = stillin.find(x);
        // system("sleep 1");
        if(isin != stillin.end()) 
        {
            multiset<int>::iterator prev, next, end = stillin.end(), begin = stillin.begin();
            i++;
            printf("%d", x+1);
            int chase, victim;
            if(isin != begin) prev = prev_it(isin);
            else prev = prev_it(end);
            chase = *prev;

            if(isin != prev_it(end) ) next = next_it(isin);
            else next = begin; 
            victim = *next;
            
            overtakes.erase(it);
            stillin.erase(isin);
            if(data[chase] > data[victim] && data[chase].pos != data[victim].pos)
            {
                double time;
                if(chase < victim) time = (data[victim].pos-data[chase].pos) / (data[chase].val-data[victim].val);
                else time = (L+data[victim].pos-data[chase].pos) / (data[chase].val-data[victim].val);
                overtakes.insert(elim(victim, time));
            }
            
            if(i < N - speedcount) putchar(' ');
        }
        else
        {
            overtakes.erase(it);
        }
    }   
    delete[] data;
        
    putchar('\n');      // end line and bye
    return 0;
}
