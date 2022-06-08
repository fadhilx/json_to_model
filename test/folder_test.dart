import 'dart:io';

import 'package:json_to_model/config/options.dart';
import 'package:json_to_model/index.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('Evaluate run all json test files without error', () {
    final options = Options();
    options.setOption(kSource, './test/jsons/folders');
    options.setOption(kOutput, './test/tmp/models');
    options.setOption(kFactoryOutput, './test/tmp/factories');

    final runner = JsonModelRunner(options);
    runner.run();

    final generated = File('test/tmp/models/subfolder/folders.dart').readAsStringSync();
    expect(generated, isNot(contains("import 'types.dart';")));
    expect(generated, contains("import '../index.dart';"));
  });
}
