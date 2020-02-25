import 'package:json_to_model/models/json_key_map.dart';

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

    value = trimmed.split(' ');
    value = value.expand((e) => e.split('_')).toList();
    value = value.expand((e) => e.split(RegExp(r'(?=[A-Z])'))).toList();

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

extension JsonKeyModels on List<JsonKeyModel> {
  String toDeclarationStrings() {
    return map((e) => e.toDeclarationString()).join('\n').trim();
  }

  String toImportStrings() {
    return where(
            (element) => element.import != null && element.import.isNotEmpty)
        .map((e) => e.toImportString())
        .where((element) => element != null && element.isNotEmpty)
        .join('\n');
  }

  List getImportRaw() {
    var imports_raw = [];
    where((element) => element.import != null).forEach((element) {
      imports_raw.addAll(element.import);
    });
    imports_raw = imports_raw
        .where((element) => element != null && element.isNotEmpty)
        .toList();
    return imports_raw;
  }
}
