import 'exceptions/no_commits_exception.dart';
import 'dart:io';
import 'models/commit.dart';
import 'dart:convert';

Future<List<Commit>> getCommits(
  DateTime from,
  DateTime to,
  Duration frequency,
  Directory projectLocation,
  bool considerAllCommits,
) async {
  var allCommits = await getAllCommits(
    from,
    to,
    projectLocation,
    considerAllCommits,
  );
  if (frequency == null) {
    return allCommits;
  }

  // Set to ensure no duplicates
  var commits = <Commit>{};
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

Future<Commit> getFirstCommit(Directory projectLocation) async {
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

Future<Commit> getLastCommit(Directory projectLocation) async {
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

Future<List<Commit>> getAllCommits(DateTime from, DateTime to,
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
  var gitCommits = <Commit>[];
  var commitLines = LineSplitter().convert(result.stdout);
  for (var commitLine in commitLines) {
    gitCommits.add(commitFromStdOut(commitLine.toString()));
  }
  return gitCommits;
}

Future<Commit> _getNearestGitCommit(DateTime date, List<Commit> commits) async {
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
