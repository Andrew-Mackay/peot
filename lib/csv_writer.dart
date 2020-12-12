import 'dart:io';

import 'package:csv/csv.dart';
import 'psalm_errors_over_time.dart';

Future<void> writePsalmErrorsOverTimeToCSV(
    Map<DateTime, AnalysisResult> psalmErrorsOverTime) async {
  var rows = [
    ['date', 'number_of_errors', 'commit']
  ];

  psalmErrorsOverTime.forEach((key, value) {
    rows.add([
      '${key.year}-${key.month}-${key.day}',
      value.numberOfErrors.toString(),
      value.commit.hash,
    ]);
  });

  var csvFormatted = ListToCsvConverter().convert(rows);
  print('Writing analysis results to results.csv');
  await File('results.csv').writeAsString(csvFormatted);
}
