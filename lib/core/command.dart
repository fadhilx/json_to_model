import 'package:json_to_model/core/decorator.dart';
import 'package:json_to_model/core/json_key.dart';
import 'package:json_to_model/core/json_model.dart';

import 'dart_declaration.dart';
import '../utils/extensions.dart';

typedef Callback = DartDeclaration Function(DartDeclaration self, String testSubject, {String key, dynamic value});

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
  static Callback defaultCommandCallback = (DartDeclaration self, dynamic testSubject, {String key, dynamic value}) {
    self.setName(key);

    if (value == null) {
      self.type = 'dynamic';
      return self;
    }

    if (value is Map) {
      self.type = key.toTitleCase();
      self.nestedClasses.add(JsonModel.fromMap(key, value));
      return self;
    }

    if (value is List && value.isNotEmpty) {
      final firstListValue = value.first;
      if (firstListValue is List) {
        final nestedFirst = firstListValue.first;
        if (nestedFirst is Map) {
          final key = nestedFirst['\$key'];
          nestedFirst.remove('\$key');
          self.type = 'List<List<$key>>';
          self.nestedClasses.add(JsonModel.fromMap(key, nestedFirst));
        }
      } else if (firstListValue is Map) {
        final key = firstListValue['\$key'];
        firstListValue.remove('\$key');
        self.type = 'List<$key>';
        self.nestedClasses.add(JsonModel.fromMap(key, firstListValue));
      } else {
        final listValueType = firstListValue.runtimeType.toString();
        self.type = 'List<$listValueType>';
      }
      return self;
    }

    var newDeclaration = DartDeclaration.fromCommand(
      valueCommands,
      self,
      testSubject: value,
      key: key,
      value: value,
    );

    self.type = newDeclaration.type ?? value.runtimeType.toString();

    return self;
  };

  static final List<Command> keyComands = [
    Command(
      prefix: '\@',
      command: 'JsonKey',
      callback: (DartDeclaration self, String testSubject, {String key, dynamic value}) {
        var jsonKey = JsonKeyMutate.fromJsonKeyParamaString(testSubject);
        self.jsonKey &= jsonKey;
        var newDeclaration =
            DartDeclaration.fromCommand(valueCommands, self, testSubject: value, key: key, value: value);

        self.decorators.replaceDecorator(Decorator(self.jsonKey.toString()));
        self.type = DartDeclaration.getTypeFromJsonKey(testSubject) ?? newDeclaration.type ?? self.type;
        self.name = DartDeclaration.getNameFromJsonKey(testSubject) ?? newDeclaration.name ?? self.name;
        if (self.name == null) self.setName(value);
        return self;
      },
    ),
    Command(
      prefix: '\@',
      command: 'import',
      callback: (DartDeclaration self, dynamic testSubject, {String key, dynamic value}) {
        self.addImport(value);
        return self;
      },
    ),
    Command(
      prefix: '\@',
      command: 'extends',
      callback: (DartDeclaration self, dynamic testSubject, {String key, dynamic value}) {
        self.setExtends(value);
        return self;
      },
    ),
    Command(
      prefix: '\@',
      command: 'mixin',
      callback: (DartDeclaration self, dynamic testSubject, {String key, dynamic value}) {
        self.setMixin(value);
        return self;
      },
    ),
    Command(
      prefix: '\@',
      command: 'override',
      callback: (DartDeclaration self, dynamic testSubject, {String key, dynamic value}) {
        self.enableOverridden();

        key = key.cleaned();
        print('Override found for key $testSubject -> cleaned $key');
        return defaultCommandCallback(self, key, key: key, value: value);
      },
    ),
    Command(
      prefix: '@',
      command: '_',
      callback: (DartDeclaration self, dynamic testSubject, {String key, dynamic value}) {
        self.type = key.substring(2);
        self.name = value;
        return self;
      },
    ),
    Command(
      prefix: '',
      command: '',
      callback: defaultCommandCallback,
    ),
  ];

  static final List<Command> valueCommands = [
    Command(
      prefix: '\$',
      command: '\[\]',
      callback: (DartDeclaration self, String testSubject, {String key, dynamic value}) {
        var typeName = testSubject.substring(3).split('/').last.split('\\').last.toCamelCase();
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
      callback: (DartDeclaration self, String testSubject, {String key, dynamic value}) {
        self.setName(key);

        var typeName = testSubject.substring(1).split('/').last.split('\\').last.toCamelCase();

        var toImport = testSubject.substring(1);
        self.addImport(toImport);
        var type = typeName.toTitleCase();

        self.type = type;

        return self;
      },
    ),
    Command(
      prefix: '\@datetime',
      command: '',
      notprefix: '\$\[\]',
      callback: (DartDeclaration self, String testSubject, {String key, dynamic value}) {
        self.setName(key);
        self.type = 'DateTime';
        return self;
      },
    ),
    Command(
      prefix: '\@enum',
      command: ':',
      notprefix: '\$\[\]',
      callback: (DartDeclaration self, String testSubject, {String key, dynamic value}) {
        self.setEnumValues((value as String).substring('@enum:'.length).split(','));
        self.setName(key);
        return self;
      },
    ),
    Command(
      type: dynamic,
      callback: (DartDeclaration self, dynamic testSubject, {String key, dynamic value}) {
        self.setName(key);

        if (value == null) {
          self.type = 'dynamic';
          return self;
        }
        if (value is Map) {
          self.type = key.toTitleCase();
          self.nestedClasses.add(JsonModel.fromMap('nested', value));
          return self;
        }
        self.type = value.runtimeType.toString();
        return self;
      },
    ),
  ];
}
