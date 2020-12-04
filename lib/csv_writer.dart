import 'dart:io';

import 'package:csv/csv.dart';

Future<void> writePsalmErrorsOverTimeToCSV(
    Map<DateTime, int> psalmErrorsOverTime) async {
  var rows = [
    ['date', 'number_of_errors']
  ];

  psalmErrorsOverTime.forEach((key, value) {
    rows.add(['${key.year}-${key.month}-${key.day}', value.toString()]);
  });

  var csvFormatted = ListToCsvConverter().convert(rows);
  await File('results.csv').writeAsString(csvFormatted);
}
