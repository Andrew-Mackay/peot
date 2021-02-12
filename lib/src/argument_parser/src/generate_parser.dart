import 'package:args/args.dart';
import 'argument_keys.dart' as keys;

const _frequencyOptions = {'all', 'daily', 'weekly', 'monthly', 'yearly'};

ArgParser generateParser() {
  return ArgParser()
    ..addOption(
      keys.from,
      help: 'Date to start the analysis from in format YYYY-MM-DD. Example: '
          '2020-02-24.',
    )
    ..addOption(
      keys.to,
      help: 'Date to run the analysis until in format YYYY-MM-DD. Example: '
          '2020-02-24.',
    )
    ..addOption(
      keys.psalmConfig,
      help: '''
Path to the desired psalm.xml configuration file. If this argument is not
provided, the program will check for an existing psalm.xml file in the project
repository. If no psalm.xml is found in the project repository, a new psalm.xml
file will be initialised using `psalm --init`.
''',
    )
    ..addOption(
      keys.frequency,
      help: 'How frequently to analyse the project.',
      allowed: _frequencyOptions,
      defaultsTo: 'monthly',
    )
    ..addOption(
      keys.psalmVersion,
      help: 'Which psalm version to use.',
      defaultsTo: '4.1.1',
    )
    ..addFlag(
      keys.considerAllCommits,
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
      keys.help,
      abbr: 'h',
      help: 'Print this usage information.',
      negatable: false,
    );
}
