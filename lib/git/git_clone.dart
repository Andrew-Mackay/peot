import 'dart:io';

Future<void> clone(String projectLocation, Directory workingDirectory) async {
  var result = await Process.run(
      'git',
      [
        'clone',
        projectLocation,
      ],
      workingDirectory: workingDirectory.path);
  if (result.exitCode != 0) {
    throw Exception(
        'git clone returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
}
