import 'package:json_to_model/models/decorator.dart';
import 'package:json_to_model/models/json_key.dart';

import 'dart_declaration.dart';
import '../utils/extensions.dart';

typedef Callback = DartDeclaration Function(
    DartDeclaration self, String testSubject,
    {String key, dynamic value});

class Command {
  Type type = String;
  String notprefix;
  String prefix;
  String command;
  Callback callback;
  Command({
    this.type,
    this.prefix,
    this.notprefix,
    this.command,
    this.callback,
  });
}

class Commands {
  static final List<Command> keyComands = [
    Command(
      prefix: '\@',
      command: 'JsonKey',
      callback: (DartDeclaration self, String testSubject,
          {String key, dynamic value}) {
        var jsonKey = JsonKeyMutate.fromJsonKeyParamaString(testSubject);
        self.jsonKey &= jsonKey;
        var newDeclaration = DartDeclaration.fromCommand(valueCommands, self,
            testSubject: value, key: key, value: value);

        self.decorators.replaceDecorator(Decorator(self.jsonKey.toString()));
        self.type = DartDeclaration.getTypeFromJsonKey(testSubject) ??
            newDeclaration.type ??
            self.type;
        self.name = DartDeclaration.getNameFromJsonKey(testSubject) ??
            newDeclaration.name ??
            self.name;
        if (self.name == null) self.setName(value);
        return self;
      },
    ),
    Command(
      prefix: '\@',
      command: 'import',
      callback: (DartDeclaration self, dynamic testSubject,
          {String key, dynamic value}) {
        self.addImport(value);
        return self;
      },
    ),
    Command(
      prefix: '@',
      command: '_',
      callback: (DartDeclaration self, dynamic testSubject,
          {String key, dynamic value}) {
        self.type = key.substring(1);
        self.name = value;
        return self;
      },
    ),
    Command(
      prefix: '',
      command: '',
      callback: (DartDeclaration self, dynamic testSubject,
          {String key, dynamic value}) {
        self.setName(key);
        if (value == null) {
          self.type = 'dynamic';
          return self;
        }
        if (value is Map) {
          self.type = 'Map<String, dynamic>';
          return self;
        }
        var newDeclaration = DartDeclaration.fromCommand(valueCommands, self,
            testSubject: value, key: key, value: value);
        self.type = newDeclaration.type ?? value.runtimeType.toString();
        return self;
      },
    ),
  ];
  static final List<Command> valueCommands = [
    Command(
      prefix: '\$',
      command: '\[\]',
      callback: (DartDeclaration self, String testSubject,
          {String key, dynamic value}) {
        var typeName = testSubject
            .substring(3)
            .split('/')
            .last
            .split('\\')
            .last
            .toCamelCase();
        var toImport = testSubject.substring(3);
        self.addImport(toImport);
        self.type = 'List<${typeName.toTitleCase()}>';
        return self;
      },
    ),
    Command(
      prefix: '\$',
      command: '',
      notprefix: '\$\[\]',
      callback: (DartDeclaration self, String testSubject,
          {String key, dynamic value}) {
        self.setName(key);

        var typeName = testSubject
            .substring(1)
            .split('/')
            .last
            .split('\\')
            .last
            .toCamelCase();

        var toImport = testSubject.substring(1);
        self.addImport(toImport);
        var type = typeName.toTitleCase();

        self.type = type;

        return self;
      },
    ),
    Command(
      type: dynamic,
      callback: (DartDeclaration self, dynamic testSubject,
          {String key, dynamic value}) {
        self.setName(key);

        if (value == null) {
          self.type = 'dynamic';
          return self;
        }
        if (value is Map) {
          self.type = 'Map<String, dynamic>';
          return self;
        }
        self.type = value.runtimeType.toString();
        return self;
      },
    ),
  ];
}
