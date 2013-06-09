#!/usr/bin/env dart

import 'dart:io';
import '../lib/sudoku.dart';

void main(){
  var args = new Options().arguments;
  if (args.length == 1){
    solveSudoku(args[0]);
  } else if (args.length == 2){
    solveSudoku(args[1], args[0]);
  }
}