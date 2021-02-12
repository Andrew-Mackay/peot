import 'package:peot/peot.dart' as peot;

Future<void> main(List<String> arguments) async {
  var args = await peot.parseArguments(arguments);

  await peot.checkRequirements();

  var numberOfErrorsOverTime = await peot.getPsalmErrorsOverTime(
    args.projectLocation,
    args.psalmConfig,
    args.from,
    args.to,
    args.frequency,
    args.psalmVersion,
    args.considerAllCommits,
  );

  await peot.writePsalmErrorsOverTimeToCSV(numberOfErrorsOverTime);
  print('Analysis complete! Results have been written to results.csv.');
}
