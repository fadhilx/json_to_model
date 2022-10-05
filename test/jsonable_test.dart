import 'dart:convert';
import 'dart:io';

import 'package:json_to_model/core/json_model.dart';
import 'package:json_to_model/core/model_template.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('Check if .fromJson is not used by a type that is not jsonable', () {
    final content = json.decode(File('test/jsons/jsonable.json').readAsStringSync()) as Map<String, dynamic>;

    final jsonModel = JsonModel.fromMap(
      'jsonable',
      content,
      relativePath: './',
      packageName: 'core',
      indexPath: 'index.dart',
    );

    final output = modelFromJsonModel(jsonModel);

    expect(output, isNot(contains("num.fromJson")));
    expect(output, isNot(contains("Map<String,dynamic>.fromJson")));
    expect(output, contains("Class.fromJson"));
    expect(output, contains("json['numValue'] as num"));
  });
}
