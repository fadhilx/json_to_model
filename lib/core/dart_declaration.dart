import 'dart:collection';

import 'package:apn_json2model/core/command.dart';
import 'package:apn_json2model/core/decorator.dart';
import 'package:apn_json2model/core/json_key.dart';
import 'package:apn_json2model/core/json_model.dart';
import 'package:apn_json2model/core/model_template.dart';

import '../utils/extensions.dart';

class DartDeclaration {
  final keyComands = Commands.keyComands;
  final valueCommands = Commands.valueCommands;

  JsonKeyMutate jsonKey = JsonKeyMutate();
  List<Decorator> decorators = [];
  List<String> imports = [];
  String? type;
  String? name;
  String? assignment;
  String? extendsClass;
  String? mixinClass;
  List<String> enumValues = [];
  List<JsonModel> nestedClasses = [];
  bool isNullable = false;
  bool override = false;

  bool get isEnum => enumValues.isNotEmpty;

  DartDeclaration({
    this.type,
    this.name,
    this.assignment,
  });

  String toConstructor() {
    final nullable = isNullable ? '' : 'required';
    return ModelTemplates.indented('$nullable this.$name,'.trim());
  }

  String toDeclaration(String className) {
    var declaration = '';

    if (isEnum) {
      declaration += '${getEnum(className).toImport()}\n';
    } else if (override) {
      declaration += '@override ';
    }

    declaration +=
        '${stringifyDecorator(getDecorator())} final $type${isNullable ? '?' : ''} $name${stringifyAssignment(assignment)};'
            .trim();

    return ModelTemplates.indented(declaration);
  }

  String copyWithConstructorDeclaration() {
    return '$type? $name';
  }

  String copyWithBodyDeclaration() {
    return '$name: $name ?? this.$name';
  }

  String toCloneDeclaration() {
    var cleanType = type!;
    var cloneDeclaration;

    //Support for nested lists List<List<type>> (but not deeper than 2 levels)
    var isList = cleanType.startsWith('List') == true;
    var isListInList = false;

    if (isList) {
      cleanType = cleanType.substring(5, cleanType.length - 1);
      isListInList = cleanType.startsWith('List') == true;
      if (isListInList) {
        cleanType = cleanType.substring(5, cleanType.length - 1);
      }
    }

    final importExists = imports.indexWhere((element) => element == cleanType.toSnakeCase()) != -1;
    final nestedClassExists = nestedClasses.indexWhere((element) => element.className == cleanType) != -1;

    if (!isEnum && (importExists || nestedClassExists)) {
      if (isListInList) {
        cloneDeclaration = '$name: $name${isNullable ? '?' : ''}.map((x) => x.map((y) => y.clone()).toList()).toList()';
      } else if (isList) {
        cloneDeclaration = '$name: $name${isNullable ? '?' : ''}.map((e) => e.clone()).toList()';
      } else {
        cloneDeclaration = '$name: $name${isNullable ? '?' : ''}.clone()';
      }
    } else {
      cloneDeclaration = '$name: $name';
    }

    return cloneDeclaration;
  }

  String toEquals() {
    return '$name == other.$name';
  }

  String toHash() {
    return '$name.hashCode';
  }

  String stringifyAssignment(value) {
    return value != null ? ' = $value' : '';
  }

  String stringifyDecorator(deco) {
    return deco != null && deco.isNotEmpty ? '$deco ' : '';
  }

  void setIsNullable(bool isNullable) {
    this.isNullable = isNullable;
  }

  String getDecorator() {
    return decorators.join('\n');
  }

  List<String> getImportStrings(String? relativePath) {
    var prefix = '';

    if (relativePath != null) {
      final matches = RegExp(r'\/').allMatches(relativePath).length;
      List.filled(matches, (i) => i).forEach((_) => prefix = '$prefix../');
    }

    return imports.where((element) => element.isNotEmpty).map((e) => "import '$prefix$e.dart';").toList();
  }

