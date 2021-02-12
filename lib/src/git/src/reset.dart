import 'dart:io';

Future<void> resetGitBranch(Directory projectLocation) async {
  var result = await Process.run('git', ['reset', '--hard'],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'git reset --hard returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
}
