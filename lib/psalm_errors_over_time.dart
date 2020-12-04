import 'dart:io';

import 'composer.dart' as composer;
import 'git.dart' as git;
import 'psalm.dart' as psalm;

// TODO copy directory across?
// TODO use isolates?
Future<Map<DateTime, int>> getPsalmErrorsOverTime(
    Directory projectLocation,
    String psalmConfigLocation,
    DateTime from,
    DateTime to,
    Duration frequency) async {
  var psalmErrorsOverTime = <DateTime, int>{};

  await git.checkoutMasterBranch(projectLocation);

  var commits = await git.getCommits(from, to, frequency, projectLocation);
  print('Found ${commits.length} commits\n');

  for (var commit in commits) {
    print('Checking out commit ${commit.hash} with date ${commit.date}');
    await git.checkoutCommit(commit.hash, projectLocation);

    print('Running composer install');
    await composer.install(projectLocation);

    print('Installing psalm');
    await composer.installPsalm(projectLocation);

    // TODO --diff flag?
    print('Running psalm');
    var numberOfErrors = await psalm.run(projectLocation, psalmConfigLocation);
    print('Number of errors: $numberOfErrors');

    psalmErrorsOverTime[commit.date] = numberOfErrors;

    await git.resetGitBranch(projectLocation);

    // TODO clear cache?
    print('\n');
  }

  await git.checkoutMasterBranch(projectLocation);

  return psalmErrorsOverTime;
}