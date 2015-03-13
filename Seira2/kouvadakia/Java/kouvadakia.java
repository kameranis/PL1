/* Kouvadakia NTUA ECE PL1 spring semester 2014
 * We have two buckets with capacity A, B
 * We want one of the buckets to hold exactly C
 *
 * Konstantios Ameranis: 03112177 
 */


public class kouvadakia {

    static int min(int a, int b)
    {
        return a < b ? a : b;
    }

    static int max(int a, int b)
    {
        return a > b ? a : b;
    }

    // Return the Greater Common Divisor of a, b using Euclid's algorithm
    static int gcd(int a, int b)
    {
        if(a*b!=0) return gcd(max(a,b) % min(a,b), min(a,b));
        else return a+b;
    }

    /*
     * One fuction to rule them all
     * One function to call them all
     * One function to bring them all
     * and in program bind them
     */
    public static void main(String[] args) {
        int a = Integer.valueOf(args[0].trim());
        int b = Integer.valueOf(args[1].trim());
        int c = Integer.valueOf(args[2].trim());
        if((c>a && c>b) || (c % gcd(a, b) != 0))
        {
            System.out.println("impossible");
            return;
        }
        String acc1 = new String("01");
        int from = a, to = 0;
        while(from!=c && to!=c) {
            // Get water from the sea 
            if(from==0) {
                from = a;
                acc1 = new String(acc1+"-01");
            }

            // Empty water to the sea
            else if(to==b) {
                to = 0;
                acc1 = new String(acc1+"-20");
            }

            // Move water from 1 to 2
            else
            {
                int x = min(from, b-to); // x = water to be moved
                from = from - x;
                to = to + x;
                acc1 = new String(acc1+"-12");
            }
        }
        String acc2 = new String("02");
        from = b;
        to = 0;
        while(from!=c && to!=c) {
            // Get water from the sea 
            if(from==0) {
                from = b;
                acc2 = new String(acc2+"-02");
            }

            // Empty water to the sea
            else if(to==a) {
                to = 0;
                acc2 = new String(acc2+"-10");
            }

            // Move water from 2 to 1
            else
            {
                int x = min(from, a-to); // x = water to be moved
                from = from - x;
                to = to + x;
                acc2 = new String(acc2+"-21");
            }
        }
        if(acc1.length() < acc2.length()) System.out.println(acc1);
        else System.out.println(acc2);
        return;
    }
}
