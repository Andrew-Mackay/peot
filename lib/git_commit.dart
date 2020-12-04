import 'dart:convert';

class GitCommit {
  String hash;
  DateTime date;

  GitCommit(this.hash, this.date);

  GitCommit.fromStdOut(String commit) {
    var commitLines = LineSplitter().convert(commit);
    hash = commitLines[0].split(' ')[1];
    date = DateTime.parse(commitLines[3].split('   ')[1]);
  }
}
