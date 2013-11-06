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
import 'package:sudoku/sudoku.dart';

main() {
  String board = '.....6....59.....82....8....45........3........6..3.54...325..6..................';
  Map result = solve(board);
  display(result);
}
```

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

## [Installing via Pub](http://pub.dartlang.org/packages/sudoku)	

Add this to your package's pubspec.yaml file:

	dependencies:
	  sudoku: 0.1.3

## Benchmarks

Results from running [these stand-alone benchmarks](https://github.com/dartist/sudoku_solver/blob/master/benchmarks/) 
on a new 2013 high-end 27" iMac on OSX after a clean re-start. Results are shown in Microseconds (µs):


## Side-by-side Results Summary

<table>
<tr><th></th><th>grid1</th><th>grid2</th><th>top95</th></tr>
<tr><td>PyPy</td><td>1x</td><td>1x</td><td>1.03x</td></tr>
<tr><td>Dart</td><td>1.55x</td><td>1.26x</td><td>1x</td></tr>
<tr><td>C# / Mono</td><td>2.68x</td><td>2.09x</td><td>1.96x</td></tr>
<tr><td>C# / .NET *</td><td>3.33x</td><td>2.60x</td><td>2.31x</td></tr>
<tr><td>Python</td><td>3.43x</td><td>2.58x</td><td>2.48x</td></tr>
<tr><td>CoffeeScript</td><td>4.70x</td><td>33.74x</td><td>5.81x</td></tr>
<tr><td>Ruby</td><td>5.23x</td><td>15.09x</td><td>200.83x</td></tr>
</table>

__* .NET running inside Parallels Windows 8.1 VM__


### PyPy

    iMac:benchmark mythz$ pypy --version
    Python 2.7.3 (480845e6b1dd, Jul 31 2013, 10:58:28)
    [PyPy 2.1.0 with GCC 4.2.1 Compatible Clang Compiler]

    iMac:benchmark mythz$ pypy sudoku.py 
    grid1(RunTime): 1369 us.
    grid2(RunTime): 3323 us.
    top95(RunTime): 678333 us.

### Dart

    iMac:benchmark mythz$ dart --version
    Dart VM version: 0.8.10.3_r29803 (Mon Nov  4 06:02:48 2013) on "macos_x64"

    iMac:benchmark mythz$ dart sudoku.dart 
    grid1(RunTime): 2125.3985122210415 us.
    grid2(RunTime): 4188.284518828452 us.
    top95(RunTime): 657000.0 us.

### C# / Mono

    iMac:benchmark mythz$ mono --version
    Mono JIT compiler version 3.2.0 ((no/7c7fcc7 Tue Jul 23 19:59:39 EDT 2013)
    Copyright (C) 2002-2012 Novell, Inc, Xamarin Inc and Contributors. www.mono-project.com
        TLS:           normal
        SIGSEGV:       altstack
        Notification:  kqueue
        Architecture:  x86
        Disabled:      none
        Misc:          softdebug 
        LLVM:          yes(3.3svn-mono)
        GC:            sgen

    iMac:benchmark mythz$ dmcs -w:0 -optimize sudoku.cs
    iMac:benchmark mythz$ mono sudoku.exe 
    grid1(RunTime): 3673.39449541284 us.
    grid2(RunTime): 6934.25605536332 us.
    top95(RunTime): 1291000 us.

### C# / .NET 4.0 (in Paralells Windows 8 VM)

    C:\src\sudoku_solver\benchmark>csc /optimize /warn:0 sudoku.cs
    Microsoft (R) Visual C# Compiler version 4.0.30319.17929
    for Microsoft (R) .NET Framework 4.5
    Copyright (C) Microsoft Corporation. All rights reserved.

    C:\src\sudoku_solver\benchmark>sudoku.exe
    grid1(RunTime): 4558.08656036446 us.
    grid2(RunTime): 8629.31034482759 us.
    top95(RunTime): 1517500 us.

### Python

    iMac:benchmark mythz$ python --version
    Python 2.7.5

    iMac:benchmark mythz$ python sudoku.py 
    grid1(RunTime): 4694 us.
    grid2(RunTime): 8587 us.
    top95(RunTime): 1629000 us.

### CoffeeScript

    iMac:benchmark mythz$ coffee -v
    CoffeeScript version 1.6.3
    iMac:benchmark mythz$ node -v
    v0.10.21

    iMac:benchmark mythz$ coffee sudoku.coffee 
    grid1(RunTime): 6434.083601286174 us.
    grid2(RunTime): 112111.11111111111 us.
    top95(RunTime): 3817000 us.

### Ruby

    iMac:benchmark mythz$ ruby --version
    ruby 2.0.0p247 (2013-06-27 revision 41674) [universal.x86_64-darwin13]

    iMac:benchmark mythz$ ruby sudoku.rb 
    grid1(RunTime): 7165.203571428572 us.
    grid2(RunTime): 50142.12500000001 us.
    top95(RunTime): 131944815.0 us.

#### Benchmark Notes

Unlike many benchmarks [these stand-alone ports](https://github.com/dartist/sudoku_solver/blob/master/benchmark/) weren't written with performance in mind. i.e They were designed to show a readable and expressive example of Peter Norvig's original Python solution available in each language. These benchmarks then only show the performace of each languages contained 'readable style'.

I added the benchmark harness used in each port, which was based on Dart's 
[benchmark_harness](https://github.com/dart-lang/benchmark_harness/blob/master/lib/src/benchmark_base.dart)
that is currently being used to measure [Dart's performance](http://www.dartlang.org/performance/).
i.e. There's a 100ms warmup, before running the specific benchmark for 2000ms, then returning the avg time 
for each iteration in Microseconds (µs). Whilst I aimed to keep the implementation of each benchmark harness 
as close as possible, if there is a more accurate / high-precision (stand-alone) method available please send in a pull-request and I'll update the results.

## The 'Hard1' board benchmarks

Peter Norvig's `hard1` sample board was run in isolation since in most cases each took a lot
longer than the 2s run rate being sampled above. In addition to the performace results varying significantly, most found different correct solutions to the same board (i.e. only Python / C# returned same board). The results however are deterministic, i.e. each run results in the same board being returned within the same time-frame. 

### Dart

    iMac:hard1 mythz$ dart sudoku.dart 
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

    solved: true, in 64ms

### PyPy

    iMac:hard1 mythz$ pypy sudoku.py 
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

    solved: True, in 37301.27 ms


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

### C# / Mono

    iMac:hard1 mythz$ mono sudoku.exe 
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

    solved: True, in 51971ms
	
### Python

    iMac:hard1 mythz$ python sudoku.py 
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

    solved: True, in 79835.44 ms
	
### Ruby

    iMac:hard1 mythz$ ruby sudoku.rb 
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
    solved: true, in 229950.406ms
	
### CoffeeScript
 
	Ran for over 1hr, but never finished. 


### Contributors

  - [mythz](https://github.com/mythz) (Demis Bellot)

------

Contributions for more languages or to make the existing ports more idiomatic are welcome.
