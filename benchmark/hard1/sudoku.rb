#!usr/bin/env ruby
# 2011-04-11 jonelf@gmail.com

# Sudoku solver refactored from Luddite Geek http://theludditegeek.com/blog/?page_id=92
# and that in turn is a translation from the Python solution by Peter Norvig
# http://norvig.com/sudoku.html

## Throughout this program we have:
##   r is a row,    e.g. 'A'
##   c is a column, e.g. '3'
##   s is a square, e.g. 'A3'
##   d is a digit,  e.g. '9'
##   u is a unit,   e.g. ['A1','B1','C1','D1','E1','F1','G1','H1','I1']
##   grid is a grid,e.g. 81 non-blank chars, e.g. starting with '.18...7...
##   values is a dict/hash of possible values, e.g. {'A1':'12349', 'A2':'8', ...}

ROWS = ('A'..'I')
COLS = ('1'..'9')
DIGITS = "123456789"

def cross(rows,cols)
  cols.map {|x| rows.map {|y| y + x  }}.flatten
end

@squares =  cross(ROWS, COLS) # total of 81 squares
# rowset(9) + colset (9) + subgrids (9) -   27 total
nine_squares = ROWS.each_slice(3).map {|r| COLS.each_slice(3).map{|c| cross(r,c)}}.flatten(1)
@unitlist = COLS.map{|c| cross(ROWS,[c])} <<
            ROWS.map{|r| cross([r], COLS)} <<
            nine_squares
@units = @squares.inject({}) {|h, s| h[s]=@unitlist.select{|arr| arr.include?(s)};h}
# All on the same row, same column and same 1/9 unit except the square itself
@peers = @squares.inject({}) {|h,s| peers=(cross(ROWS,[s[1]]) << 
                                    cross([s[0]],COLS) << 
                                    nine_squares.select{|sq| sq.include?(s)} ).
                                    flatten; 
                                    peers.delete(s);
                                    h[s]=peers;
                                    h}

def grid_values(grid)
  #  Convert grid into a dict of {square: char} with '0' or '.' for empties.
  @squares.zip(grid.each_char.grep(/[0-9\.]/))
end

################ Constraint Propagation ################

def assign(values, s, d)
  # eliminate all other values (except d) from values[s] and propogate
  # return updated values, unless a contradiction is detected (then return false)
  other_values = values[s].sub(d,'')
  other_values.each_char do |d2|
    return false unless eliminate(values, s, d2)
  end
  values
end

def eliminate(values, s, d)
  # Eliminate digit from values list; propogate when # of values/places  reduced to <= 2
  # Return false if contradiction is detected; else return values 
  return values unless values[s].include?(d) ## Already eliminated

  values[s] = values[s].sub(d,'')

  ## (1) If a square s is reduced to one value d2, then eliminate d2 from the peers.
  if values[s].size== 0
    return false ## Contradiction: removed last value
  elsif values[s].size == 1
    d2 = values[s]
    @peers[s].each do |s2|
      return false unless (eliminate(values, s2, d2))
    end
  end

  ## (2) If a unit u is reduced to only one place for a value d, then put it there.
  sa = [s]
  @units[s].each do |u|
    dplaces = values[s].include?(d) ? sa & u : []
    ## Contradiction: no place for this value
    return values if dplaces.size == 0
    if dplaces.size == 1
      return false unless assign(values, dplaces[0], d)
    end
	end
  values
end # def

################ Display Results as 2-D grid ################       

def display(values)
  #"Display these values as a 2-D grid."
  #width = 2 since the "DG" and "36" are hardcoded anyway.
  width = 2 #1 + values.max_by {|a| a.size}[1].size
  puts line = [['-'*width*3]*3].join('+') # 81 square grid
  ROWS.each do |r|
    puts line if "DG".include?(r)    # 3x3 grid
    COLS.each do |c|
      print values["#{r}#{c}"].center(width)
      print '|' if '36'.include?(c)
    end
    puts
  end
  puts line
end

################ Utilities ################

