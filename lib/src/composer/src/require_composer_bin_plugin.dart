import 'dart:io';

Future<void> requireComposerBinPlugin(Directory projectLocation) async {
  var result = await Process.run(
      'composer',
      [
        'require',
        '--dev',
        'bamarni/composer-bin-plugin',
        '--ignore-platform-reqs',
        '--no-scripts',
        '-q'
      ],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'composer require composer-bin-plugin returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
}
