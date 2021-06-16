import 'dart:collection';

import 'package:json_to_model/core/command.dart';
import 'package:json_to_model/core/json_model.dart';
import 'package:json_to_model/utils/faker_maker.dart';

import '../utils/extensions.dart';

class DartDeclaration {
  List<String> imports = [];
  String? type;
  dynamic jsonValue;
  String? originalName;
  String? name;
  String? assignment;
  String? extendsClass;
  String? mixinClass;
  String? fakerDeclaration;
  List<String> enumValues = [];
  List<JsonModel> nestedClasses = [];
  bool isNullable = false;
  bool overrideEnabled = false;
  bool ignored = false;

  bool get isEnum => enumValues.isNotEmpty;
  bool get isDatetime => type == 'DateTime';

  String get isNullableString => isNullable ? '?' : '';

  DartDeclaration();

  String toConstructor() {
    final nullable = isNullable ? '' : 'required';
    return '$nullable this.$name,'.trim().indented();
  }

  String toMockDeclaration(String className) {
    final value = checkNestedTypes(type!, (String cleanedType, bool isList, bool isListInList, bool isModel) {
      final fakerMaker = FakerMaker(this, className, cleanedType, isModel);
      final fakerDeclaration = fakerMaker.generate();

      if (isListInList) {
        return 'List.generate(5, (_) => List.generate(5, (_) => $fakerDeclaration))';
      } else if (isList) {
        return 'List.generate(5, (_) => $fakerDeclaration)';
      } else {
        return fakerDeclaration;
      }
    });

    if (isNullable) {
      return '$name: checkOptional($name, $value)'.trim().indented();
    } else {
      return '$name: $name ?? $value'.trim().indented();
    }
  }

  String toDeclaration(String className) {
    var declaration = '';

    if (isEnum) {
      declaration += '${getEnum(className).toImport()}\n';
    } else if (overrideEnabled) {
      declaration += '@override ';
    }

    declaration += 'final $type$isNullableString $name${stringifyAssignment(assignment)};'.trim();

    return declaration.indented();
  }

  String fromJsonBody() {
    return checkNestedTypes(type!, (String cleanedType, bool isList, bool isListInList, bool isModel) {
      final jsonVar = "json['$originalName']";
      String conversion;
      String modelFromJson([String jsonVar = 'e']) => '$cleanedType.fromJson($jsonVar as Map<String, dynamic>)';

      if (isListInList) {
        conversion =
            '($jsonVar as List? ?? []).map((e) => (e as List? ?? []).map((e) => ${modelFromJson()}).toList()).toList()';
      } else if (isList) {
        if (isModel) {
          conversion = '($jsonVar as List? ?? []).map((e) => ${modelFromJson()}).toList()';
        } else {
          conversion = '($jsonVar as List? ?? []).map((e) => e as $cleanedType).toList()';
        }
      } else if (isModel) {
        conversion = modelFromJson(jsonVar);
      } else if (isDatetime) {
        conversion = 'DateTime.parse($jsonVar as String)';
      } else {
        conversion = '$jsonVar as $type';
      }

      if (isNullable) {
        return '$name: $jsonVar != null ? $conversion : null';
      } else {
        return '$name: $conversion';
      }
    });
  }

  String toJsonBody(String className) {
    return checkNestedTypes(type!, (String cleanedType, bool isList, bool isListInList, bool isModel) {
      String conversion;

      if (isListInList) {
        conversion = '$name$isNullableString.map((e) => e.map((e) => e.toJson()).toList()).toList()';
      } else if (isList) {
        if (isModel) {
          conversion = '$name$isNullableString.map((e) => e.toJson()).toList()';
        } else {
          conversion = '$name$isNullableString.map((e) => e.toString()).toList()';
        }
      } else if (isModel) {
        conversion = '$name$isNullableString.toJson()';
      } else if (isDatetime) {
        conversion = '$name$isNullableString.toIso8601String()';
      } else {
        conversion = name ?? '';
      }

      return "'$originalName': $conversion";
    });
  }

  String copyWithConstructorDeclaration() {
    if (isNullable) {
      return 'Optional<$type?>? $name';
    } else {
      return '$type? $name';
    }
  }

  String copyWithBodyDeclaration() {
    if (isNullable) {
      return '$name: checkOptional($name, this.$name)';
    } else {
      return '$name: $name ?? this.$name';
    }
  }

  String toCloneDeclaration() {
    return checkNestedTypes(type!, (String cleanedType, bool isList, bool isListInList, bool isModel) {
      if (isListInList) {
        return '$name: $name${isNullable ? '?' : ''}.map((x) => x.map((y) => y.clone()).toList()).toList()';
      } else if (isList) {
        if (isModel) {
          return '$name: $name${isNullable ? '?' : ''}.map((e) => e.clone()).toList()';
        } else {
          return '$name: $name${isNullable ? '?' : ''}.toList()';
        }
      } else if (isModel) {
        return '$name: $name${isNullable ? '?' : ''}.clone()';
      } else {
        return '$name: $name';
      }
    });
  }

  String checkNestedTypes(String type, NestedCallbackFunction callback) {
    var cleanType = type;

    final isList = type.startsWith('List') == true;
    var isListInList = false;

    if (isList) {
      cleanType = type.substring(5, type.length - 1);
      isListInList = cleanType.startsWith('List') == true;

      if (isListInList) {
        cleanType = cleanType.substring(5, cleanType.length - 1);
      }
    }

    final importExists = imports.indexWhere((element) => element == cleanType.toSnakeCase()) != -1;
    final nestedClassExists = nestedClasses.indexWhere((element) => element.className == cleanType) != -1;
    final isModel = !isEnum && (importExists || nestedClassExists);

    return callback(cleanType, isList, isListInList, isModel);
  }

