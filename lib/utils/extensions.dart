import 'package:apn_json2model/core/dart_declaration.dart';
import 'package:apn_json2model/core/model_template.dart';

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

  String between(String start, String end) {
    final startIndex = indexOf(start);
    final endIndex = indexOf(end);
    if (startIndex == -1) return null;
    if (endIndex == -1) return null;
    if (endIndex <= startIndex) return null;

    return substring(startIndex + start.length, endIndex).trim();
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

  String cleaned() {
    return replaceAll('@override', '').trim();
  }
}

extension JsonKeyModels on List<DartDeclaration> {
  String toDeclarationStrings(String className) {
    return where((e) => e.name != null).map((e) => e.toDeclaration(className)).join('\n').trim();
  }

  String toCloneDeclarationStrings() {
    final declarations = where((e) => e.name != null).map((e) => e.toCloneDeclaration()).join('\n').trim();
    return ModelTemplates.indented(declarations, indent: 2);
  }

  String toEqualsDeclarationString() {
    return where((e) => e.name != null).map((e) => e.toEquals()).join(' && ').trim();
  }

  String toHashDeclarationString() {
    return where((e) => e.name != null).map((e) => e.toHash()).join(' ^ ').trim();
  }

  String toImportStrings(String relativePath) {
    var imports = where((element) => element.imports != null && element.imports.isNotEmpty)
        .map((e) => e.getImportStrings(relativePath))
        .where((element) => element != null && element.isNotEmpty)
        .fold<List<String>>(<String>[], (prev, current) => prev..addAll(current));

    var nestedImports = where((element) => element.nestedClasses.isNotEmpty)
        .map((e) => e.nestedClasses.map((jsonModel) => jsonModel.imports).toList())
        .fold<List<String>>(<String>[], (prev, current) => prev..addAll(current));

    imports.addAll(nestedImports);

    return imports.join('\n');
  }

  String getEnums(String className) {
    return where((element) => element.isEnum)
        .map((e) => e.getEnum(className).toTemplateString())
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
}
