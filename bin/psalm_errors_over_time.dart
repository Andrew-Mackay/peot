import 'package:psalm_errors_over_time/argument_parser.dart';
import 'package:psalm_errors_over_time/psalm_errors_over_time.dart'
    as psalm_errors_over_time;

void main(List<String> arguments) {
  // TODO take psalm version?
  // TODO take number of threads
  // TODO take name of master/main branch
  var args = parseArguments(arguments);
  var numberOfErrorsOverTime =
      psalm_errors_over_time.getPsalmErrorsOverTime(args);

  print(numberOfErrorsOverTime);
}
