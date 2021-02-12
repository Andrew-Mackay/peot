import 'dart:io';

Future<void> install(Directory projectLocation) async {
  var result = await Process.run('composer', ['install'],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'composer install returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
}
