import 'package:json_to_model/json_to_model.dart';
import 'package:args/args.dart';

void main(List<String> arguments) {
  var source = '';
  var output = '';
  var argParser = ArgParser();
  argParser
    ..addOption(
      'source',
      abbr: 's',
      defaultsTo: './jsons/',
      callback: (v) => source = v,
      help: 'Specify source directory',
    )
    ..addOption(
      'output',
      abbr: 'o',
      defaultsTo: './lib/models/',
      callback: (v) => output = v,
      help: 'Specify models directory',
    )
    ..parse(arguments);
  var runner = JsonModelRunner(source: source, output: output);
  runner..setup();

  if (runner.run()) {
    // cleanup on success
    runner.cleanup();
  }
}
