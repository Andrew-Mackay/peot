import 'package:psalm_errors_over_time/argument_parser.dart';
import 'package:psalm_errors_over_time/psalm_errors_over_time.dart'
    as psalm_errors_over_time;

Future<void> main(List<String> arguments) async {
  // TODO take psalm version?
  // TODO take number of threads
  // TODO take name of master/main branch
  var args = parseArguments(arguments);
  var numberOfErrorsOverTime =
      await psalm_errors_over_time.getPsalmErrorsOverTime(
          args.projectLocation,
          args.psalmConfigLocation,
          args.from,
          args.to,
          args.frequency,
          args.mainBranch);

  print(numberOfErrorsOverTime);
  // TODO output as csv (take csv path)
}
