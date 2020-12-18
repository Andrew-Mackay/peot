import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:psalm_errors_over_time/git/git_commit.dart';

import 'composer.dart' as composer;
import 'git/git.dart' as git;
import 'git/git_checkout.dart' as git_checkout;
import 'git/git_clone.dart' as git_clone;
import 'psalm.dart' as psalm;

// TODO use isolates?
Future<Map<DateTime, AnalysisResult>> getPsalmErrorsOverTime(String projectLocation,
    File psalmConfig, DateTime from, DateTime to, Duration frequency) async {
  print('Creating temporary directory...');
  var temporaryDirectory =
      await (Directory('.psalm_error_over_time_temp')).create();

  try {
    print('Cloning repository into temporary directory...');
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

    print('Collecting commits...');
    var commits = await git.getCommits(from, to, frequency, projectDirectory);
    print('Found ${commits.length} commits\n');

    return (await _analyseCommits(commits, projectDirectory, psalmConfig));
  } finally {
    print('Deleting temporary directory...');
    await temporaryDirectory.delete(recursive: true);
  }
}

Future<Map<DateTime, AnalysisResult>> _analyseCommits(
  List<GitCommit> commits,
  Directory projectDirectory,
  File psalmConfigLocation,
) async {
  var psalmErrorsOverTime = <DateTime, AnalysisResult>{};
  for (var commit in commits) {
    var result =
        await _analyseCommit(commit, projectDirectory, psalmConfigLocation);
    psalmErrorsOverTime[result.date] = result;

    print('Resetting git branch...');
    await git.resetGitBranch(projectDirectory);
    print('Removing composer bin plugin...');
    await composer.removeComposerBinPlugin(projectDirectory);
    print('Removing broken composer symbolic links...');
    await composer.removeBrokenSymLinks(projectDirectory);
    print('\n');

    // TODO clear cache?
  }
  return psalmErrorsOverTime;
}

Future<AnalysisResult> _analyseCommit(
  GitCommit commit,
  Directory projectDirectory,
  File psalmConfig,
) async {
  print('Checking out commit ${commit.hash} with date ${commit.date.year}-${commit.date.month}-${commit.date.day}...');
  await git_checkout.checkoutCommit(commit.hash, projectDirectory);

  print('Running composer install...');
  await composer.install(projectDirectory);

  print('(Composer) Installing bamarni/composer-bin-plugin...');
  await composer.installComposerBinPlugin(projectDirectory);

  print('(Composer) Installing psalm...');
  await composer.installPsalm(projectDirectory);

  if (psalmConfig == null) {
    psalmConfig = File(p.join(projectDirectory.path, 'psalm.xml'));
    if (await psalmConfig.exists()) {
      print('Using existing psalm.xml');
    } else {
      // TODO test this condition
      print('Generating psalm.xml...');
      psalmConfig = await psalm.generateConfigurationFile(projectDirectory);
    }
  }

  // TODO --diff flag?
  print('Running psalm...');
  var numberOfErrors = await psalm.run(
    projectDirectory,
    psalmConfig.absolute.path,
  );
  print('Number of errors: $numberOfErrors');
  return AnalysisResult(commit.date, numberOfErrors, commit);
}

class AnalysisResult {
  final DateTime date;
  final int numberOfErrors;
  final GitCommit commit;

  AnalysisResult(this.date, this.numberOfErrors, this.commit);
}