def get_min(d)
  # Find best candidate to process next (i.e. entry w least # of  possible values) = steps are:
  # 1) filter list - only select those with length > 1 (otherwise it's a solved square)
  # 2) return key, value and length of shortest entry
  min = d.select{|k,v| v.length>1}.
          min_by{|h| h[1].length}
  return min[0], min[1], min[1].length
end

################ Parse a Grid ################

def parse_grid (grid)
  # Convert grid to a list of possible values and parses grid into a values dictionary
  # the values hash/dict contains a text string of possible values for each cell
  # if cell is completed then the string is 1 char long with the correct/solved value
  # the grid is an array containing the initial/current?? value(s) defined in the puzzle

  values = {} # define values dictionary
  @squares.each do |s|
    values[s] = DIGITS
  end

  grid_values(grid).each do |zg|
    # extract cell names and values from zip grid array
    s, d = zg
    if DIGITS.include?(d)
      return false unless assign(values, s, d)
    end
  end
  values
end # parse_grid  

################ Search Grid Values ################    

def search(values)
  # Depth first search and propagation
  return false unless values ## Failed earlier
  return values unless @squares.any?{|s| values[s].size != 1}
  # For harder puzzles there is some more work to do
  # Find the unfilled square s with the fewest possibilities
  # and continue the search/elimination process
  k,v,l =  get_min(values)
  v.each_char do |d|
    r = search(assign(values.clone, k, d))
    return r if r
  end
  return false
end # search def


### define set of test games

require 'benchmark'

GRID1  = '003020600900305001001806400008102900700000008006708200002609500800203009005010300'
GRID2  = '4.....8.5.3..........7......2.....6.....8.4......1.......6.3.7.5..2.....1.4......'
HARD1  = '.....6....59.....82....8....45........3........6..3.54...325..6..................'
TOP95 = %w{
4.....8.5.3..........7......2.....6.....8.4......1.......6.3.7.5..2.....1.4......
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
3...8.......7....51..............36...2..4....7...........6.13..452...........8..
}

def measureFor(fn, timeMinimum) 
  iter = 0
  elapsed = 0
  start = Time.now
  while elapsed < timeMinimum do 
    fn.call()
    elapsed = (Time.now - start) * 1000
    iter += 1
  end
  return 1000.0 * elapsed / iter
end

def measure(fn, times = 10, runfor = 2000, setup=nil, warmup=nil, teardown=nil) 
  if setup != nil
    setup.call()    
  end

  # Warmup for at least 100ms. Discard result.
  if warmup == nil
    warmup = fn
  end
  
  measureFor(lambda { warmup.call() }, 100)
  
  # Run the benchmark for at least 2000ms.
  result = measureFor(lambda { (0..times).each { |i| fn.call() } }, runfor)
  
  if teardown != nil
    teardown.call()
  end
  
  return result
end

def report(name, score) 
  puts "#{name}(RunTime): #{score} us."
end

def log(o)
  puts o
  return o
end

def solved(values)
  unitsolved = lambda { |unit| ((unit.map { |s| (values[s]) }.uniq - DIGITS.chars.uniq {|c| c}).length) == 0 }
  return values != nil && @unitlist.select{ |unit| unitsolved.call((unit)) }.all?   
end

def solveGrid(name, grid)
  solution = nil
  puts "#{name}: #{grid}"
  time = Benchmark.realtime do
  	solution = search(parse_grid(grid))
  end
  display(solution)
  puts "solved: #{solved(solution)}, in #{time * 1000}ms\n"
end

def displayAll()
  solveGrid("grid1", GRID1)
  solveGrid("grid2", GRID2)
  i = 0
  TOP95.each { |game| solveGrid("top #{i += 1}/95", game) }
end

def benchmark()
  report("grid1", measure(lambda { search(parse_grid(GRID1)) }, 1))
  report("grid2", measure(lambda { search(parse_grid(GRID2)) }, 1))
  report("top95", measure(lambda { TOP95.each { |game| search(parse_grid(game)) } }, 1))
end

#benchmark()
#puts ""
#displayAll()
solveGrid("hard1", HARD1)
