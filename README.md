Sudoku Solver
=============

Port of [Solving Every Sudoku Puzzle](http://norvig.com/sudoku.html) by Peter Norvig in [Dart](http://www.dartlang.org/).

  - [sudoku.dart](https://github.com/dartist/sudoku_solver/blob/master/benchmarks/sudoku.dart) in Dart
  - [sudoku.py](https://github.com/dartist/sudoku_solver/blob/master/benchmarks/sudoku.py) in Python
  - [sudoku.cs](https://github.com/dartist/sudoku_solver/blob/master/benchmarks/sudoku.cs) in C#
  - [sudoku.rb](https://github.com/dartist/sudoku_solver/blob/master/benchmarks/sudoku.rb) in Ruby
  - [sudoku.coffee](https://github.com/dartist/sudoku_solver/blob/master/benchmarks/sudoku.coffee) in CoffeeScript
  
View above solutions [side-by-side in Python, Dart, C#, Ruby, CoffeeScript](https://gist.github.com/mythz/5723202). 
  
## Example

From Command line:

    ./bin/sudoku.dart .....6....59.....82....8....45........3........6..3.54...325..6..................

As a Library:

```dart
import '../lib/sudoku.dart';

solveSudoku('.....6....59.....82....8....45........3........6..3.54...325..6..................');
```

#### Output 

	Board: .....6....59.....82....8....45........3........6..3.54...325..6..................
	
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
	
	solved: true, in 69ms

## [Installing via Pub](http://pub.dartlang.org/packages/sudoku)	

Add this to your package's pubspec.yaml file:

	dependencies:
	  sudoku: 0.1.1

## Benchmarks

Results from running [these stand-alone benchmarks](https://github.com/dartist/sudoku_solver/blob/master/benchmarks/) 
on a new 2013 high-end 27" iMac on OSX after a clean re-start. Results are shown in Microseconds (µs):


## Side-by-side Results Summary

<table>
<tr><th></th><th>grid1</th><th>grid2</th><th>top95</th></tr>
<tr><td>Dart</td><td>1x</td><td>1.05x</td><td>1x</td></tr>
<tr><td>C# / .NET</td><td>1.15x</td><td>1x</td><td>1.22x</td></tr>
<tr><td>Python</td><td>1.20x</td><td>1.06x</td><td>1.36x</td></tr>
<tr><td>CoffeeScript</td><td>1.80x</td><td>15.36x</td><td>3.62x</td></tr>
<tr><td>C# / Mono</td><td>3.73x</td><td>3.23x</td><td>3.97x</td></tr>
<tr><td>Ruby</td><td>1.89x</td><td>6.53x</td><td>114.55x</td></tr>
</table>

### Dart

    localhost:benchmarks mythz$ dart sudoku.dart 
    grid1(RunTime): 3824.091778202677 us.
    grid2(RunTime): 8171.428571428572 us.
    top95(RunTime): 1160500.0 us.

### C# / .NET (in Paralells Windows 8 VM)

    C:\Users\mythz\Documents\Visual Studio 2012\Projects\Sudoku\Sudoku\bin\Release>Sudoku.exe
    grid1(RunTime): 4402.1978021978 us.
    grid2(RunTime): 7816.40625 us.
    top95(RunTime): 1415500 us.

### Python

    localhost:benchmarks mythz$ python sudoku.py 
    grid1(RunTime): 4581 us.
    grid2(RunTime): 8302 us.
    top95(RunTime): 1576500 us.

### CoffeeScript

    localhost:benchmarks mythz$ coffee sudoku.coffee 
    grid1(RunTime): 6893.470790378007 us.
    grid2(RunTime): 120058.82352941176 us.
    top95(RunTime): 4199000 us.

### C# / Mono

	localhost:benchmarks mythz$ dmcs -optimize sudoku.cs 
    localhost:benchmarks mythz$ mono sudoku.exe 
    grid1(RunTime): 14269.5035460993 us.
    grid2(RunTime): 25275 us.
    top95(RunTime): 4606000 us.

### Ruby

    localhost:benchmarks mythz$ /usr/local/Cellar/ruby/2.0.0-p0/bin/ruby sudoku.rb 
    grid1(RunTime): 7189.8172043010745 us.
    grid2(RunTime): 51023.675 us.
    top95(RunTime): 132935387.99999997 us.

#### Benchmark Notes

Unlike many benchmarks [these stand-alone ports](https://github.com/dartist/sudoku_solver/blob/master/benchmarks/) weren't written with performance in mind. i.e They were designed to show a readable and expressive example of Peter Norvig's original Python solution available in each language. These benchmarks then only show the performace of each languages contained 'readable style'.

I added the benchmark harness used in each port, which was originally based on Dart's 
[benchmark_harness](https://github.com/dart-lang/benchmark_harness/blob/master/lib/src/benchmark_base.dart#L35)
that is currently being used to measure [Dart's performance](http://www.dartlang.org/performance/).
i.e. There's a 100ms warmup, before running the specific benchmark for 2000ms, then returning the avg time 
for each iteration in Microseconds (µs). Whilst I aimed to keep the implementation of each benchmark harness 
as close as possible, if there is a more accurate / high-precision (stand-alone) method available please send in a pull-request and I'll update the results.

## The 'Hard1' board benchmarks

Peter Norvig's `hard1` sample board was run in isolation since in most cases each took a lot
longer than the 2s run rate being sampled above. In addition to the performace results varying significantly, most found different correct solutions to the same board (i.e. only Python / C# returned same board). The results however are deterministic, i.e. each run results in the same board being returned within the same time-frame. 

### Dart

	localhost:benchmarks mythz$ dart sudoku.dart 

	hard1: .....6....59.....82....8....45........3........6..3.54...325..6..................
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
	
	solved: true, in 67ms

### C# / .NET (in Paralells Windows 8 VM)

	C:\Users\mythz\Documents\Visual Studio 2012\Projects\Sudoku\Sudoku\bin\Release>Sudoku.exe
	hard1: .....6....59.....82....8....45........3........6..3.54...325..6..................
	4 3 8 |7 9 6 |2 1 5
	6 5 9 |1 3 2 |4 7 8
	2 7 1 |4 5 8 |6 9 3
	------+------+------
	8 4 5 |2 1 9 |3 6 7
	7 1 3 |5 6 4 |8 2 9
	9 2 6 |8 7 3 |1 5 4
	------+------+------
	1 9 4 |3 2 5 |7 8 6
	3 6 2 |9 8 7 |5 4 1
	5 8 7 |6 4 1 |9 3 2
	
	solved: True, in 50079ms
	
### Python

	localhost:benchmarks mythz$ python sudoku.py 
	
	hard1: .....6....59.....82....8....45........3........6..3.54...325..6..................
	4 3 8 |7 9 6 |2 1 5 
	6 5 9 |1 3 2 |4 7 8 
	2 7 1 |4 5 8 |6 9 3 
	------+------+------
	8 4 5 |2 1 9 |3 6 7 
	7 1 3 |5 6 4 |8 2 9 
	9 2 6 |8 7 3 |1 5 4 
	------+------+------
	1 9 4 |3 2 5 |7 8 6 
	3 6 2 |9 8 7 |5 4 1 
	5 8 7 |6 4 1 |9 3 2 
	
	solved: True, in 80425.67 ms

### C# / Mono

	localhost:benchmarks mythz$ dmcs -optimize sudoku.cs 
	localhost:benchmarks mythz$ mono sudoku.exe 
	hard1: .....6....59.....82....8....45........3........6..3.54...325..6..................
	4 3 8 |7 9 6 |2 1 5 
	6 5 9 |1 3 2 |4 7 8 
	2 7 1 |4 5 8 |6 9 3 
	------+------+------
	8 4 5 |2 1 9 |3 6 7 
	7 1 3 |5 6 4 |8 2 9 
	9 2 6 |8 7 3 |1 5 4 
	------+------+------
	1 9 4 |3 2 5 |7 8 6 
	3 6 2 |9 8 7 |5 4 1 
	5 8 7 |6 4 1 |9 3 2 

	solved: True, in 162868ms
	
### Ruby

	localhost:benchmarks mythz$ /usr/local/Cellar/ruby/2.0.0-p0/bin/ruby sudoku.rb 
	
	hard1: .....6....59.....82....8....45........3........6..3.54...325..6..................
	------+------+------
	4 6 2 |8 7 9 |1 3 5 
	3 5 7 |4 1 2 |9 6 8 
	8 9 1 |5 3 6 |4 2 7 
	------+------+------
	7 1 4 |2 5 8 |3 9 6 
	9 3 5 |1 6 7 |2 8 4 
	6 2 8 |9 4 3 |5 7 1 
	------+------+------
	2 4 6 |3 8 1 |7 5 9 
	1 7 9 |6 2 5 |8 4 3 
	5 8 3 |7 9 4 |6 1 2 
	------+------+------
	solved: true, in 247882.09100000001ms
	
### CoffeeScript
 
	Ran for over 1hr, but never finished. 


### Contributors

  - [mythz](https://github.com/mythz) (Demis Bellot)

------

Contributions for more languages or to make the existing ports more idiomatic are welcome.
