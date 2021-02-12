import 'dart:io';

class Arguments {
  final String projectLocation;
  final File psalmConfig;
  final DateTime from;
  final DateTime to;
  final Duration frequency;
  final String psalmVersion;
  final bool considerAllCommits;

  Arguments(
    this.projectLocation,
    this.psalmConfig,
    this.from,
    this.to,
    this.frequency,
    this.psalmVersion,
    this.considerAllCommits,
  );
}
