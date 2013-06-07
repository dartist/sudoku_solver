part of sudoku_solver;

wrap(value, fn(x)) => fn(value);

order(List seq, {Comparator by, List<Comparator> byAll, on(x), List<Function> onAll}) =>
  by != null ? 
    (seq..sort(by)) 
  : byAll != null ?
    (seq..sort((a,b) => byAll
      .firstWhere((compare) => compare(a,b) != 0, orElse:() => (x,y) => 0)(a,b)))
  : on != null ? 
    (seq..sort((a,b) => on(a).compareTo(on(b)))) 
  : onAll != null ?
    (seq..sort((a,b) =>
      wrap(onAll.firstWhere((_on) => _on(a).compareTo(_on(b)) != 0, orElse:() => (x) => 0),
        (_on) => _on(a).compareTo(_on(b)) 
    ))) 
  : (seq..sort()); 

List<List> zip(a, b) {
  var z = [];
  var n = Math.min(a.length, b.length);
  for (var i=0; i<n; i++)
    z.add([a.elementAt(i), b.elementAt(i)]);
  return z;
}

String repeat(String s, int n){
  var sb = new StringBuffer();
  for (var i=0; i<n; i++)
    sb.write(s);
  return sb.toString();
}

String center(String s, int max, [String pad=" "]) {
  var padLen = max - s.length;
  if (padLen <= 0) return s;
  
  s = repeat(pad, (padLen/2).toInt()) + s;
  return s + repeat(pad, max-s.length);
}
 
Map dict(Iterable seq) => seq.fold({}, (map, kv) => map..putIfAbsent(kv[0], () => kv[1]));
dynamic some(Iterable seq) => seq.firstWhere((e) => e != null, orElse:() => null);
bool all(Iterable seq) => seq.every((e) => e != null);

var rand = new Math.Random();
List shuffled(Iterable seq) => order(seq.toList(), on:(a) => rand.nextDouble());

log(s){
  print(s);
  return s;
}

double measureFor(Function f, int timeMinimum) {
  int iter = 0;
  Stopwatch watch = new Stopwatch();
  watch.start();
  int elapsed = 0;
  while (elapsed < timeMinimum) {
    f();
    elapsed = watch.elapsedMilliseconds;
    iter++;
  }
  return 1000.0 * elapsed / iter;
}

// Measures the score for the benchmark and returns it.
double measure(Function fn, {times: 10, runfor: 2000, Function setup, Function warmup, Function teardown}) {
  if (setup != null)
    setup();    

  // Warmup for at least 100ms. Discard result.
  if (warmup == null)
    warmup = fn;
  
  measureFor(() { warmup(); }, 100);
  
  // Run the benchmark for at least 2000ms.
  double result = measureFor(() { 
    for (var i=0; i<times; i++) 
      fn(); 
    }, runfor);
  
  if (teardown != null)
    teardown();
  
  return result;
}

void report(name, score) {
  print("$name(RunTime): $score us.");
}