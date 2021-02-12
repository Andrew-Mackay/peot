import 'dart:io';

import 'argument_keys.dart' as keys;
import 'package:path/path.dart' as p;
import 'models/arguments.dart';
import 'generate_parser.dart';

Future<Arguments> parseArguments(List<String> arguments) async {
  final parser = generateParser();

  var results = parser.parse(arguments);

  if (results.wasParsed(keys.help)) {
    _printUsage(parser.usage);
    exit(0);
  }

  var from =
      results.wasParsed(keys.from) ? DateTime.parse(results[keys.from]) : null;
  var to = results.wasParsed(keys.to) ? DateTime.parse(results[keys.to]) : null;
  if (from != null && to != null) {
    _validateFromIsBeforeTo(from, to);
  }

  return Arguments(
      results.rest[0],
      results.wasParsed(keys.psalmConfig)
          ? (await _getPsalmConfigLocation(results[keys.psalmConfig]))
          : null,
      from,
      to,
      _frequencyOptionToDuration(results[keys.frequency]),
      results[keys.psalmVersion],
      results.wasParsed(keys.considerAllCommits));
}

void _printUsage(String usage) {
  print('''
peot (psalm errors over time)

Reports the number of static errors in a PHP project over time by running the 
psalm static code analysis tool.

Usage: peot <git-repository> [args]

Results will be written to results.csv.

${usage}
''');
}

Future<File> _getPsalmConfigLocation(String locationFromArgument) async {
  var psalmConfigLocation = File(locationFromArgument);
  var fileExists = await psalmConfigLocation.exists();
  if (!fileExists) {
    throw ArgumentError('${psalmConfigLocation.path} does not exist.');
  }
  var fileExtension = p.extension(psalmConfigLocation.path);
  if (fileExtension != '.xml') {
    throw ArgumentError(
      'Psalm config must be an xml file. Provided file is of type: '
      '$fileExtension.',
    );
  }
  return psalmConfigLocation;
}

void _validateFromIsBeforeTo(DateTime from, DateTime to) {
  if (to.isBefore(from)) {
    throw ArgumentError('Argument `from` must be before `to`.');
  }
}

Duration _frequencyOptionToDuration(String option) {
  switch (option) {
    case 'all':
      return null;
    case 'daily':
      return Duration(days: 1);
    case 'weekly':
      return Duration(days: 7);
    case 'monthly':
      return Duration(days: 31);
    case 'yearly':
    default:
      return Duration(days: 365);
  }
}
