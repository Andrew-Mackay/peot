import 'dart:io';

Future<void> install(Directory projectLocation) async {
  var result = await Process.run(
      'composer',
      [
        'install',
      ],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'composer install returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
}

Future<void> installPsalm(Directory projectLocation) async {
  var result = await Process.run(
      'composer', ['require', '--dev', 'psalm/phar:4.1.1'],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'composer require psalm returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
  print(result.stdout);
}