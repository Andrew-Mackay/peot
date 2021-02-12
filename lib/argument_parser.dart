import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'models/arguments.dart';

Future<Arguments> parseArguments(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'from',
      help: 'Date to start the analysis from in format YYYY-MM-DD. Example: '
          '2020-02-24.',
    )
    ..addOption(
      'to',
      help: 'Date to run the analysis until in format YYYY-MM-DD. Example: '
          '2020-02-24.',
    )
    ..addOption(
      'psalm-config',
      help: '''
Path to the desired psalm.xml configuration file. If this argument is not
provided, the program will check for an existing psalm.xml file in the project
repository. If no psalm.xml is found in the project repository, a new psalm.xml
file will be initialised using `psalm --init`.
''',
    )
    ..addOption(
      'frequency',
      help: 'How frequently to analyse the project.',
      allowed: frequencyOptions,
      defaultsTo: 'monthly',
    )
    ..addOption(
      'psalm-version',
      help: 'Which psalm version to use.',
      defaultsTo: '4.1.1',
    )
    ..addFlag(
      'consider-all-commits',
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
      'help',
      abbr: 'h',
      help: 'Print this usage information.',
      negatable: false,
    );

  // TODO check date format
  // TODO check to is after from (if provided)

  var results = parser.parse(arguments);

  if (results.wasParsed('help')) {
    print('''
peot (psalm errors over time)

Reports the number of static errors in a PHP project over time by running the 
psalm static code analysis tool.

Usage: peot <git-repository> [args]

Results will be written to results.csv.

${parser.usage}
''');
    exit(0);
  }

  var psalmConfigLocation;
  if (results.wasParsed('psalm-config')) {
    psalmConfigLocation = File(results['psalm-config']);
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
  }

  return Arguments(
      results.rest[0],
      psalmConfigLocation,
      results.wasParsed('from') ? DateTime.parse(results['from']) : null,
      results.wasParsed('to') ? DateTime.parse(results['to']) : null,
      frequencyOptionToDuration(results['frequency']),
      results['psalm-version'],
      results.wasParsed('consider-all-commits'));
}

const frequencyOptions = {'all', 'daily', 'weekly', 'monthly', 'yearly'};

Duration frequencyOptionToDuration(String option) {
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