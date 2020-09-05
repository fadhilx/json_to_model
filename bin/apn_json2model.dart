import 'package:apn_json2model/json_to_model.dart';
import 'package:args/args.dart';

void main(List<String> arguments) {
  var source = '';
  var output = '';
  String onlyFile;

  var argParser = ArgParser();
  argParser.addOption(
    'source',
    abbr: 's',
    defaultsTo: './jsons/',
    callback: (v) => source = v,
    help: 'Specify source directory',
  );
  argParser.addOption(
    'output',
    abbr: 'o',
    defaultsTo: './lib/models/',
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
    source: source,
    output: output,
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
