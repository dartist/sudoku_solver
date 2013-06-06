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

some(Iterable seq) => seq.firstWhere((e) => e != null, orElse:() => null);
all(Iterable seq) => seq.every((e) => e != null);

var rand = new Math.Random();
shuffled(Iterable seq) => order(seq.toList(), on:(a) => rand.nextDouble());

log(s){
  print(s);
  return s;
}
