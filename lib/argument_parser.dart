import 'dart:io';

import 'package:args/args.dart';

Arguments parseArguments(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('from')
    ..addOption('to')
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Print this usage information.',
      negatable: false,
    );

  // TODO add optional frequency argument (default monthly)
  // TODO make from/to optional
  // TODO make psalm config optional
  // TODO check if paths exist
  // TODO check date format
  // TODO check to is after from (if provided)

  var results = parser.parse(arguments);

  if (results.wasParsed('help')) {
    print(parser.usage);
    exit(0);
  }

  // project psalm_config from to,
  return Arguments(
    results.rest[0],
    results.rest[1],
    results.wasParsed('from') ? DateTime.parse(results['from']) : null,
    results.wasParsed('to') ? DateTime.parse(results['to']) : null,
  );
}

class Arguments {
  final String projectLocation;
  final String psalmConfigLocation;
  final DateTime from;
  final DateTime to;
  final String mainBranch = 'master';

  final Duration frequency = Duration(days: 30);

  Arguments(
    this.projectLocation,
    this.psalmConfigLocation,
    this.from,
    this.to,
  );
}
