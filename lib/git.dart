import 'dart:io';

import './git_commit_parser.dart' as git_commit_parser;


Future<void> checkoutMasterBranch(Directory projectLocation) async {
  var result = await Process.run('git', ['checkout', 'master'],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'git checkout master returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
}

Future<void> resetGitBranch(Directory projectLocation) async {
  var result = await Process.run('git', ['reset', '--hard'],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'git reset --hard returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
}

Future<git_commit_parser.GitCommit> getNearestGitCommit(
    Directory projectLocation, DateTime date) async {
  var result = await Process.run(
      'git',
      [
        'log',
        '--merges',
        '--first-parent',
        '--until=${date.month}-${date.day}-${date.year}',
        '-n',
        '1',
        '--date=short'
      ],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'git log returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
  if (result.stdout.toString().isEmpty) {
    throw NoCommitsException();
  }
  return git_commit_parser.parse(result.stdout);
}

class NoCommitsException implements Exception {}

Future<List<git_commit_parser.GitCommit>> getCommits(DateTime from, DateTime to,
    Duration frequency, Directory projectLocation) async {
  var commits = <git_commit_parser.GitCommit>[];
  for (var date = from; date.isBefore(to); date = date.add(frequency)) {
    try {
      var nearestGitCommit = await getNearestGitCommit(projectLocation, date);
      commits.add(nearestGitCommit);
    } on NoCommitsException {
      continue;
    }
  }
  return commits;
}

Future<void> gitStatus(Directory projectLocation) async {
  var result = await Process.run(
      'git',
      [
        'status',
      ],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'git checkout returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
  print(result.stdout);
}

Future<void> checkoutCommit(String hash, Directory projectLocation) async {
  var result = await Process.run(
      'git',
      [
        'checkout',
        hash, // TODO need to sanitise?
      ],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'git checkout returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
}