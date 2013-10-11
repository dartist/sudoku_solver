#!/usr/bin/env dart

import 'dart:io';
import 'package:sudoku/sudoku.dart';

void main(){
  var args = new Options().arguments;
  if (args.length != 1) {
    print("Missing one argument: the board as a single string");
    return;
  }
  display(solve(args[0]));
}