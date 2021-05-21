import 'package:json_to_model/core/dart_declaration.dart';
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
    return '${words[0].toLowerCase()}$leadingWord';
  }

  String toSnakeCase() {
    var words = getWords();
    var leadingWord = words.map((e) => e.toLowerCase()).join('_');
    return '$leadingWord';
  }

  String? between(String start, String end) {
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
    var cleaned = this;
    cleaned = cleaned.replaceAll('@override', '');
    cleaned = cleaned.replaceAll('@ignore', '');
    cleaned = cleaned.replaceAll('?', '');
    cleaned = cleaned.trim();
    return cleaned;
  }
}

extension JsonKeyModels on List<DartDeclaration> {
  String toConstructor(String className) {
    final declarations = where((e) => e.name != null).map((e) => e.toConstructor()).join('\n').trim();
    return ModelTemplates.indented('const $className({\n  $declarations\n});', indent: 1);
  }

  String toDeclarationStrings(String className) {
    return where((e) => e.name != null).map((e) => e.toDeclaration(className)).join('\n').trim();
  }

  String toCopyWith(String className) {
    var constructorDeclarations =
        where((e) => e.name != null).map((e) => e.copyWithConstructorDeclaration()).join(',\n').trim();
    constructorDeclarations = ModelTemplates.indented(constructorDeclarations);

    var bodyDeclarations = where((e) => e.name != null).map((e) => e.copyWithBodyDeclaration()).join(',\n').trim();
    bodyDeclarations = ModelTemplates.indented(bodyDeclarations);

    return ModelTemplates.indented('$className copyWith({\n'
        '$constructorDeclarations\n'
        '}) => $className(\n'
        '$bodyDeclarations,\n'
        ');');
  }

  String toJsonFunctions(String className) {
    var result = '';

    bool find(DartDeclaration e) => e.name != null && e.ignored == false;
    final fromJsonBody = ModelTemplates.indented(where(find).map((e) => e.fromJsonBody()).join(',\n').trim());
    final toJsonBody = ModelTemplates.indented(where(find).map((e) => e.toJsonBody(className)).join(',\n').trim());

    result = 'factory $className.fromJson(Map<String,dynamic> json) => $className(\n$fromJsonBody\n);\n\n';
    result += 'Map<String, dynamic> toJson() => {\n$toJsonBody\n};';

    return ModelTemplates.indented(result);
  }

  String toCloneFunction(String className) {
    final declarations = where((e) => e.name != null).map((e) => e.toCloneDeclaration()).join(',\n').trim();
    final cloneDeclarations = ModelTemplates.indented(declarations, indent: 2);

    return '$className clone() => $className(\n$cloneDeclarations\n  );';
  }

  String toEqualsDeclarationString() {
    return where((e) => e.name != null).map((e) => e.toEquals()).join(' && ').trim();
  }

  String toHashDeclarationString() {
    return where((e) => e.name != null).map((e) => e.toHash()).join(' ^ ').trim();
  }

  String toImportStrings(String? relativePath) {
    var imports = where((element) => element.imports.isNotEmpty)
        .map((e) => e.getImportStrings(relativePath))
        .where((element) => element.isNotEmpty)
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
        .where((element) => element.isNotEmpty)
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
