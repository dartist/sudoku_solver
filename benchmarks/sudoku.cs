using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using System.Diagnostics;

/// <summary>
/// Ported from http://norvig.com/sudo.py by Richard Birkby, June 2007.
/// See http://norvig.com/sudoku.html
/// Also, https://bugzilla.mozilla.org/attachment.cgi?id=266577 - Javascript1.8 version
/// </summary>
static class LinqSudokuSolver {
    // Throughout this program we have:
    //   r is a row,    e.g. 'A'
    //   c is a column, e.g. '3'
    //   s is a square, e.g. 'A3'
    //   d is a digit,  e.g. '9'
    //   u is a unit,   e.g. ['A1','B1','C1','D1','E1','F1','G1','H1','I1']
    //   g is a grid,   e.g. 81 non-blank chars, e.g. starting with '.18...7...
    //   values is a dict of possible values, e.g. {'A1':'123489', 'A2':'8', ...}
    static string rows = "ABCDEFGHI";
    static string cols = "123456789";
    static string digits = "123456789";
    static string[] squares = cross(rows, cols);
    static Dictionary<string, IEnumerable<string>> peers;
    static Dictionary<string, IGrouping<string, string[]>> units;

    /*
     * def cross(A, B):
     *   return [a+b for a in A for b in B]
     */
    static string[] cross(string A, string B) {
        return (from a in A from b in B select ""+a+b).ToArray();
    }

    static LinqSudokuSolver() {
        /*
         * unitlist = ([cross(rows, c) for c in cols] +
         *           [cross(r, cols) for r in rows] +
         *           [cross(rs, cs) for rs in ('ABC','DEF','GHI') for cs in ('123','456','789')])
         */
        var unitlist=((from c in cols select cross(rows, c.ToString()))
                           .Concat(from r in rows select cross(r.ToString(), cols))
                           .Concat(from rs in (new [] { "ABC", "DEF", "GHI" }) from cs in (new [] { "123", "456", "789" }) select cross(rs, cs)));
        
        /*
         * units = dict((s, [u for u in unitlist if s in u]) 
         *   for s in squares)
         */
        units = (from s in squares from u in unitlist where u.Contains(s) group u by s into g select g).ToDictionary(g=>g.Key);

        /*
         * peers = dict((s, set(s2 for u in units[s] for s2 in u if s2 != s))
         *   for s in squares)
         */            
        peers = (from s in squares from u in units[s] from s2 in u where s2 != s group s2 by s into g select g).ToDictionary(g=>g.Key, g=>g.Distinct());

    }
    /* [Javascript1.8]
     * function zip(A, B) {
     *   let z = []
     *   let n = Math.min(A.length, B.length)
     *   for (let i = 0; i < n; i++)
     *     z.push([A[i], B[i]])
     *   return z
     * }
     */
    static string[][] zip(string[] A, string[] B) {
        var n=Math.Min(A.Length, B.Length);
        string[][] sd = new string[n][];
        for(var i = 0; i < n; i++) {
            sd[i]=new string[] {A[i].ToString(), B[i].ToString()};
        }
        return sd;
    }
    /*
    def parse_grid(grid):
        "Given a string of 81 digits (or . or 0 or -), return a dict of {cell:values}"
        grid = [c for c in grid if c in '0.-123456789']
        values = dict((s, digits) for s in squares) ## To start, every square can be any digit
        for s,d in zip(squares, grid):
            if d in digits and not assign(values, s, d):
            return False
        return values
    */
    /// <summary>Given a string of 81 digits (or . or 0 or -), return a dict of {cell:values}</summary>
    public static Dictionary<string, string> parse_grid(string grid) {
        //var grid2 = from c in grid where "0.-123456789".Contains(c) select c;
        var values = squares.ToDictionary(s => s, s => digits); //To start, every square can be any digit

        foreach (var sd in zip(squares, (from s in grid select s.ToString()).ToArray())) {
            var s = sd[0];
            var d = sd[1];

            if (digits.Contains(d) && assign(values, s, d)==null) {
                return null;
            }
        }
        return values;
    }

