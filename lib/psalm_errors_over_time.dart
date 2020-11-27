import 'package:psalm_errors_over_time/argument_parser.dart';
import 'dart:io';
import './git_commit_parser.dart' as git_commit_parser;

Future<void> getPsalmErrorsOverTime(Arguments arguments) async {
  for (var date = arguments.from;
      date.isBefore(arguments.to);
      date = date.add(arguments.frequency)) {
    print('\n');
    print('Date $date');
    var commit = await getNearestGitCommit(arguments.projectLocation, date);
    print(commit.hash);
    print(commit.date);
  }
}

Future<git_commit_parser.GitCommit> getNearestGitCommit(
    String projectLocation, DateTime date) async {
  var result = await Process.run('git', [
    '--git-dir=$projectLocation/.git',
    'log',
    '--merges',
    '--first-parent',
    '--until=${date.day}-${date.month}-${date.year}',
    '-n',
    '1',
    '--date=short'
  ]);
  if (result.exitCode != 0) {
    throw Exception(
        'git log returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
  return git_commit_parser.parse(result.stdout);
}
