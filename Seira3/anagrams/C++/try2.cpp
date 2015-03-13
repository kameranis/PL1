/*
 * Stack Anagrams ECE NTUA Spring 2014
 * We get 2 anagrams of the same letters
 * All the letters start at one stack
 * We must form the second word in the other stack
 * using only the two stacks and a on-letter register
 * Our goal is to do that in as few moves as possible
 * */

#include <cstdio>
#include <set>
#include <algorithm>
#include <iterator>
#include <queue>
#include <iostream>

using namespace std;

/* This class saves
 * stack[0]: register
 * stack[1]: first stack
 * stack[2]: second stack
 */
class State
{
    public:
        string stack[3];

        // Constructors
        State() {}
        
        State(const State &other)
        {
            this->stack[0] = other.stack[0];
            this->stack[1] = other.stack[1];
            this->stack[2] = other.stack[2];
        }

        State(string x, string y, string z)
        {
            stack[0] = x;
            stack[1] = y;
            stack[2] = z;
        }
        
        // This is used in order to be able to use the set container
        bool operator<(const State &other) const
        {
            int t;
            if((t = this->stack[1].compare(other.stack[1])) < 0)
                return true;
            if(t == 0) return (this->stack[2].compare(other.stack[2])) < 0;
            return false;
        }

        bool operator>(const State &other) const
        {
            int t;
            if((t = this->stack[1].compare(other.stack[1])) > 0)
                return true;
            if(t == 0) return (this->stack[2].compare(other.stack[2])) > 0;
            return false;
        }

        bool operator==(const State &other) const
        {
            return((this->stack[1].compare(other.stack[1]) == 0) 
            && (this->stack[2].compare(other.stack[2]) == 0) && (this->stack[0].compare(other.stack[0]) == 0));
        }

        /*~State()
        {
            for(int i=0; i<3; i++) delete &stack[i];
        }*/
};

/* This class saves the current state of the stacks, the moves performed to get
 * to that state and the heuristic distance that is needed for the ordering in the set
 */
class State_move
{
    public:
        State curr;
        vector<string> moves;
        int heur;
        
        // Constructors
        State_move() {curr = State();}

        State_move(State a, vector<string> move, int d)
        {  
            curr = State(a);
            moves = move;
            heur = d;    
        }
        
        // TO be able to use in set
        // Primary key: heuristic
        // Secondary key: State
        bool operator<(const State_move &other) const
        {
            if(this->heur != other.heur) return this->heur < other.heur;
            return this->curr < other.curr;
        }
        
        // Prints the current state
        void print() const
        {
            printf("%s %s %s\n", curr.stack[0].c_str(), curr.stack[1].c_str(), curr.stack[2].c_str());
        }

        // Destructor
        /*~State_move()
        {
            for(vector<string>::iterator it = moves.begin(); it != moves.end(); it++)
                delete &it;
            moves.clear();
        }*/
};

// Finds the heuristic distance of a state and a goal
// heuristic = letters - (letters in the beginning correctly placed)
int heuristic(string actual, string target)
{
    int count = 0;
    for(unsigned int i = 0; i < actual.size(); i++)
    {
        count++;
        if(actual[i] != target[i]) break;
    }
    return target.size() - count;
}

// Makes the move m in the state now
// the validity of the move is established beforehand
// Returns the new State_move after it has performed m and appended m to the moves
// of the initial State_move
State_move movement(State_move now, string m, string goal)
{
    int from = m[0]-'0', to = m[1]-'0';
    char c = now.curr.stack[from].at(now.curr.stack[from].size()-1);       // Character to be moved
    now.curr.stack[to].push_back(c);
    now.curr.stack[from].erase(now.curr.stack[from].size()-1);
    now.moves.push_back(m);
    State_move next = State_move(now.curr, now.moves, now.moves.size()+heuristic(now.curr.stack[2], goal));
    return next;
}


/* One fuction to rule them all
* One function to call them all
* One function to bring them all
* and in program bind them */