    /*
     * def search(values):
     *   "Using depth-first search and propagation, try all possible values."
     *   if values is False:
     *     return False ## Failed earlier
     *   if all(len(values[s]) == 1 for s in squares): 
     *     return values ## Solved!
     *   ## Chose the unfilled square s with the fewest possibilities
     *   _,s = min((len(values[s]), s) for s in squares if len(values[s]) > 1)
     *   return some(search(assign(values.copy(), s, d)) 
     *           for d in values[s])
     */
    /// <summary>Using depth-first search and propagation, try all possible values.</summary>
    public static Dictionary<string, string> search(Dictionary<string, string> values) {
        if (values == null) {
            return null; // Failed earlier
        }
        if (all(from s in squares select values[s].Length == 1?"":null)) {
            return values; // Solved!
        }

        // Chose the unfilled square s with the fewest possibilities
        var s2 = (from s in squares where values[s].Length > 1 orderby values[s].Length ascending select s).First();

        return some(from d in values[s2] 
                    select search(assign(new Dictionary<string,string>(values), s2, d.ToString())));
    }
    
    /*
     * def assign(values, s, d):
     *   "Eliminate all the other values (except d) from values[s] and propagate."
     *   if all(eliminate(values, s, d2) for d2 in values[s] if d2 != d):
     *     return values
     *   else:
     *     return False
     */
    /// <summary>Eliminate all the other values (except d) from values[s] and propagate.</summary>
    static Dictionary<string, string> assign(Dictionary<string, string> values, string s, string d) {
        if (all(
                from d2 in values[s] 
                where d2.ToString() != d 
                select eliminate(values, s, d2.ToString()))) {
            return values;
        }
        return null;
    }

    // Eliminate d from values[s]; propagate when values or places <= 2.
    /* def eliminate(values, s, d):
     *   "Eliminate d from values[s]; propagate when values or places <= 2."
     *   if d not in values[s]:
     *       return values ## Already eliminated
     *   values[s] = values[s].replace(d,'')
     *   if len(values[s]) == 0:
     *       return False ## Contradiction: removed last value
     *   elif len(values[s]) == 1:
     *       ## If there is only one value (d2) left in square, remove it from peers
     *       d2, = values[s]
     *       if not all(eliminate(values, s2, d2) for s2 in peers[s]):
     *           return False
     *   ## Now check the places where d appears in the units of s
     *   for u in units[s]:
     *       dplaces = [s for s in u if d in values[s]]
     *       if len(dplaces) == 0:
     *           return False
     *       elif len(dplaces) == 1:
     *           # d can only be in one place in unit; assign it there
     *           if not assign(values, dplaces[0], d):
     *               return False
     *   return values
     */
    /// <summary>Eliminate d from values[s]; propagate when values or places &lt;= 2.</summary>
    static Dictionary<string, string> eliminate(Dictionary<string, string> values, string s, string d) {
        if (!values[s].Contains(d)) {
            return values;
        }
        values[s]=values[s].Replace(d, "");
        if (values[s].Length == 0) {
            return null; //Contradiction: removed last value
        } else if (values[s].Length == 1) {
            //If there is only one value (d2) left in square, remove it from peers
            var d2 = values[s];
            if (!all(from s2 in peers[s] select eliminate(values, s2, d2))) {
                return null;
            }
        }

        //Now check the places where d appears in the units of s
        foreach (var u in units[s]) {
            var dplaces = from s2 in u where values[s2].Contains(d) select s2;
            if (dplaces.Count() == 0) {
                return null;
            } else if (dplaces.Count() == 1) {
                // d can only be in one place in unit; assign it there
                if (assign(values, dplaces.First(), d)==null) {
                    return null;
                }
            }
        }
        return values;
    }
    
    /*
     * def all(seq):
     *   for e in seq:
     *     if not e: return False
     *   return True
     */
    static bool all<T>(IEnumerable<T> seq) {
        foreach (var e in seq) {
            if (e==null) return false;
        }
        return true;
    }

