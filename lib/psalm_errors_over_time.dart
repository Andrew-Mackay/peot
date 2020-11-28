import 'package:psalm_errors_over_time/argument_parser.dart';
import 'dart:io';
import './git_commit_parser.dart' as git_commit_parser;

// TODO put branch back to current state
// TODO copy directory across?
// TODO collect all commits using isolates?
Future<void> getPsalmErrorsOverTime(Arguments arguments) async {
  for (var date = arguments.from;
      date.isBefore(arguments.to);
      date = date.add(arguments.frequency)) {
    print('Date: $date');

    var commit = await getNearestGitCommit(arguments.projectLocation, date);
    print('Got nearest commit ${commit.hash} ${commit.date}');

    await checkoutCommit(commit.hash, arguments.projectLocation);
    print('Checked out commit ${commit.hash}');

    // await installPsalm(arguments.projectLocation);
    // print('installed psalm');

    await composerInstall(arguments.projectLocation);
    print('Ran composer install');


    // TODO --diff flag?
    var numberOfErrors = await runPsalm(arguments.projectLocation, arguments.psalmConfigLocation);
    print('Number of errors: $numberOfErrors');
    // TODO clear cache?
    // copy across config (if provided)
    // run psalm
    // parse results
    // store results
    break; // TODO remove
    print('\n');
  }
  // TODO put branch back to original state
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
  return git_commit_parser.parse(result.stdout);
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
      'composer',
      [
        'require',
        '--dev',
        'vimeo/psalm'
      ],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'composer require psalm returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
  print(result.stdout);
}

Future<int> runPsalm(Directory projectLocation, String psalmConfigLocation) async {
    var result = await Process.run(
      './vendor/bin/psalm',
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
    return numberOfErrosFromPsalmOutput(result.stdout.toString()); // TODO parse and return real number
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