library sudoku; 

import "dart:math" as Math;

part 'utils.dart';

List<List<String>> cross(String A, String B) =>
  A.split('').expand((a) => B.split('').map((b) => a+b)).toList();  

const String digits   = '123456789';
const String rows     = 'ABCDEFGHI';
const String cols     = digits;
final List<List<String>> squares = cross(rows, cols);

final List unitlist = cols.split('').map((c) => cross(rows, c)).toList()
  ..addAll( rows.split('').map((r) => cross(r, cols)))
  ..addAll( ['ABC','DEF','GHI'].expand((rs) => ['123','456','789'].map((cs) => cross(rs, cs)) ));

final Map units = dict(squares.map((s) => 
    [s, unitlist.where((u) => u.contains(s)).toList()] ));

final Map peers = dict(squares.map((s) => 
    [s, units[s].expand((u) => u).toSet()..removeAll([s])]));    

/// Parse a Grid
Map parse_grid(String grid){
  var values = dict(squares.map((s) => [s, digits]));
  var gridValues = grid_values(grid);
  for (var s in gridValues.keys){
    var d = gridValues[s];
    if (digits.contains(d) && assign(values, s, d) == null)
      return null;
  }
  return values;
}

Map grid_values(String grid){
  var chars = grid.split('').where((c) => digits.contains(c) || '0.'.contains(c));
  return dict(zip(squares, chars));
}

/// Constraint Propagation
Map assign(Map values, String s, String d){
  var other_values = values[s].replaceAll(d, '');
//  print("$s, $d, $other_values");
  if (all(other_values.split('').map((d2) => eliminate(values, s, d2))))
    return values;
  return null;
}

Map eliminate(Map values, String s, String d){
  if (!values[s].contains(d))
    return values;
  values[s] = values[s].replaceAll(d,'');
  if (values[s].length == 0)
    return null;
  else if (values[s].length == 1){
    var d2 = values[s];
    if (!all(peers[s].map((s2) => eliminate(values, s2, d2))))
      return null;
  }
  for (var u in units[s]){
    var dplaces = u.where((s) => values[s].contains(d)); 
    if (dplaces.length == 0)
      return null;
    else if (dplaces.length == 1)
      if (assign(values, dplaces.elementAt(0), d) == null)
        return null;
  }
  return values;
}

/// Display as 2-D grid
void display(Map values){
  var width = 1 + squares.map((s) => values[s].length).reduce(Math.max);
  var line = repeat('+' + repeat('-', width*3), 3).substring(1);  
  rows.split('').forEach((r){
    print(cols.split('').map((c) => center(values[r+c], width) + ('36'.contains(c) ? '|' : '')).toList()
      .join(''));
    if ('CF'.contains(r))
      print(line);
  });
  print("");  
}

/// Search 
Map solve(String grid) => search(parse_grid(grid));

Map search(Map values){
  if (values == null)
    return null;
  if (squares.every((s) => values[s].length == 1))
    return values;
  var s2 = order(squares.where((s) => values[s].length > 1).toList(), on:(s) => values[s].length).first;
  return some(values[s2].split('').map((d) => search(assign(new Map.from(values), s2, d))));
}
