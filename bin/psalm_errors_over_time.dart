import 'package:psalm_errors_over_time/argument_parser.dart';
import 'package:psalm_errors_over_time/psalm_errors_over_time.dart' as psalm_errors_over_time;

void main(List<String> arguments) {
  var args = parseArguments(arguments);
  psalm_errors_over_time.getPsalmErrorsOverTime(args);
}
