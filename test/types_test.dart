import 'package:json_to_model/core/json_model.dart';
import 'package:json_to_model/core/model_template.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('All supported types', () {
    const content = <String, dynamic>{
      "name": "Mark",
      "age?": 25,
      "city?": "New York",
      "birthdate": "@datetime",
      "timeStamp": "@timestamp"
    };

    final jsonModel = JsonModel.fromMap(
      'types',
      content,
      relativePath: './',
      packageName: 'core',
      indexPath: 'index.dart',
    );

    final output = modelFromJsonModel(jsonModel);

    expect(output, contains('final String name;'));
    expect(output, contains('final int? age;'));
    expect(output, contains('final String? city;'));
    expect(output, contains('final DateTime birthdate;'));
    expect(output, contains('final DateTime timeStamp;'));
  });
}
