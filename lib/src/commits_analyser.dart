import 'package:path/path.dart' as p;
import 'dart:io';

import 'git/git.dart' as git;
import 'composer/composer.dart' as composer;
import 'psalm/psalm.dart' as psalm;

Future<Map<DateTime, AnalysisResult>> analyseCommits(
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
      print('Generating psalm.xml...');
      psalmConfig = await psalm.generateConfigFile(projectDirectory);
    }
  }

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
