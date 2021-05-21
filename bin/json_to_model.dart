import 'package:json_to_model/json_to_model.dart';
import 'package:args/args.dart';

void main(List<String> arguments) {
  const defaultSource = './jsons/';
  const defaultOutput = './lib/models/';

  String? source = '';
  String? output = '';
  String? onlyFile;

  var argParser = ArgParser();
  argParser.addOption(
    'source',
    abbr: 's',
    defaultsTo: defaultSource,
    callback: (v) => source = v,
    help: 'Specify source directory',
  );
  argParser.addOption(
    'output',
    abbr: 'o',
    defaultsTo: defaultOutput,
    callback: (v) => output = v,
    help: 'Specify models directory',
  );
  argParser.addOption(
    'onlyFile',
    abbr: 'f',
    callback: (v) => onlyFile = v,
    help: 'Specify file to read',
  );
  argParser.parse(arguments);
  var runner = JsonModelRunner(
    source: source ?? defaultSource,
    output: output ?? defaultOutput,
    onlyFile: onlyFile,
  );

  runner.setup();

  print('Start generating');
  if (runner.run()) {
    // cleanup on success
    print('Cleanup');
    runner.cleanup();
  }
}