int main(int argc, char* argv[])
{
    // Initialazation
    if(argc != 3)
    {
        printf("You have given %d arguements\nExpected 3", argc);
        return 1;
    }
    string from = string(argv[1]);
    string goal = string(argv[2]);
    if(from.size() != goal.size())
    {
        printf("The 2 strings are not of the same length\n");
        return 2;
    }
    int count = 0;      // How many States I have visited, purely debugging
    set<State> visited;
    set<State_move> pos;
    pos.insert(State_move(State("", from, ""), vector<string>(), 0));

    // Main loop
    // Gets State_move with the lowest heuristic and adds possible moves
    while(!pos.empty())
    {
        count += 1;
        set<State_move>::iterator it = pos.begin();
        if(it->curr.stack[2].compare(goal) == 0)    // Base case, Found solution
        {
            for(unsigned int i = 0; i < it->moves.size()-1; i++)
            {
                printf("%s-", it->moves[i].c_str());
            }
            printf("%s\n", it->moves[it->moves.size()-1].c_str());
            // printf("%d\n", it->moves.size());
            // printf("%d\n", count);
            return 0;
        }
        if(it->moves.empty())       // First entry only, State("", from, "")
        {
            pos.insert(movement(*it, "12", goal));
            pos.insert(movement(*it, "10", goal));
            pos.erase(it);      // Delete lowest element 
            continue;           // Already added possibilities
        }

        visited.insert(it->curr);       // New unvisited State, add to visited
        string last = it->moves[it->moves.size()-1]; // According to last move, I can determine the next possible moves
        State_move next;
        //printf("%d %s\n", count, last.c_str()); 

        // A lot of conditionals conditions checking the condition of the conditions 
        // that brought us to the current condition used to condition the programming condition
        //
        // Ok, We just made that up, but it checks a lot of conditions :)
        if(last == "10")
        {
            if(!it->curr.stack[1].empty()) 
            {
                next = movement(*it, "12", goal);
                if(visited.find(next.curr) == visited.end() && pos.find(next) == pos.end()) pos.insert(next);
            }
            if(!it->curr.stack[2].empty()) 
            {
                next = movement(*it, "21", goal);
                if(visited.find(next.curr) == visited.end() && pos.find(next) == pos.end()) pos.insert(next);
            }
        }
        else if(last == "21")
        {
            if(!it->curr.stack[2].empty()) 
            {
                next = movement(*it, "21", goal);
                if(visited.find(next.curr) == visited.end() && pos.find(next) == pos.end()) pos.insert(next);
                if (it->curr.stack[0].empty())
                {
                    next = movement(*it, "20", goal);
                    if(visited.find(next.curr) == visited.end() && pos.find(next) == pos.end()) pos.insert(next);
                }
            }
            if(!it->curr.stack[0].empty())
            {
                next = movement(*it, "02", goal);
                if(visited.find(next.curr) == visited.end() && pos.find(next) == pos.end()) pos.insert(next);
                next = movement(*it, "01", goal);
                if(visited.find(next.curr) == visited.end() && pos.find(next) == pos.end()) pos.insert(next);
            }
        }
        else if(last == "02")
        {
            if(!it->curr.stack[1].empty())
            {
                next = movement(*it, "12", goal);
                if(visited.find(next.curr) == visited.end() && pos.find(next) == pos.end()) pos.insert(next);
                if(it->curr.stack[0].empty()) 
                {
                    next = movement(*it, "10", goal);
                    if(visited.find(next.curr) == visited.end() && pos.find(next) == pos.end()) pos.insert(next);
                }
            }
        }
        else if(last == "12")
        {
            if(!it->curr.stack[0].empty())
            {
                next = movement(*it, "02", goal);
                if(visited.find(next.curr) == visited.end() && pos.find(next) == pos.end()) pos.insert(next);
                next = movement(*it, "01", goal);
                if(visited.find(next.curr) == visited.end() && pos.find(next) == pos.end()) pos.insert(next);
            }
            else if(!it->curr.stack[1].empty()) 
            {
                next = movement(*it, "10", goal);
                if(visited.find(next.curr) == visited.end() && pos.find(next) == pos.end()) pos.insert(next);
            }
            if(!it->curr.stack[1].empty())
            {
                next = movement(*it, "12", goal);
                if(visited.find(next.curr) == visited.end() && pos.find(next) == pos.end()) pos.insert(next);
            }
        }
        else if(last == "01")
        {
            if(!it->curr.stack[2].empty())
            {
                next = movement(*it, "20", goal);
                if(visited.find(next.curr) == visited.end() && pos.find(next) == pos.end()) pos.insert(next);
                next = movement(*it, "21", goal);
                if(visited.find(next.curr) == visited.end() && pos.find(next) == pos.end()) pos.insert(next);
            }
        }
        else
        {
            if(!it->curr.stack[1].empty())
            {
                next = movement(*it, "12", goal);
                if(visited.find(next.curr) == visited.end() && pos.find(next) == pos.end()) pos.insert(next);
            }
            if(!it->curr.stack[2].empty())
            {
                next = movement(*it, "21", goal);
                if(visited.find(next.curr) == visited.end() && pos.find(next) == pos.end()) pos.insert(next);
            }
        }
            
        //const State_move* now = &(*it);
        pos.erase(it);      // Delete first element, so as to continue
        //delete now;
    }
}   
