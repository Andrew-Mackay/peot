import 'dart:convert';

class GitCommit {
  final String hash;
  final DateTime date;

  GitCommit(this.hash, this.date);
}

GitCommit parse(String commit) {
  var commitLines = LineSplitter().convert(commit);
  var commitHash = commitLines[0].split(' ')[1];
  var date = DateTime.parse(commitLines[3].split('   ')[1]);
  return GitCommit(commitHash, date);
}