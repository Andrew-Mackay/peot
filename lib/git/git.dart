import 'dart:convert';
import 'dart:io';

import 'git_commit.dart';

Future<void> resetGitBranch(Directory projectLocation) async {
  var result = await Process.run('git', ['reset', '--hard'],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'git reset --hard returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
}

Future<GitCommit> _getNearestGitCommit(
    DateTime date, List<GitCommit> commits) async {
  for (var commit in commits) {
    if (commit.date == date) {
      return commit;
    }
    if (commit.date.isAfter(date)) {
      return commit;
    }
  }
  throw NoCommitsException();
}

Future<List<GitCommit>> _getAllCommits(DateTime from, DateTime to,
    Directory projectLocation, bool considerAllCommits) async {
  var arguments = <String>['log'];
  if (!considerAllCommits) {
    arguments.addAll(['--merges', '--first-parent']);
  }
  arguments.addAll([
    '--after=${from.month}-${from.day}-${from.year}',
    '--before=${to.month}-${to.day}-${to.year}',
    '--date=short',
    '--pretty="%H, %ad"',
    '--reverse'
  ]);
  var result = await Process.run('git', arguments,
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'git log returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
  if (result.stdout.toString().isEmpty) {
    return [];
  }
  var gitCommits = <GitCommit>[];
  var commitLines = LineSplitter().convert(result.stdout);
  for (var commitLine in commitLines) {
    gitCommits.add(commitFromStdOut(commitLine.toString()));
  }
  return gitCommits;
}

class NoCommitsException implements Exception {}

Future<List<GitCommit>> getCommits(
  DateTime from,
  DateTime to,
  Duration frequency,
  Directory projectLocation,
  bool considerAllCommits,
) async {
  var allCommits = await _getAllCommits(
    from,
    to,
    projectLocation,
    considerAllCommits,
  );
  if (frequency == null) {
    return allCommits;
  }

  // Set to ensure no duplicates
  var commits = <GitCommit>{};
  for (var date = from; date.isBefore(to); date = date.add(frequency)) {
    try {
      var nearestGitCommit = await _getNearestGitCommit(date, allCommits);
      commits.add(nearestGitCommit);
    } on NoCommitsException {
      continue;
    }
  }
  return commits.toList();
}

Future<GitCommit> getFirstCommit(Directory projectLocation) async {
  var result = await Process.run(
      'git',
      [
        'log',
        '--merges',
        '--first-parent',
        '--reverse',
        '--date=short',
        '--pretty="%H, %ad"',
      ],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'git log returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
  if (result.stdout.toString().isEmpty) {
    throw NoCommitsException();
  }
  var firstLine = LineSplitter().convert(result.stdout.toString()).first;
  return commitFromStdOut(firstLine);
}

Future<GitCommit> getLastCommit(Directory projectLocation) async {
  var result = await Process.run(
      'git',
      [
        'log',
        '--merges',
        '--first-parent',
        '-n',
        '1',
        '--date=short',
        '--pretty="%H, %ad"',
      ],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'git log returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
  if (result.stdout.toString().isEmpty) {
    throw NoCommitsException();
  }
  return commitFromStdOut(result.stdout.toString());
}
