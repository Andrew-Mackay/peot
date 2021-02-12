import 'package:peot/argument_parser.dart';
import 'package:peot/csv_writer.dart' as csv_writer;
import 'package:peot/psalm_errors_over_time.dart' as psalm_errors_over_time;
import 'package:peot/requirements_checker.dart';

Future<void> main(List<String> arguments) async {
  var args = await parseArguments(arguments);

  await checkRequirements();

  var numberOfErrorsOverTime =
      await psalm_errors_over_time.getPsalmErrorsOverTime(
    args.projectLocation,
    args.psalmConfig,
    args.from,
    args.to,
    args.frequency,
    args.psalmVersion,
    args.considerAllCommits,
  );

  await csv_writer.writePsalmErrorsOverTimeToCSV(numberOfErrorsOverTime);
  print('Analysis complete! Results have been written to results.csv.');
}
