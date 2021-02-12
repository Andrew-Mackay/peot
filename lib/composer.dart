import 'dart:io';
import 'package:path/path.dart' as p;

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
  var vendorBinDirectory =
      Directory(p.join(projectLocation.path, 'vendor', 'bin'));
  await for (var entity in vendorBinDirectory.list()) {
    if (entity is Link) {
      try {
        entity.resolveSymbolicLinksSync();
      } on FileSystemException {
        // broken link
        entity.deleteSync();
      }
    }
  }
}

Future<void> removeComposerBinPlugin(Directory projectLocation) async {
  projectLocation.list();
  var vendorBinDir = Directory(p.join(projectLocation.path, 'vendor-bin'));
  await vendorBinDir.delete(recursive: true);
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

Future<void> version() async {
  var result = await Process.run('composer', ['--version']);
  if (result.exitCode != 0) {
    throw ProcessException(
        'composer', ['--version'], result.stderr, result.exitCode);
  }
}