  String toEquals() {
    return '$name == other.$name';
  }

  String toHash() {
    return '$name.hashCode';
  }

  String stringifyAssignment(String? value) {
    return value != null ? ' = $value' : '';
  }

  List<String> getImportStrings(String? relativePath) {
    var prefix = '';

    if (relativePath != null) {
      final matches = RegExp(r'\/').allMatches(relativePath).length;
      String addPrefix(_) => prefix = '$prefix../';
      List.filled(matches, (i) => i).forEach(addPrefix);
    }

    return imports.where((element) => element.isNotEmpty).map((e) => "import '$prefix$e.dart';").toList();
  }

  static String? getTypeFromJsonKey(String theString) {
    final declare = theString.split(')').last.trim().split(' ');
    if (declare.isNotEmpty) return declare.first;
    return null;
  }

  static String? getNameFromJsonKey(String theString) {
    final declare = theString.split(')').last.trim().split(' ');
    if (declare.length > 1) return declare.last;
    return null;
  }

  static String getParameterString(String theString) {
    return theString.split('(')[1].split(')')[0];
  }

  void setName(String name) {
    originalName = name;
    this.name = name.cleaned().toCamelCase();
  }

  void setEnumValues(List<String> values) {
    enumValues = values;
    type = _detectType(values.first);
  }

  Enum getEnum(String className) {
    return Enum(className, name!, enumValues, isNullable: isNullable);
  }

  void addImport(dynamic import) {
    if (import == null) {
      return;
    }
    if (import is List && !import.isNotEmpty) {
      imports.addAll(import.map((e) => e as String));
    } else if (import != null && import is String) {
      imports.add(import);
    }

    imports = LinkedHashSet<String>.from(imports).toList();
  }

  void setIgnored() {
    ignored = true;
  }

  void enableOverridden() {
    overrideEnabled = true;
  }

  factory DartDeclaration.fromKeyValue(String key, dynamic val) {
    var dartDeclaration = DartDeclaration();
    dartDeclaration = DartDeclaration.fromCommand(
      valueCommands,
      dartDeclaration,
      testSubject: val,
      key: key.cleaned(),
      value: val,
    );

    dartDeclaration = DartDeclaration.fromCommand(
      keyComands,
      dartDeclaration,
      testSubject: key,
      key: key.cleaned(),
      value: val,
    );

    return dartDeclaration;
  }

  factory DartDeclaration.fromCommand(
    List<Command> commandList,
    DartDeclaration self, {
    required String key,
    dynamic testSubject,
    dynamic value,
  }) {
    var newSelf = self;

    for (final command in commandList) {
      if (testSubject is String) {
        if (command.prefix != null && testSubject.startsWith(command.prefix!)) {
          final commandPrefixMatch = command.prefix != null &&
              command.command != null &&
              testSubject.startsWith(command.prefix! + command.command!);
          final commandMatch = command.command == null || testSubject.startsWith(command.command!);

          if (commandPrefixMatch || commandMatch) {
            final notprefixnull = command.notprefix == null;
            final notprefix = !notprefixnull && !testSubject.startsWith(command.notprefix!);

            if (notprefix || notprefixnull) {
              newSelf = command.callback(self, testSubject, key: key, value: value);
              break;
            }
          }
        }
      }
      if (testSubject.runtimeType == command.type) {
        newSelf = command.callback(self, testSubject, key: key, value: value);
        break;
      }
    }

    return newSelf;
  }

  @override
  String toString() {
    return 'Instance of DartDeclaration --> $type => $name';
  }
}

class Enum {
  final String className;
  final String name;
  final List<String> values;
  final bool isNullable;

  String valueType = 'String';

  String get isNullableString => isNullable ? '?' : '';

  String get enumName => '$className${name.toTitleCase()}Enum';

  String get converterName => '_${enumName.toTitleCase()}Converter';

  String get enumValuesMapName => '_${enumName.toCamelCase()}Values';

  Enum(
    this.className,
    this.name,
    this.values, {
    required this.isNullable,
  }) {
    valueType = _detectType(values.first);
  }

  String valueName(String input) {
    if (input.contains('(')) {
      return input.substring(0, input.indexOf('(')).toTitleCase();
    } else {
      return input.toTitleCase();
    }
  }

  String valuesForTemplate() {
    return values.map((e) {
      final value = e.between('(', ')');
      if (value != null) {
        return '  $value: $enumName.${valueName(e)},';
      } else {
        return "  '$e': $enumName.${valueName(e)},";
      }
    }).join('\n');
  }

  String toTemplateString() {
    return '''
enum $enumName { ${values.map((e) => valueName(e)).toList().join(', ')} }

extension ${enumName}Ex on $enumName{
  $valueType? get value => $enumValuesMapName.reverse[this];
}

final $enumValuesMapName = $converterName({
${valuesForTemplate()}
});


class $converterName<$valueType, O> {
  final Map<$valueType, O> map;
  Map<O, $valueType>? reverseMap;

  $converterName(this.map);

  Map<O, $valueType> get reverse => reverseMap ??= map.map((k, v) => MapEntry(v, k));
}
''';
  }

  String toImport() {
    return '''
$enumName$isNullableString get ${enumName.toCamelCase()} => $enumValuesMapName.map[$name]${isNullable ? '' : '!'};''';
  }
}

String _detectType(String value) {
  final firstValue = value.between('(', ')');
  if (firstValue != null) {
    final isInt = (int.tryParse(firstValue) ?? '') is int;
    if (isInt) {
      return 'int';
    }
  }
  return 'String';
}

typedef NestedCallbackFunction = String Function(String cleanedType, bool isList, bool isListInList, bool isModel);
