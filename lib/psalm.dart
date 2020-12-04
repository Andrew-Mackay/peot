import 'dart:io';

Future<int> run(
    Directory projectLocation, String psalmConfigLocation) async {
  var result = await Process.run(
      './vendor/bin/psalm.phar',
      [
        '--config=$psalmConfigLocation',
        '--ignore-baseline',
        '--no-progress',
        '-m'
        // '--no-cache'
      ],
      workingDirectory: projectLocation.path);
  if (result.exitCode == 0) {
    return 0;
  } else if (result.exitCode == 1) {
    return _numberOfErrosFromPsalmOutput(
        result.stdout.toString()); // TODO parse and return real number
  } else {
    throw Exception(
        'psalm returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
}

int _numberOfErrosFromPsalmOutput(String psalmOutput) {
  // TODO make once instead of every call
  var regExp = RegExp(r'[0-9]+ errors found');
  var match = regExp.firstMatch(psalmOutput);
  return int.parse(match.group(0).split(' ')[0]);
}
