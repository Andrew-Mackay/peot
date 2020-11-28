import 'dart:io';

import 'package:args/args.dart';

Arguments parseArguments(List<String> arguments) {
  final parser = ArgParser();

  // TODO add optional frequency argument (default monthly)
  // TODO make from/to optional
  // TODO make psalm config optional
  var args = parser.parse(arguments).rest;
  validateArguments(args);
  // project psalm_config from to,
  return Arguments(
    Directory(args[0]),
    args[1],
    DateTime.parse(args[2]),
    DateTime.parse(args[3]),
  );
}

void validateArguments(List<String> arguments) {
  if (arguments.length != 4) {
    throw ArgumentError(
        'Four arguments required, received ${arguments.length}');
  }
  // TODO check if paths exist
  // TODO check date format
  // TODO check to is after from (if provided)
}

class Arguments {
  final Directory projectLocation;
  final String psalmConfigLocation;
  final DateTime from;
  final DateTime to;

  final Duration frequency = Duration(days: 30);

  Arguments(
    this.projectLocation,
    this.psalmConfigLocation,
    this.from,
    this.to,
  );
}
