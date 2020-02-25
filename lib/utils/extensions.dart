import 'package:json_to_model/models/dart_declaration.dart';

extension StringExtension on String {
  String toTitleCase() {
    var words = getWords();
    var firstWord = words[0];
    if (firstWord.isNotEmpty) {
      firstWord =
          '${firstWord.substring(0, 1).toUpperCase()}${firstWord.substring(1)}';
    }
    return "${firstWord}${words.getRange(1, words.length).join('')}";
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
    value = value
        .expand((e) => e.split(RegExp(r'(?=[A-Z])')))
        .where((element) => element.isNotEmpty)
        .toList();

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
    return where(
            (element) => element.imports != null && element.imports.isNotEmpty)
        .map((e) => e.getImportStrings())
        .where((element) => element != null && element.isNotEmpty)
        .join('\n');
  }

  List getImportRaw() {
    var imports_raw = [];
    where((element) => element.imports != null && element.imports.isNotEmpty)
        .forEach((element) {
      imports_raw.addAll(element.imports);
    });
    imports_raw = imports_raw
        .where((element) => element != null && element.isNotEmpty)
        .toList();
    return imports_raw;
  }
}
