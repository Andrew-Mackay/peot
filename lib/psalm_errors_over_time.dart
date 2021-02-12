import 'dart:io';

import 'package:path/path.dart' as p;

import 'composer/composer.dart' as composer;
import 'git/git.dart' as git;
import 'psalm/psalm.dart' as psalm;

Future<Map<DateTime, AnalysisResult>> getPsalmErrorsOverTime(
  String projectLocation,
  File psalmConfig,
  DateTime from,
  DateTime to,
  Duration frequency,
  String psalmVersion,
  bool considerAllCommits,
) async {
  print('Creating temporary directory...');
  var temporaryDirectory =
      await (Directory('.psalm_error_over_time_temp')).create();

  try {
    print('Cloning repository into temporary directory...');
    await git.clone(projectLocation, temporaryDirectory);

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
    var commits = await git.getCommits(
      from,
      to,
      frequency,
      projectDirectory,
      considerAllCommits,
    );
    print('Found ${commits.length} commits\n');

    return (await _analyseCommits(
        commits, projectDirectory, psalmConfig, psalmVersion));
  } finally {
    print('Deleting temporary directory...');
    await temporaryDirectory.delete(recursive: true);
  }
}

Future<Map<DateTime, AnalysisResult>> _analyseCommits(
  List<git.Commit> commits,
  Directory projectDirectory,
  File psalmConfigLocation,
  String psalmVersion,
) async {
  var psalmErrorsOverTime = <DateTime, AnalysisResult>{};
  for (var commit in commits) {
    var result = await _analyseCommit(
        commit, projectDirectory, psalmConfigLocation, psalmVersion);
    psalmErrorsOverTime[result.date] = result;

    print('Resetting git branch...');
    await git.resetGitBranch(projectDirectory);
    print('Removing composer bin plugin...');
    await composer.removeComposerBinPlugin(projectDirectory);

    // TODO clear cache?
  }
  return psalmErrorsOverTime;
}

Future<AnalysisResult> _analyseCommit(
  git.Commit commit,
  Directory projectDirectory,
  File psalmConfig,
  String psalmVersion,
) async {
  print(
      'Checking out commit ${commit.hash} with date ${commit.date.year}-${commit.date.month}-${commit.date.day}...');
  await git.checkoutCommit(commit.hash, projectDirectory);

  print('Running composer install...');
  await composer.install(projectDirectory);

  print('(Composer) Installing bamarni/composer-bin-plugin...');
  await composer.requireComposerBinPlugin(projectDirectory);

  print('(Composer) Installing psalm...');
  await composer.installPsalm(projectDirectory, psalmVersion);

  if (psalmConfig == null) {
    psalmConfig = File(p.join(projectDirectory.path, 'psalm.xml'));
    if (await psalmConfig.exists()) {
      print('Using existing psalm.xml');
    } else {
      // TODO test this condition
      print('Generating psalm.xml...');
      psalmConfig = await psalm.generateConfigFile(projectDirectory);
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
  final git.Commit commit;

  AnalysisResult(this.date, this.numberOfErrors, this.commit);
}
