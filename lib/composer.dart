import 'dart:io';

Future<void> install(Directory projectLocation) async {
  var result = await Process.run('composer', ['install'],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'composer install returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
}

Future<void> installComposerBinPlugin(Directory projectLocation) async {
  var result = await Process.run(
      'composer',
      [
        'require',
        '--dev',
        'bamarni/composer-bin-plugin',
        '--ignore-platform-reqs',
        '-q'
      ],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'composer require composer-bin-plugin returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
}

Future<void> removeBrokenSymLinks(Directory projectLocation) async {
  var result = await Process.run(
      'find', ['./vendor/bin/', '-xtype', 'l', '-delete'],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'removing broken symlinks returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
}

Future<void> removeComposerBinPlugin(Directory projectLocation) async {
  var result = await Process.run('rm', ['-r', 'vendor-bin'],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'removing composer-bin-plugin returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
}

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
