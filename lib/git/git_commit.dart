import 'package:equatable/equatable.dart';

class GitCommit extends Equatable {
  final String hash;
  final DateTime date;

  GitCommit(this.hash, this.date);

  @override
  List<Object> get props => [hash, date];
}

GitCommit commitFromStdOut(String stdOut) {
  var hashAndDate = stdOut.split('"')[1].split(', ');
  return GitCommit(hashAndDate[0], DateTime.parse(hashAndDate[1]));
}