import 'package:json_to_model/core/dart_declaration.dart';
import 'package:json_to_model/core/json_model.dart';
import 'package:json_to_model/core/model_template.dart';

extension StringExtension on String {
  String toTitleCase() {
    var firstWord = toCamelCase();
    return '${firstWord.substring(0, 1).toUpperCase()}${firstWord.substring(1)}';
  }

  String toCamelCase() {
    var words = getWords();
    var leadingWords = words.getRange(1, words.length).toList();
    var leadingWord = leadingWords.map((e) => e.toTitleCase()).join('');
    return '${words[0].toLowerCase()}${leadingWord}';
  }

  String toSnakeCase() {
    var words = getWords();
    var leadingWord = words.map((e) => e.toLowerCase()).join('_');
    return '$leadingWord';
  }

  List<String> getWords() {
    var trimmed = trim();
    List<String> value;

    value = trimmed.split(RegExp(r'[_\W]'));
    value = value.where((element) => element.isNotEmpty).toList();
    value = value.expand((e) => e.split(RegExp(r'(?=[A-Z])'))).where((element) => element.isNotEmpty).toList();

    return value;
  }

  bool isTitleCase() {
    if (isEmpty) {
      return false;
    }
    if (trimLeft().isEmpty) {
      return false;
    }
    var firstLetter = trimLeft().substring(0, 1);
    if (double.tryParse(firstLetter) != null) {
      return false;
    }
    return firstLetter.toUpperCase() == substring(0, 1);
  }
}

extension JsonKeyModels on List<DartDeclaration> {
  String toDeclarationStrings() {
    return map((e) => e.toString()).join('\n').trim();
  }

  String toImportStrings() {
    return where((element) => element.imports != null && element.imports.isNotEmpty)
        .map((e) => e.getImportStrings())
        .where((element) => element != null && element.isNotEmpty)
        .join('\n');
  }

  String getEnums() {
    return where((element) => element.isEnum)
        .map((e) => e.getEnum().toTemplateString())
        .where((element) => element != null && element.isNotEmpty)
        .join('\n');
    ;
  }

  String getEnumConverters() {
    return where((element) => element.isEnum)
        .map((e) => e.getEnum().toConverter())
        .where((element) => element != null && element.isNotEmpty)
        .join('\n');
  }

  String getNestedClasses() {
    return where((element) => element.nestedClasses.isNotEmpty)
        .map((e) => e.nestedClasses.map(
              (jsonModel) {
                return ModelTemplates.fromJsonModel(jsonModel, true);
              },
            ).join('\n\n'))
        .join('\n');
  }

  List<String> getImportRaw() {
    var imports_raw = <String>[];
    where((element) => element.imports != null && element.imports.isNotEmpty).forEach((element) {
      imports_raw.addAll(element.imports);
      if (element.nestedClasses.isNotEmpty) {
        imports_raw.addAll(element.nestedClasses.map((e) => e.imports_raw).reduce((value, element) => value..addAll(element)));
      }
    });
    imports_raw = imports_raw.where((element) => element != null && element.isNotEmpty).toList();
    return imports_raw;
  }
}
