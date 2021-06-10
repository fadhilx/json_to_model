import 'package:json_to_model/config/args_parser.dart';
import 'package:json_to_model/config/pubspec_parser.dart';
import 'package:json_to_model/json_to_model.dart';

Future<void> main(List<String> arguments) async {
  final argumentOptions = await ArgumentParser(arguments).parse();
  final pubspecOptions = await PubspecParser().parse();

  final options = argumentOptions + pubspecOptions;

  JsonModelRunner(options).run();
}
