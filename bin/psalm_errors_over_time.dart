import 'package:psalm_errors_over_time/argument_parser.dart';
import 'package:psalm_errors_over_time/csv_writer.dart' as csv_writer;
import 'package:psalm_errors_over_time/psalm_errors_over_time.dart'
    as psalm_errors_over_time;

Future<void> main(List<String> arguments) async {
  // TODO take psalm version?
  // TODO take number of threads
  var args = await parseArguments(arguments);
  var numberOfErrorsOverTime =
      await psalm_errors_over_time.getPsalmErrorsOverTime(
          args.projectLocation,
          args.psalmConfig,
          args.from,
          args.to,
          args.frequency);

  print(numberOfErrorsOverTime);
  // TODO take csv path as arg
  await csv_writer.writePsalmErrorsOverTimeToCSV(numberOfErrorsOverTime);
}
