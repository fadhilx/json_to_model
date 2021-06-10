import 'package:json_to_model/config/options.dart';

abstract class Parser {
  Future<Options> parse();
}
