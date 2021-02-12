import 'dart:io';

Future<void> version() async {
  var result = await Process.run('composer', ['--version']);
  if (result.exitCode != 0) {
    throw ProcessException(
        'composer', ['--version'], result.stderr, result.exitCode);
  }
}
