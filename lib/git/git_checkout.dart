import 'dart:io';

Future<void> checkoutBranch(String branch, Directory projectLocation) async {
  await _checkout(branch, projectLocation);
}

Future<void> checkoutCommit(String commit, Directory projectLocation) async {
  await _checkout(commit, projectLocation);
}

Future<void> _checkout(String branchOrCommit, Directory projectLocation) async {
  var result = await Process.run(
      'git',
      [
        'checkout',
        branchOrCommit,
      ],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'git checkout returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
}