  static String? getTypeFromJsonKey(String theString) {
    var declare = theString.split(')').last.trim().split(' ');
    if (declare.isNotEmpty) return declare.first;
    return null;
  }

  static String? getNameFromJsonKey(String theString) {
    var declare = theString.split(')').last.trim().split(' ');
    if (declare.length > 1) return declare.last;
    return null;
  }

  static String getParameterString(String theString) {
    return theString.split('(')[1].split(')')[0];
  }

  void setName(String name) {
    final cleaned = name.cleaned();

    jsonKey.addKey(name: cleaned, nullable: isNullable);
    this.name = cleaned.toCamelCase();
    decorators.replaceDecorator(Decorator(jsonKey.toString()));
  }

  void setEnumValues(List<String> values) {
    enumValues = values;
    type = _detectType(values.first);
  }

  Enum getEnum(String className) {
    return Enum(className, name!, enumValues);
  }

  void addImport(import) {
    if (import == null && !import.isNotEmpty) {
      return;
    }
    if (import is List) {
      imports.addAll(import.map((e) => e));
    } else if (import != null && import.isNotEmpty) {
      imports.add(import);
    }

    imports = LinkedHashSet<String>.from(imports).toList();
  }

  void setExtends(String extendsClass) {
    this.extendsClass = extendsClass;
  }

  void setMixin(String mixinClass) {
    this.mixinClass = mixinClass;
  }

  void enableOverridden() {
    override = true;
  }

  static DartDeclaration fromKeyValue(key, val) {
    var dartDeclaration = DartDeclaration();
    dartDeclaration = fromCommand(
      Commands.valueCommands,
      dartDeclaration,
      testSubject: val,
      key: key.replaceAll('@override', '').trim(),
      value: val,
    );

    dartDeclaration = fromCommand(
      Commands.keyComands,
      dartDeclaration,
      testSubject: key,
      key: key,
      value: val,
    );

    return dartDeclaration;
  }

  static DartDeclaration fromCommand(
    List<Command> commandList,
    self, {
    required String key,
    dynamic testSubject,
    dynamic value,
  }) {
    var newSelf = self;

    for (var command in commandList) {
      if (testSubject is String) {
        if ((command.prefix != null && testSubject.startsWith(command.prefix!))) {
          final commandPrefixMatch = command.prefix != null &&
              command.command != null &&
              testSubject.startsWith(command.prefix! + command.command!);
          final commandMatch = command.command != null && testSubject.startsWith(command.command!);
          if (commandPrefixMatch || commandMatch) {
            final prefixnull = command.notprefix == null;
            final notprefix = !prefixnull && !testSubject.startsWith(command.notprefix!);

            if (notprefix || prefixnull) {
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
}

class Enum {
  final String className;
  final String name;
  final List<String> values;

  var valueType = 'String';

  String get enumName => '$className${name.toTitleCase()}Enum';

  String get converterName => '_${enumName.toTitleCase()}Converter';

  String get enumValuesMapName => '_${enumName.toCamelCase()}Values';

  Enum(this.className, this.name, this.values) {
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
        return '  \'$e\': $enumName.${valueName(e)},';
      }
    }).join('\n');
  }

  String toTemplateString() {
    return '''
enum $enumName { ${values.map((e) => valueName(e)).toList().join(', ')} }


final $enumValuesMapName = $converterName({
${valuesForTemplate()}
});


class $converterName<$valueType, O> {
  Map<$valueType, O> map;
  Map<O, $valueType> reverseMap;

  $converterName(this.map);

  Map<O, $valueType> get reverse => reverseMap ??= map.map((k, v) => MapEntry(v, k));
}
''';
  }

  String toImport() {
    return '''
@JsonKey(ignore: true)
$enumName 
  get ${enumName.toCamelCase()} => $enumValuesMapName.map[$name];
  set ${enumName.toCamelCase()}($enumName value) => $name = $enumValuesMapName.reverse[value];''';
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
