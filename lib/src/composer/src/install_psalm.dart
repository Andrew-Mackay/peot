import 'dart:io';

Future<void> installPsalm(Directory projectLocation, String version) async {
  var result = await Process.run(
      'composer',
      [
        'bin',
        'errors_over_time',
        'require',
        '--dev',
        'vimeo/psalm:$version',
        '-q'
      ],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'composer require psalm returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
}
