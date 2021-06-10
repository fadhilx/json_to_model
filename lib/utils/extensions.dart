import 'package:json_to_model/core/dart_declaration.dart';
import 'package:json_to_model/core/factory_template.dart';
import 'package:json_to_model/core/model_template.dart';

extension StringExtension on String {
  String toTitleCase() {
    final firstWord = toCamelCase();
    return '${firstWord.substring(0, 1).toUpperCase()}${firstWord.substring(1)}';
  }

  String toCamelCase() {
    final words = getWords();
    final leadingWords = words.getRange(1, words.length).toList();
    final leadingWord = leadingWords.map((e) => e.toTitleCase()).join();
    return '${words[0].toLowerCase()}$leadingWord';
  }

  String toSnakeCase() {
    final words = getWords();
    return words.map((e) => e.toLowerCase()).join('_');
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
    List<String> value;

    value = trim().split(RegExp(r'[_\W]'));
    value = value.where((element) => element.isNotEmpty).toList();
    value = value.expand((e) => e.split(RegExp('(?=[A-Z])'))).where((element) => element.isNotEmpty).toList();

    return value;
  }

  bool isTitleCase() {
    if (isEmpty) {
      return false;
    }
    if (trimLeft().isEmpty) {
      return false;
    }
    final firstLetter = trimLeft().substring(0, 1);
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

  String indented({int indent = 1}) {
    final indentString = List.generate(indent, (index) => '  ').join();
    final content = replaceAll('\n', '\n$indentString');

    return '$indentString$content';
  }
}

extension JsonKeyModels on List<DartDeclaration> {
  String toConstructor(String className) {
    final declarations = where((e) => e.name != null).map((e) => e.toConstructor()).join('\n').trim();
    return 'const $className({\n  $declarations\n});'.indented();
  }

  String toDeclarationStrings(String className) {
    return where((e) => e.name != null).map((e) => e.toDeclaration(className)).join('\n').trim();
  }

  String toMockDeclarationStrings(String className) {
    final declaration = where((e) => e.name != null).map((e) => e.toMockDeclaration(className)).join(',\n').trim();
    final constructorDeclarations = toConstructorDeclarations();
    return '''

$className mock$className({
$constructorDeclarations,
}) => $className(
  $declaration,
);
''';
  }

  String toConstructorDeclarations() {
    return where((e) => e.name != null)
        .map(
          (e) => e.copyWithConstructorDeclaration(),
        )
        .join(',\n')
        .trim()
        .indented();
  }

  String toCopyWith(String className) {
    final constructorDeclarations = toConstructorDeclarations();
    final bodyDeclarations = where((e) => e.name != null)
        .map(
          (e) => e.copyWithBodyDeclaration(),
        )
        .join(',\n')
        .trim()
        .indented();

    return '$className copyWith({\n'
            '$constructorDeclarations\n'
            '}) => $className(\n'
            '$bodyDeclarations,\n'
            ');'
        .indented();
  }

  String toJsonFunctions(String className) {
    var result = '';

    bool find(DartDeclaration e) => e.name != null && e.ignored == false;
    final fromJsonBody = where(find).map((e) => e.fromJsonBody()).join(',\n').trim().indented();
    final toJsonBody = where(find).map((e) => e.toJsonBody(className)).join(',\n').trim().indented();

    result = 'factory $className.fromJson(Map<String,dynamic> json) => $className(\n$fromJsonBody\n);\n\n';
    result += 'Map<String, dynamic> toJson() => {\n$toJsonBody\n};';

    return result.indented();
  }

  String toCloneFunction(String className) {
    final declarations = where((e) => e.name != null).map((e) => e.toCloneDeclaration()).join(',\n').trim();
    final cloneDeclarations = declarations.indented(indent: 2);

    return '$className clone() => $className(\n$cloneDeclarations\n  );';
  }

  String toEqualsDeclarationString() {
    return where((e) => e.name != null).map((e) => e.toEquals()).join(' && ').trim();
  }

  String toHashDeclarationString() {
    return where((e) => e.name != null).map((e) => e.toHash()).join(' ^ ').trim();
  }

  String toImportStrings(String? relativePath) {
    final imports = where((element) => element.imports.isNotEmpty)
        .map((e) => e.getImportStrings(relativePath))
        .where((element) => element.isNotEmpty)
        .fold<List<String>>(<String>[], (prev, current) => prev..addAll(current));

    final nestedImports = where((element) => element.nestedClasses.isNotEmpty)
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

  String getNestedModelClasses() {
    return where((element) => element.nestedClasses.isNotEmpty)
        .map((e) => e.nestedClasses.map(
              (jsonModel) {
                return modelFromJsonModel(jsonModel, isNested: true);
              },
            ).join('\n\n'))
        .join('\n');
  }

  String getNestedFactoryClasses() {
    return where((element) => element.nestedClasses.isNotEmpty)
        .map((e) => e.nestedClasses.map(
              (jsonModel) {
                return factoryFromJsonModel(
                  jsonModel,
                  isNested: true,
                );
              },
            ).join('\n\n'))
        .join('\n');
  }
}

extension ListStringEx on List<String> {
  bool hasStartsWith(String needle) {
    return where((element) => element.startsWith(needle)).isNotEmpty;
  }

  bool hasStartsWithOr(List<String> needles) {
    bool needleLoop(String option) {
      for (final needle in needles) {
        if (option.startsWith(needle)) return true;
      }

      return false;
    }

    return where(needleLoop).isNotEmpty;
  }
}
