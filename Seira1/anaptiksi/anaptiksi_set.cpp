/*
 * Problem Anaptiksi ECE pl1 earino 2014
 * A road of length L needs to be renovated
 * In N days, each day the part from start_i to end_i is renovated
 * Find the day that the biggest continuous part of unrenovated road is less than X
 * 
 * Konstantinos Ameranis
 */

#include <cstdio>
#include <algorithm>
#include <set>
#include <iterator>

using namespace std;

class day       // Each day of work is saved as an object
{
    public:
        int start, finish;

        day() {}

        day(int x, int y)
        {
            start = x;
            finish = y;
        }

        bool operator<(const day & other) const
        {
            return this->start < other.start || (this->start == other.start && this->finish < other.finish);
        }

        bool operator>(const day & other) const 
        {
            return this->start > other.start || (this->start == other.start && this->finish > other.finish);
        }

        bool operator==(const day & other) const
        {
            return (this->start == other.start) && (this->finish == other.finish);
        }

        void set_values(int x, int y)
        {
            start = x;
            finish = y;
        }

        void print_values() const
        {
            printf("%d %d\n", start, finish);
        }

};

set<day>::iterator prev_it(set<day>::iterator it) { return --it; }  // Can't use C++11
set<day>::iterator next_it(set<day>::iterator it) { return ++it; }  // Can't use C++11

int max_road(set<day> interval)         // Given a set of work done, finds the maximum piece of road not yet renovated O(n)
{
    int max = 0;
    int next_finish = 0;
    for(set<day>::iterator it = interval.begin(); it != interval.end(); it++)
    {
        if(it->start > next_finish)
        {
            int dist = it->start - next_finish;
            if(dist > max) max = dist;
        }
        if(it->finish > next_finish) next_finish = it->finish;
    }
    return max;
}



int main(int argc, char *argv[])
{
    if(argc > 1 && !freopen(argv[1], "r", stdin)) exit(1);      // file opening
    if(!stdin) exit(1);

    int N, L, X;
    if(scanf("%d %d %d", &N, &L, &X) != 3) exit(2);             // First line of input

    day work[N];
    int x, y;
    for(int i = 0; i < N; i++)
    {
        if(scanf("%d %d", &x, &y) != 2) exit(2);                // The rest of the input
        work[i].set_values(x, y);
    }

    set<day> interval;              // Initialize set
    interval.insert(day(0, 0));
    interval.insert(day(L, L));

    int right=N-1, left=0, mid = (N-1)/2, old_mid = mid;        // Binary search O(logn)
    for(int i = 0; i <= mid; i++) interval.insert(work[i]);

    int max = 0;
    while(right >= left)
    {
        max = max_road(interval);       // find max
        
        // printf("%d %d %d\n", mid, max, X);   // test line
        
        if(max > X) left = mid + 1;
        else if(max < X) right = mid-1;
        else { printf("%d\n", mid + 1); return 0; }

        old_mid = mid;
        mid = (right + left) / 2;
        if(old_mid < mid)       // update set to have days[0..mid]
        {
            for(int i = old_mid; i <= mid; i++) interval.insert(work[i]);
        }
        else
        {
            for(int i = old_mid; i > mid; i--) interval.erase(work[i]);
        }
        // system("sleep 1");   // For slow execution
    }
    if(left < N) {
        printf("%d\n", max > X ? old_mid + 2 : old_mid + 1);    // end of binary, found day
        return 0;
    }

    printf("-1\n");         // Didn't find day
    return 0;
}
