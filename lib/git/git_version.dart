import 'dart:io';

Future<void> version() async {
  var result = await Process.run('git', ['--version']);
  if (result.exitCode != 0) {
    throw ProcessException(
        'git', ['--version'], result.stderr, result.exitCode);
  }
}
