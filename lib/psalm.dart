import 'dart:io';

import 'package:path/path.dart' as p;

Future<int> run(
    Directory projectLocation, String psalmConfigLocation) async {
  var result = await Process.run(
      './vendor-bin/errors_over_time/vendor/vimeo/psalm/psalm',
      [
        '--config=$psalmConfigLocation',
        '--ignore-baseline',
        '--no-progress',
        '-m',
        '--no-cache'
      ],
      workingDirectory: projectLocation.path);
  if (result.exitCode == 0) {
    return 0;
  } else if (result.exitCode == 1) {
    return _numberOfErrosFromPsalmOutput(result.stdout.toString());
  } else {
    throw Exception(
        'psalm returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
}

Future<File> generateConfigurationFile(Directory projectLocation) async {
    var result = await Process.run(
      './vendor-bin/errors_over_time/vendor/vimeo/psalm/psalm',
      [
        '--init',
      ],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'psalm init returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
  var psalmConfig = File(p.join(projectLocation.path, 'psalm.xml'));
  if (!(await psalmConfig.exists())){
    throw Exception('Failed to create psalm config file');
  }
  return psalmConfig;
}

int _numberOfErrosFromPsalmOutput(String psalmOutput) {
  var match = RegExp(r'[0-9]+ errors found').firstMatch(psalmOutput);
  return int.parse(match.group(0).split(' ')[0]);
}
