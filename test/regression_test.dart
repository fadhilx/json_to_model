import 'package:json_to_model/config/options.dart';
import 'package:json_to_model/index.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('Evaluate run all json test files without error', () {
    final options = Options();
    options.setOption(kSource, './test/jsons/regression');
    options.setOption(kOutput, './test/tmp/models');
    options.setOption(kFactoryOutput, './test/tmp/factories');

    final runner = JsonModelRunner(options);
    runner.run();
  });
}
