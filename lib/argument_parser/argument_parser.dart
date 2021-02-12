import 'dart:io';

import 'package:path/path.dart' as p;
import '../models/arguments.dart';
import 'package:args/args.dart';

// Agruments
const _from = 'from';
const _to = 'to';
const _psalmConfig = 'psalm-config';
const _frequency = 'frequency';
const _psalmVersion = 'psalm-version';
const _considerAllCommits = 'consider-all-commits';
const _help = 'help';

const _frequencyOptions = {'all', 'daily', 'weekly', 'monthly', 'yearly'};

Future<Arguments> parseArguments(List<String> arguments) async {
  final parser = _generateParser();

  var results = parser.parse(arguments);

  if (results.wasParsed(_help)) {
    _printUsage(parser.usage);
    exit(0);
  }

  var from = results.wasParsed(_from) ? DateTime.parse(results[_from]) : null;
  var to = results.wasParsed(_to) ? DateTime.parse(results[_to]) : null;
  if (from != null && to != null) {
    _validateFromIsBeforeTo(from, to);
  }

  return Arguments(
      results.rest[0],
      results.wasParsed(_psalmConfig)
          ? (await _getPsalmConfigLocation(results[_psalmConfig]))
          : null,
      from,
      to,
      _frequencyOptionToDuration(results[_frequency]),
      results[_psalmVersion],
      results.wasParsed(_considerAllCommits));
}

ArgParser _generateParser() {
  return ArgParser()
    ..addOption(
      _from,
      help: 'Date to start the analysis from in format YYYY-MM-DD. Example: '
          '2020-02-24.',
    )
    ..addOption(
      _to,
      help: 'Date to run the analysis until in format YYYY-MM-DD. Example: '
          '2020-02-24.',
    )
    ..addOption(
      _psalmConfig,
      help: '''
Path to the desired psalm.xml configuration file. If this argument is not
provided, the program will check for an existing psalm.xml file in the project
repository. If no psalm.xml is found in the project repository, a new psalm.xml
file will be initialised using `psalm --init`.
''',
    )
    ..addOption(
      _frequency,
      help: 'How frequently to analyse the project.',
      allowed: _frequencyOptions,
      defaultsTo: 'monthly',
    )
    ..addOption(
      _psalmVersion,
      help: 'Which psalm version to use.',
      defaultsTo: '4.1.1',
    )
    ..addFlag(
      _considerAllCommits,
      abbr: 'a',
      help: '''
By default, analysis is only run on merge commits into the main/master branch.
This is found to give a more accurate insight into the state of the codebase
over time for projects using some form of branching strategy. Use this flag to
override this behaviour and instead consider all commits in the analysis.
''',
      negatable: false,
    )
    ..addFlag(
      _help,
      abbr: 'h',
      help: 'Print this usage information.',
      negatable: false,
    );
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
