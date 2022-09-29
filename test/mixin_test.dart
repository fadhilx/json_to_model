import 'dart:convert';
import 'dart:io';

import 'package:json_to_model/core/json_model.dart';
import 'package:json_to_model/core/model_template.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('Check if we can add mixins', () {
    final content = json.decode(File('test/jsons/mixin.json').readAsStringSync()) as Map<String, dynamic>;

    final jsonModel = JsonModel.fromMap(
      'add_mixin',
      content,
      relativePath: './',
      packageName: 'core',
      indexPath: 'index.dart',
    );

    final output = modelFromJsonModel(jsonModel);

    print(output);

    expect(output, contains("class AddMixin with HasFormValue {"));
    expect(output, contains("  AddMixin({")); // double space indicates no const
    expect(output, contains("import 'package:project/mixins/has_form_value.dart';"));
  });
}
