import 'dart:io';

import 'git/git.dart' as git;
import 'commits_analyser.dart';

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
      var firstCommit = await git.getFirstCommit(
        projectDirectory,
        considerAllCommits,
      );
      from = firstCommit.date;
    }

    if (to == null) {
      var lastCommit = await git.getLastCommit(
        projectDirectory,
        considerAllCommits,
      );
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

    return (await analyseCommits(
        commits, projectDirectory, psalmConfig, psalmVersion));
  } finally {
    print('Deleting temporary directory...');
    await temporaryDirectory.delete(recursive: true);
  }
}
