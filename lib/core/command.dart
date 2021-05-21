import 'package:json_to_model/core/json_model.dart';

import 'dart_declaration.dart';
import '../utils/extensions.dart';

typedef Callback = DartDeclaration Function(DartDeclaration self, String testSubject, {required String key, dynamic value});

class Command {
  final Type? type;
  final String? notprefix;
  final String? prefix;
  final String? command;
  final Callback callback;

  Command({
    this.type,
    this.prefix,
    this.notprefix,
    this.command,
    required this.callback,
  });

  @override
  String toString() {
    return 'Command $type => $prefix $command && !$notprefix';
  }
}

class Commands {
  static Callback defaultCommandCallback = (DartDeclaration self, dynamic testSubject, {required String key, dynamic value}) {
    self.isNullable = testSubject.endsWith('?');

    self.setName(key);

    if (value == null) {
      self.type = 'dynamic';
      return self;
    }

    if (value is Map) {
      self.type = key.toTitleCase();
      self.nestedClasses.add(JsonModel.fromMap(key, value as Map<String, dynamic>));
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
          self.nestedClasses.add(JsonModel.fromMap(key, nestedFirst as Map<String, dynamic>));
        }
      } else if (firstListValue is Map) {
        final key = firstListValue['\$key'];
        firstListValue.remove('\$key');
        self.type = 'List<$key>';
        self.nestedClasses.add(JsonModel.fromMap(key, firstListValue as Map<String, dynamic>));
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
      command: 'import',
      callback: (DartDeclaration self, dynamic testSubject, {required String key, dynamic value}) {
        self.addImport(value);
        return self;
      },
    ),
    Command(
      prefix: '\@',
      command: 'extends',
      callback: (DartDeclaration self, dynamic testSubject, {required String key, dynamic value}) {
        self.setExtends(value);
        return self;
      },
    ),
    Command(
      prefix: '\@',
      command: 'mixin',
      callback: (DartDeclaration self, dynamic testSubject, {required String key, dynamic value}) {
        self.setMixin(value);
        return self;
      },
    ),
    Command(
      prefix: '\@',
      command: 'ignore',
      callback: (DartDeclaration self, dynamic testSubject, {required String key, dynamic value}) {
        self.setIgnored();
        return defaultCommandCallback(self, testSubject, key: key, value: value);
      },
    ),
     Command(
      prefix: '\@',
      command: 'override',
      callback: (DartDeclaration self, dynamic testSubject, {required String key, dynamic value}) {
        self.enableOverridden();
        return defaultCommandCallback(self, testSubject, key: key, value: value);
      },
    ),
    Command(
      prefix: '@',
      command: '_',
      callback: (DartDeclaration self, dynamic testSubject, {required String key, dynamic value}) {
        self.type = key.substring(2);
        self.name = value;
        return self;
      },
    ),
    Command(
      type: String,
      callback: defaultCommandCallback,
    ),
  ];

  static final List<Command> valueCommands = [
    Command(
      prefix: '\$',
      command: '\[\]',
      callback: (DartDeclaration self, String testSubject, {required String key, dynamic value}) {
        var typeName = testSubject.substring(3).split('/').last.split('\\').last.toCamelCase();
        var toImport = testSubject.substring(3);
        self.addImport(toImport);
        self.type = 'List<${typeName.toTitleCase()}>';
        return self;
      },
    ),
    Command(
      prefix: '\$',
      notprefix: '\$\[\]',
      callback: (DartDeclaration self, String testSubject, {required String key, dynamic value}) {
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
      prefix: '\@',
      command: 'datetime',
      notprefix: '\$\[\]',
      callback: (DartDeclaration self, String testSubject, {required String key, dynamic value}) {
        self.setName(key);
        self.type = 'DateTime';
        return self;
      },
    ),
    Command(
      prefix: '\@',
      command: 'enum',
      notprefix: '\$\[\]',
      callback: (DartDeclaration self, String testSubject, {required String key, dynamic value}) {
        self.setEnumValues((value as String).substring('@enum:'.length).split(','));
        self.setName(key);
        return self;
      },
    ),
    Command(
      type: dynamic,
      callback: (DartDeclaration self, dynamic testSubject, {required String key, dynamic value}) {
        self.setName(key);

        if (value == null) {
          self.type = 'dynamic';
          return self;
        }
        if (value is Map) {
          self.type = key.toTitleCase();
          self.nestedClasses.add(JsonModel.fromMap('nested', value as Map<String, dynamic>));
          return self;
        }
        self.type = value.runtimeType.toString();
        return self;
      },
    ),
  ];
}