    /*
     * def some(seq):
     *   for e in seq:
     *     if e: return e
     *  return False
     */
    static T some<T>(IEnumerable<T> seq) {
        foreach (var e in seq) {
            if (e!=null) return e;
        }            
        return default(T);
    }
    /*
     * def center(s, width):
     *   n = width - len(s)
     *   if n <= 0: return s
     *   half = n/2
     *   if n%2 and width%2:
     *     half = half+1
     *   return ' '*half +  s + ' '*(n-half)
     */
    static string Center(this string s, int width) {
        var n=width-s.Length;
        if(n<=0) return s;
        var half = n/2;

        if(n%2>0 && width%2>0) half++;

        return new string(' ', half) + s + new String(' ', n-half);
    }
    /*
     * def printboard(values):
     *   "Used for debugging."
     *   width = 1+max(len(values[s]) for s in squares)
     *   line = '\n' + '+'.join(['-'*(width*3)]*3)
     *   for r in rows:
     *     print ''.join(values[r+c].center(width)+(c in '36' and '|' or '')
     *            for c in cols) + (r in 'CF' and line or '')
     *   print
     *   return values
     */
    /// <summary>Used for debugging.</summary>
    static Dictionary<string, string> print_board(Dictionary<string, string> values) {
        if (values == null) return null;

        var width = 1 + (from s in squares select values[s].Length).Max();
        var line = "\n" + String.Join("+", Enumerable.Repeat(new String('-', width * 3), 3).ToArray());        

        foreach (var r in rows) {
            Console.WriteLine(String.Join("", 
                (from c in cols 
                 select values[""+r+c].Center(width)+("36".Contains(c)?"|":"")).ToArray()) 
                    + ("CF".Contains(r)?line:""));
        }

        Console.WriteLine();
        return values;
    }

static string grid1  = "003020600900305001001806400008102900700000008006708200002609500800203009005010300";
static string grid2  = "4.....8.5.3..........7......2.....6.....8.4......1.......6.3.7.5..2.....1.4......";
//static string hard1  = ".....6....59.....82....8....45........3........6..3.54...325..6..................";

static string[] top95 = @"4.....8.5.3..........7......2.....6.....8.4......1.......6.3.7.5..2.....1.4......
52...6.........7.13...........4..8..6......5...........418.........3..2...87.....
6.....8.3.4.7.................5.4.7.3..2.....1.6.......2.....5.....8.6......1....
48.3............71.2.......7.5....6....2..8.............1.76...3.....4......5....
....14....3....2...7..........9...3.6.1.............8.2.....1.4....5.6.....7.8...
......52..8.4......3...9...5.1...6..2..7........3.....6...1..........7.4.......3.
6.2.5.........3.4..........43...8....1....2........7..5..27...........81...6.....
.524.........7.1..............8.2...3.....6...9.5.....1.6.3...........897........
6.2.5.........4.3..........43...8....1....2........7..5..27...........81...6.....
.923.........8.1...........1.7.4...........658.........6.5.2...4.....7.....9.....
6..3.2....5.....1..........7.26............543.........8.15........4.2........7..
.6.5.1.9.1...9..539....7....4.8...7.......5.8.817.5.3.....5.2............76..8...
..5...987.4..5...1..7......2...48....9.1.....6..2.....3..6..2.......9.7.......5..
3.6.7...........518.........1.4.5...7.....6.....2......2.....4.....8.3.....5.....
1.....3.8.7.4..............2.3.1...........958.........5.6...7.....8.2...4.......
6..3.2....4.....1..........7.26............543.........8.15........4.2........7..
....3..9....2....1.5.9..............1.2.8.4.6.8.5...2..75......4.1..6..3.....4.6.
45.....3....8.1....9...........5..9.2..7.....8.........1..4..........7.2...6..8..
.237....68...6.59.9.....7......4.97.3.7.96..2.........5..47.........2....8.......
..84...3....3.....9....157479...8........7..514.....2...9.6...2.5....4......9..56
.98.1....2......6.............3.2.5..84.........6.........4.8.93..5...........1..
..247..58..............1.4.....2...9528.9.4....9...1.........3.3....75..685..2...
4.....8.5.3..........7......2.....6.....5.4......1.......6.3.7.5..2.....1.9......
.2.3......63.....58.......15....9.3....7........1....8.879..26......6.7...6..7..4
1.....7.9.4...72..8.........7..1..6.3.......5.6..4..2.........8..53...7.7.2....46
4.....3.....8.2......7........1...8734.......6........5...6........1.4...82......
.......71.2.8........4.3...7...6..5....2..3..9........6...7.....8....4......5....
6..3.2....4.....8..........7.26............543.........8.15........8.2........7..
.47.8...1............6..7..6....357......5....1..6....28..4.....9.1...4.....2.69.
......8.17..2........5.6......7...5..1....3...8.......5......2..4..8....6...3....
38.6.......9.......2..3.51......5....3..1..6....4......17.5..8.......9.......7.32
...5...........5.697.....2...48.2...25.1...3..8..3.........4.7..13.5..9..2...31..
.2.......3.5.62..9.68...3...5..........64.8.2..47..9....3.....1.....6...17.43....
.8..4....3......1........2...5...4.69..1..8..2...........3.9....6....5.....2.....
..8.9.1...6.5...2......6....3.1.7.5.........9..4...3...5....2...7...3.8.2..7....4
4.....5.8.3..........7......2.....6.....5.8......1.......6.3.7.5..2.....1.8......
1.....3.8.6.4..............2.3.1...........958.........5.6...7.....8.2...4.......
1....6.8..64..........4...7....9.6...7.4..5..5...7.1...5....32.3....8...4........
249.6...3.3....2..8.......5.....6......2......1..4.82..9.5..7....4.....1.7...3...
...8....9.873...4.6..7.......85..97...........43..75.......3....3...145.4....2..1
...5.1....9....8...6.......4.1..........7..9........3.8.....1.5...2..4.....36....
......8.16..2........7.5......6...2..1....3...8.......2......7..3..8....5...4....
.476...5.8.3.....2.....9......8.5..6...1.....6.24......78...51...6....4..9...4..7
.....7.95.....1...86..2.....2..73..85......6...3..49..3.5...41724................
.4.5.....8...9..3..76.2.....146..........9..7.....36....1..4.5..6......3..71..2..
.834.........7..5...........4.1.8..........27...3.....2.6.5....5.....8........1..
..9.....3.....9...7.....5.6..65..4.....3......28......3..75.6..6...........12.3.8
.26.39......6....19.....7.......4..9.5....2....85.....3..2..9..4....762.........4
2.3.8....8..7...........1...6.5.7...4......3....1............82.5....6...1.......
6..3.2....1.....5..........7.26............843.........8.15........8.2........7..
1.....9...64..1.7..7..4.......3.....3.89..5....7....2.....6.7.9.....4.1....129.3.
.........9......84.623...5....6...453...1...6...9...7....1.....4.5..2....3.8....9
.2....5938..5..46.94..6...8..2.3.....6..8.73.7..2.........4.38..7....6..........5
9.4..5...25.6..1..31......8.7...9...4..26......147....7.......2...3..8.6.4.....9.
...52.....9...3..4......7...1.....4..8..453..6...1...87.2........8....32.4..8..1.
53..2.9...24.3..5...9..........1.827...7.........981.............64....91.2.5.43.
1....786...7..8.1.8..2....9........24...1......9..5...6.8..........5.9.......93.4
....5...11......7..6.....8......4.....9.1.3.....596.2..8..62..7..7......3.5.7.2..
.47.2....8....1....3....9.2.....5...6..81..5.....4.....7....3.4...9...1.4..27.8..
......94.....9...53....5.7..8.4..1..463...........7.8.8..7.....7......28.5.26....
.2......6....41.....78....1......7....37.....6..412....1..74..5..8.5..7......39..
1.....3.8.6.4..............2.3.1...........758.........7.5...6.....8.2...4.......
2....1.9..1..3.7..9..8...2.......85..6.4.........7...3.2.3...6....5.....1.9...2.5
..7..8.....6.2.3...3......9.1..5..6.....1.....7.9....2........4.83..4...26....51.
...36....85.......9.4..8........68.........17..9..45...1.5...6.4....9..2.....3...
34.6.......7.......2..8.57......5....7..1..2....4......36.2..1.......9.......7.82
......4.18..2........6.7......8...6..4....3...1.......6......2..5..1....7...3....
.4..5..67...1...4....2.....1..8..3........2...6...........4..5.3.....8..2........
.......4...2..4..1.7..5..9...3..7....4..6....6..1..8...2....1..85.9...6.....8...3
8..7....4.5....6............3.97...8....43..5....2.9....6......2...6...7.71..83.2
.8...4.5....7..3............1..85...6.....2......4....3.26............417........
....7..8...6...5...2...3.61.1...7..2..8..534.2..9.......2......58...6.3.4...1....
......8.16..2........7.5......6...2..1....3...8.......2......7..4..8....5...3....
.2..........6....3.74.8.........3..2.8..4..1.6..5.........1.78.5....9..........4.
.52..68.......7.2.......6....48..9..2..41......1.....8..61..38.....9...63..6..1.9
....1.78.5....9..........4..2..........6....3.74.8.........3..2.8..4..1.6..5.....
1.......3.6.3..7...7...5..121.7...9...7........8.1..2....8.64....9.2..6....4.....
4...7.1....19.46.5.....1......7....2..2.3....847..6....14...8.6.2....3..6...9....
......8.17..2........5.6......7...5..1....3...8.......5......2..3..8....6...4....
963......1....8......2.5....4.8......1....7......3..257......3...9.2.4.7......9..
15.3......7..4.2....4.72.....8.........9..1.8.1..8.79......38...........6....7423
..........5724...98....947...9..3...5..9..12...3.1.9...6....25....56.....7......6
....75....1..2.....4...3...5.....3.2...8...1.......6.....1..48.2........7........
6.....7.3.4.8.................5.4.8.7..2.....1.3.......2.....5.....7.9......1....
....6...4..6.3....1..4..5.77.....8.5...8.....6.8....9...2.9....4....32....97..1..
.32.....58..3.....9.428...1...4...39...6...5.....1.....2...67.8.....4....95....6.
...5.3.......6.7..5.8....1636..2.......4.1.......3...567....2.8..4.7.......2..5..
.5.3.7.4.1.........3.......5.8.3.61....8..5.9.6..1........4...6...6927....2...9..
..5..8..18......9.......78....4.....64....9......53..2.6.........138..5....9.714.
..........72.6.1....51...82.8...13..4.........37.9..1.....238..5.4..9.........79.
...658.....4......12............96.7...3..5....2.8...3..19..8..3.6.....4....473..
.2.3.......6..8.9.83.5........2...8.7.9..5........6..4.......1...1...4.22..7..8.9
.5..9....1.....6.....3.8.....8.4...9514.......3....2..........4.8...6..77..15..6.
.....2.......7...17..3...9.8..7......2.89.6...13..6....9..5.824.....891..........
3...8.......7....51..............36...2..4....7...........6.13..452...........8..".Split('\n');

