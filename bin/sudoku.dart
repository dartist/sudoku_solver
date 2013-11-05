#!/usr/bin/env dart

import 'package:sudoku/sudoku.dart';

void main(List<String> args){
  if (args.length != 1) {
    print("Missing one argument: the board as a single string");
    return;
  }
  display(solve(args[0]));
}