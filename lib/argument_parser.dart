import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

Future<Arguments> parseArguments(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('from')
    ..addOption('to')
    ..addOption(
      'psalm-config',
      help: '''
Path for psalm.xml configuration file.
If not provided will try to use existing psalm.xml in repository.
If no psalm.xml found, will initlise new psalm.xml using `psalm --init`
      ''',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Print this usage information.',
      negatable: false,
    );

  // TODO add optional frequency argument (default monthly)
  // TODO check if paths exist
  // TODO check date format
  // TODO check to is after from (if provided)

  var results = parser.parse(arguments);

  if (results.wasParsed('help')) {
    print(parser.usage);
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
          'Psalm config must be an xml file. Provided file is of type: $fileExtension.');
    }
  }

  // project psalm_config from to,
  return Arguments(
    results.rest[0],
    psalmConfigLocation,
    results.wasParsed('from') ? DateTime.parse(results['from']) : null,
    results.wasParsed('to') ? DateTime.parse(results['to']) : null,
  );
}

class Arguments {
  final String projectLocation;
  final File psalmConfig;
  final DateTime from;
  final DateTime to;

  final Duration frequency = Duration(days: 30);

  Arguments(
    this.projectLocation,
    this.psalmConfig,
    this.from,
    this.to,
  );
}
