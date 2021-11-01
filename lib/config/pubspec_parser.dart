import 'dart:io';

import 'package:json_to_model/config/options.dart';
import 'package:json_to_model/config/parser.dart';
import 'package:json_to_model/utils/yaml_utils.dart';

class PubspecParser extends Parser {
  @override
  Future<Options> parse() async {
    final map = await loadConfigFromYamlPath(Directory.current.path, 'pubspec.yaml');
    final options = map['json_to_model'] as Map<String, dynamic>?;

    final result = Options();

    result.setOption(kPackageName, map['name']);

    if (options != null) {
      result.setOption(kSource, options['source'] as String?);
      result.setOption(kOutput, options['output'] as String?);
      result.setOption(kFactoryOutput, options['factory_output'] as String?);
      result.setOption(kCreateFactories, options['create_factories'] as bool?);
    }

    final quiverInPubspec = (map['dependencies'] as Map<String, dynamic>?)?['quiver'] as String?;
    if (quiverInPubspec == null) {
      throw 'Quiver is needed to generate models (To support `null` in copyWith and mocks). Please run `flutter pub add quiver`\n\n';
    }

    if (result.getOption<bool>(kCreateFactories).value == true) {
      final fakerInPubspec = (map['dev_dependencies'] as Map<String, dynamic>?)?['faker'] as String?;
      if (fakerInPubspec == null) {
        throw 'Faker is needed to generate model factories. Please run `flutter pub add faker --dev`\n\n';
      }

      final clockInPubspec = (map['dependencies'] as Map<String, dynamic>?)?['clock'] as String?;
      if (clockInPubspec == null) {
        throw 'Clock is needed to generate model factories. Please run `flutter pub add clock`\n\n';
      }
    }

    return result;
  }
}
