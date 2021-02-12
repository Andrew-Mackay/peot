import 'dart:io';

import 'package:peot/git/git_version.dart' as git_version;

import 'composer.dart' as composer;

Future<void> checkRequirements() async {
  print('checking requirements...');
  try {
    await git_version.version();
    await composer.version();
    // TODO check or replace find
  } on ProcessException catch (e) {
    throw MissingRequirementException(e);
  }
}

class MissingRequirementException implements Exception {
  final ProcessException processException;

  MissingRequirementException(this.processException);

  @override
  String toString() {
    var args = processException.arguments.join(' ');
    return 'Requirement ${processException.executable} is not satisfied'
        '\nThe requirement was checked by running the command: '
        '${processException.executable} $args'
        '\nError Code: ${processException.errorCode}'
        '\nStderr: ${processException.message}';
  }
}
