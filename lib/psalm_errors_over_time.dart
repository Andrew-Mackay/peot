import 'package:psalm_errors_over_time/argument_parser.dart';
import 'dart:io';
import './git_commit_parser.dart' as git_commit_parser;

// TODO copy directory across?
// TODO use isolates?
Future<Map<DateTime, int>> getPsalmErrorsOverTime(
    Directory projectLocation,
    String psalmConfigLocation,
    DateTime from,
    DateTime to,
    Duration frequency) async {
  var psalmErrorsOverTime = <DateTime, int>{};

  await checkoutMasterBranch(projectLocation);

  var commits = await getCommits(from, to, frequency, projectLocation);
  print('Found ${commits.length} commits\n');

  for (var commit in commits) {
    print('Checking out commit ${commit.hash} with date ${commit.date}');
    await checkoutCommit(commit.hash, projectLocation);

    print('Running composer install');
    await composerInstall(projectLocation);

    print('Installing psalm');
    await installPsalm(projectLocation);

    // TODO --diff flag?
    print('Running psalm');
    var numberOfErrors = await runPsalm(projectLocation, psalmConfigLocation);
    print('Number of errors: $numberOfErrors');

    psalmErrorsOverTime[commit.date] = numberOfErrors;

    await resetGitBranch(projectLocation);

    // TODO clear cache?
    print('\n');
  }

  await checkoutMasterBranch(projectLocation);

  return psalmErrorsOverTime;
}

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

Future<void> composerInstall(Directory projectLocation) async {
  var result = await Process.run(
      'composer',
      [
        'install',
      ],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'composer install returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
}

Future<void> installPsalm(Directory projectLocation) async {
  var result = await Process.run(
      'composer', ['require', '--dev', 'psalm/phar:4.1.1'],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'composer require psalm returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
  print(result.stdout);
}

Future<int> runPsalm(
    Directory projectLocation, String psalmConfigLocation) async {
  var result = await Process.run(
      './vendor/bin/psalm.phar',
      [
        '--config=$psalmConfigLocation',
        '--ignore-baseline',
        '--no-progress',
        '-m'
        // '--no-cache'
      ],
      workingDirectory: projectLocation.path);
  if (result.exitCode == 0) {
    return 0;
  } else if (result.exitCode == 1) {
    return numberOfErrosFromPsalmOutput(
        result.stdout.toString()); // TODO parse and return real number
  } else {
    throw Exception(
        'psalm returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
}

int numberOfErrosFromPsalmOutput(String psalmOutput) {
  // TODO make once instead of every call
  var regExp = RegExp(r'[0-9]+ errors found');
  var match = regExp.firstMatch(psalmOutput);
  return int.parse(match.group(0).split(' ')[0]);
}
