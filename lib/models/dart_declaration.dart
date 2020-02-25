import 'dart:io';
import "dart:collection";
import 'package:json_to_model/models/command.dart';
import 'package:json_to_model/models/decorator.dart';
import 'package:json_to_model/models/json_key.dart';
import 'package:json_to_model/models/model_template.dart';
import '../utils/extensions.dart';

class DartDeclaration {
  JsonKeyMutate jsonKey;
  List<Decorator> decorators = [];
  List<String> imports = [];
  String type;
  String name;
  String assignment;
  List<Command> keyComands = [];
  List<Command> valueCommands = [];
  DartDeclaration({
    this.jsonKey,
    this.type,
    this.name,
    this.assignment,
  }) {
    keyComands = Commands.keyComands;
    valueCommands = Commands.valueCommands;
    jsonKey = JsonKeyMutate();
  }

  @override
  String toString() {
    return ModelTemplates.indented(
        '${stringifyDecorator(getDecorator())}$type $name${strigifyAssignment(assignment)};'
            .trim());
  }

  void addImport(import) {
    if (import == null && !import.isNotEmpty) {
      return;
    }
    if (import is List) {
      imports.addAll(import.map((e) => e));
    }
    if (import != null && import.isNotEmpty) imports.add(import);

    imports = LinkedHashSet<String>.from(imports).toList();
  }

  String strigifyAssignment(value) {
    return value != null ? ' = $value' : '';
  }

  String stringifyDecorator(deco) {
    return deco != null && deco.isNotEmpty ? '$deco ' : '';
  }

  String getDecorator() {
    return decorators?.join('\n');
  }

  String getImportStrings() {
    return imports
        .where((element) => element != null && element.isNotEmpty)
        .map((e) => "import '$e.dart';")
        .join('\n');
  }

  static String getTypeFromJsonKey(String theString) {
    var declare = theString.split(')').last.trim().split(' ');
    if (declare.isNotEmpty) return declare.first;
    return null;
  }

  static String getNameFromJsonKey(String theString) {
    var declare = theString.split(')').last.trim().split(' ');
    if (declare.length > 1) return declare.last;
    return null;
  }

  static String getParameterString(String theString) {
    return theString.split('(')[1].split(')')[0];
  }

  void setName(String newName) {
    name = newName;
    if (newName.isTitleCase() || newName.contains(RegExp(r'[_\W]'))) {
      jsonKey.addKey(name: newName);
      name = newName.toCamelCase();
      decorators.replaceDecorator(Decorator(jsonKey.toString()));
    }
  }

  static DartDeclaration fromKeyValue(key, val) {
    var dartDeclaration = DartDeclaration();
    dartDeclaration = fromCommand(Commands.valueCommands, dartDeclaration,
        testSubject: val, key: key, value: val);

    dartDeclaration = fromCommand(Commands.keyComands, dartDeclaration,
        testSubject: key, key: key, value: val);
    if (dartDeclaration.type == null || dartDeclaration.name == null) {
      exit(0);
    }
    return dartDeclaration;
  }

  static DartDeclaration fromCommand(List<Command> commandList, self,
      {dynamic testSubject, String key, dynamic value}) {
    var newSelf = self;
    for (var command in commandList) {
      if (testSubject is String) {
        if ((command.prefix != null &&
            testSubject.startsWith(command.prefix))) {
          if ((command.prefix != null &&
                  command.command != null &&
                  testSubject.startsWith(command.prefix + command.command)) ||
              (command.command != null &&
                  testSubject.startsWith(command.command))) {
            if (command.notprefix != null &&
                    !testSubject.startsWith(command.notprefix) ||
                command.notprefix == null) {
              newSelf =
                  command.callback(self, testSubject, key: key, value: value);
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