    public static void Test()
    {
        var easy = "..3.2.6..9..3.5..1..18.64....81.29..7.......8..67.82....26.95..8..2.3..9..5.1.3..";
        print_board(parse_grid(easy));

        Console.WriteLine("Simple elimination not possible:");
        var grid = "4.....8.5.3..........7......2.....6.....8.4......1.......6.3.7.5..2.....1.4......";
        print_board(parse_grid(grid));

        Console.WriteLine("Try again with search:");
        print_board(search(parse_grid(grid)));

        var hardest = "85...24..72......9..4.........1.7..23.5...9...4...........8..7..17..........36.4.";

        DateTime start = DateTime.Now;
        for (var i = 0; i < 300; i++)
        {
            search(parse_grid(hardest));
        }
        Console.WriteLine("Solving 'hardest' sodoku took on average " + (DateTime.Now - start).TotalMilliseconds / 300 + " milliseconds, timed over 300 runs");


        foreach (var game in top95)
        {
            Console.WriteLine(game);
            print_board(search(parse_grid(game)));
            search(parse_grid(game));
        }
        Console.WriteLine("Press enter to finish");
        Console.ReadLine();
    }

    static double measureFor(Action fn, int timeMinimum) {
      int iter = 0;
      Stopwatch watch = new Stopwatch();
      watch.Start();
      long elapsed = 0;
      while (elapsed < timeMinimum) {
        fn();
        elapsed = watch.ElapsedMilliseconds;
        iter++;
      }
      return 1000.0 * elapsed / iter;
    }

    static double measure(Action fn, int times=10, int runfor=2000, Action setup=null, Action warmup=null, Action teardown=null) {
      if (setup != null)
        setup();    

      // Warmup for at least 100ms. Discard result.
      if (warmup == null)
        warmup = fn;
      
      measureFor(() => { warmup(); }, 100);
      
      // Run the benchmark for at least 2000ms.
      double result = measureFor(() => { 
        for (var i=0; i<times; i++) 
          fn(); 
        }, runfor);
      
      if (teardown != null)
        teardown();
      
      return result;
    }

    static void report(String name, double score) {
        Console.WriteLine("{0}(RunTime): {1} us.", name, score);
    }

    static void benchmark(){
      report("grid1", measure(() => { search(parse_grid(grid1)); }, times:1));
      report("grid2", measure(() => { search(parse_grid(grid2)); }, times:1));
//      report("hard1", measure(() => { search(parse_grid(hard1)); }, times:1));
      report("top95", measure(() => { top95.ToList().ForEach((game) => { search(parse_grid(game)); }); }, times:1));
    }

    public static void Main(string[] args)
    {
        benchmark();
        Console.WriteLine("");
    }
}
