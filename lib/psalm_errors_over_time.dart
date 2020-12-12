import 'dart:io';

import 'package:psalm_errors_over_time/git/git_commit.dart';

import 'composer.dart' as composer;
import 'git/git.dart' as git;
import 'git/git_checkout.dart' as git_checkout;
import 'git/git_clone.dart' as git_clone;
import 'psalm.dart' as psalm;

// TODO use isolates?
Future<Map<DateTime, int>> getPsalmErrorsOverTime(
    String projectLocation,
    String psalmConfigLocation,
    DateTime from,
    DateTime to,
    Duration frequency) async {
  print('Creating temporary directory...');
  var temporaryDirectory =
      await (Directory('.psalm_error_over_time_temp')).create();

  try {
    print('Cloning repository...');
    await git_clone.clone(projectLocation, temporaryDirectory);

    var projectDirectory =
        Directory((await temporaryDirectory.list().first).path);

    if (from == null) {
      var firstCommit = await git.getFirstCommit(projectDirectory);
      from = firstCommit.date;
    }

    if (to == null) {
      var lastCommit = await git.getLastCommit(projectDirectory);
      to = lastCommit.date;
    }

    var commits = await git.getCommits(from, to, frequency, projectDirectory);
    print('Found ${commits.length} commits\n');

    return (await _analyseCommits(
        commits, projectDirectory, psalmConfigLocation));
  } finally {
    print('Deleting temporary directory...');
    await temporaryDirectory.delete(recursive: true);
  }
}

Future<Map<DateTime, int>> _analyseCommits(
  List<GitCommit> commits,
  Directory projectDirectory,
  String psalmConfigLocation,
) async {
  var psalmErrorsOverTime = <DateTime, int>{};
  for (var commit in commits) {
    var result =
        await _analyseCommit(commit, projectDirectory, psalmConfigLocation);
    psalmErrorsOverTime[result.date] = result.numberOfErrors;

    await git.resetGitBranch(projectDirectory);
    await composer.removeComposerBinPlugin(projectDirectory);
    await composer.removeBrokenSymLinks(projectDirectory);

    // TODO clear cache?
    print('\n');
  }
  return psalmErrorsOverTime;
}

Future<AnalysisResult> _analyseCommit(
  GitCommit commit,
  Directory projectDirectory,
  String psalmConfigLocation,
) async {
  print('Checking out commit ${commit.hash} with date ${commit.date}');
  await git_checkout.checkoutCommit(commit.hash, projectDirectory);

  print('Running composer install');
  await composer.install(projectDirectory);

  print('Installing composer-bin-plugin');
  await composer.installComposerBinPlugin(projectDirectory);

  print('Installing psalm');
  await composer.installPsalm(projectDirectory);

  // TODO --diff flag?
  print('Running psalm');
  var numberOfErrors = await psalm.run(projectDirectory, psalmConfigLocation);
  print('Number of errors: $numberOfErrors');
  return AnalysisResult(commit.date, numberOfErrors, commit);
}

class AnalysisResult {
  final DateTime date;
  final int numberOfErrors;
  final GitCommit commit;

  AnalysisResult(this.date, this.numberOfErrors, this.commit);
}
