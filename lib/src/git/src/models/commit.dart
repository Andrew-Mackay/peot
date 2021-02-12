import 'package:equatable/equatable.dart';

class Commit extends Equatable {
  final String hash;
  final DateTime date;

  Commit(this.hash, this.date);

  @override
  List<Object> get props => [hash, date];
}

Commit commitFromStdOut(String stdOut) {
  var hashAndDate = stdOut.split('"')[1].split(', ');
  return Commit(hashAndDate[0], DateTime.parse(hashAndDate[1]));
}
