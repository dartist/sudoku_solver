Sudoku Solver
=============

Port of [Solving Every Sudoku Puzzle](http://norvig.com/sudoku.html) by Peter Norvig in [Dart](http://www.dartlang.org/).

  - [sudoku_solver.dart](https://github.com/dartist/sudoku_solver/blob/master/bin/sudoku_solver.dart) in Dart
  - [sudo.py](http://norvig.com/sudo.py) in Python
  - [Solver.cs](https://github.com/PKRoma/LinqSudokuSolver/blob/master/Solver.cs) in C#
  - [sudoku.rb](https://gist.github.com/jonelf/914326) in Ruby
  - [sudoku.coffee](https://gist.github.com/jonelf/927782) in CoffeeScript
  
View above solutions [side-by-side in Python, Dart, C#, Ruby, CoffeeScript](https://gist.github.com/mythz/5723202). 
  
## Examples

### Easy 1 board

    003020600900305001001806400008102900700000008006708200002609500800203009005010300

#### Output 

    4 8 3 |9 2 1 |6 5 7 
    9 6 7 |3 4 5 |8 2 1 
    2 5 1 |8 7 6 |4 9 3 
    ------+------+------
    5 4 8 |1 3 2 |9 7 6 
    7 2 9 |5 6 4 |1 3 8 
    1 3 6 |7 9 8 |2 4 5 
    ------+------+------
    3 7 2 |6 8 9 |5 1 4 
    8 1 4 |2 5 3 |7 6 9 
    6 9 5 |4 1 7 |3 8 2 

### Easy 2 board

    4.....8.5.3..........7......2.....6.....8.4......1.......6.3.7.5..2.....1.4......

#### Output 

    4 1 7 |3 6 9 |8 2 5 
    6 3 2 |1 5 8 |9 4 7 
    9 5 8 |7 2 4 |3 1 6 
    ------+------+------
    8 2 5 |4 3 7 |1 6 9 
    7 9 1 |5 8 6 |4 3 2 
    3 4 6 |9 1 2 |7 5 8 
    ------+------+------
    2 8 9 |6 4 3 |5 7 1 
    5 7 3 |2 9 1 |6 8 4 
    1 6 4 |8 7 5 |2 9 3 

### Hard 1 board

    .....6....59.....82....8....45........3........6..3.54...325..6..................

#### Output 

    4 8 7 |2 5 6 |3 1 9 
    6 5 9 |7 3 1 |4 2 8 
    2 3 1 |4 9 8 |6 7 5 
    ------+------+------
    9 4 5 |6 1 2 |7 8 3 
    7 1 3 |5 8 4 |9 6 2 
    8 2 6 |9 7 3 |1 5 4 
    ------+------+------
    1 7 4 |3 2 5 |8 9 6 
    3 9 2 |8 6 7 |5 4 1 
    5 6 8 |1 4 9 |2 3 7 

## Benchmarks

Results from running [these stand-alone benchmarks](https://github.com/dartist/sudoku_solver/blob/master/benchmarks/) 
on a new high-end 27" iMac on OSX. Results shown in Microseconds (µs):

### Dart

	localhost:benchmarks mythz$ dart sudoku.dart 
	grid1(RunTime): 3962.3762376237623 us. (1x)
	grid2(RunTime): 8432.773109243697 us.  (1x)
	top95(RunTime): 1198500.0 us.          (1x)

### Python

	localhost:benchmarks mythz$ python sudoku.py 
	grid1(RunTime): 4764 us.               (1.20x)
	grid2(RunTime): 8650 us.               (1.03x)
	top95(RunTime): 1637500 us.            (1.37x)

### C# / .NET (in Paralells Windows 8 VM)

	C:\Users\mythz\Documents\Visual Studio 2012\Projects\Sudoku\Sudoku\bin\Release>Sudoku.exe
	grid1(RunTime): 5149.10025706941 us.   (1.30x)
	grid2(RunTime): 9004.48430493274 us.   (1.07x)
	top95(RunTime): 1640000 us.            (1.37x)

### C# / Mono

	localhost:benchmarks mythz$ dmcs -optimize sudoku.cs 
	localhost:benchmarks mythz$ mono sudoku.exe 
	grid1(RunTime): 14735.2941176471 us.   (3.72x)
	grid2(RunTime): 26421.0526315789 us.   (3.13x)
	top95(RunTime): 4774000 us.            (3.98x)


### Contributors

  - [mythz](https://github.com/mythz) (Demis Bellot)

