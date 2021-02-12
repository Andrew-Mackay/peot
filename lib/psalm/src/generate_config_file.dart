import 'package:path/path.dart' as p;

import 'dart:io';

Future<File> generateConfigFile(Directory projectLocation) async {
  var result = await Process.run(
      './vendor-bin/errors_over_time/vendor/vimeo/psalm/psalm',
      [
        '--init',
      ],
      workingDirectory: projectLocation.path);
  if (result.exitCode != 0) {
    throw Exception(
        'psalm init returned the following exit code ${result.exitCode} with stderr ${result.stderr}');
  }
  var psalmConfig = File(p.join(projectLocation.path, 'psalm.xml'));
  if (!(await psalmConfig.exists())) {
    throw Exception('Failed to create psalm config file');
  }
  return psalmConfig;
}
