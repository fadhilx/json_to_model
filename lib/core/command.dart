import 'package:json_to_model/core/json_model.dart';

import '../utils/extensions.dart';
import 'dart_declaration.dart';

typedef Callback = DartDeclaration Function(
    DartDeclaration self, dynamic testSubject,
    {required String key, dynamic value});

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

DartDeclaration defaultCommandCallback(
    DartDeclaration self, dynamic testSubject,
    {required String key, dynamic value}) {
  self.isNullable = testSubject.toString().endsWith('?');

  self.setName(key);

  if (value == null) {
    self.type = 'dynamic';
    return self;
  }

  if (value is Map) {
    self.type = key.toTitleCase();
    self.nestedClasses
        .add(JsonModel.fromMap(key, value as Map<String, dynamic>));
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
        self.nestedClasses.add(JsonModel.fromMap(
            key as String, nestedFirst as Map<String, dynamic>));
      }
    } else if (firstListValue is Map) {
      final key = firstListValue['\$key'];
      firstListValue.remove('\$key');
      self.type = 'List<$key>';
      self.nestedClasses.add(JsonModel.fromMap(
          key as String, firstListValue as Map<String, dynamic>));
    } else {
      final listValueType = firstListValue.runtimeType.toString();
      self.type = 'List<$listValueType>';
    }
    return self;
  }

  var v = value;
  if (value is String && value.contains('|')) {
    self.fakerDeclaration = value.split('|')[1];
    v = value.split('|')[0];

    bool parsed = false;
    try {
      v = int.parse(v.toString());
      parsed = true;
    } on FormatException catch (_) {}

    if (!parsed && v == 'true') {
      v = true;
      parsed = true;
    }
    if (!parsed && v == 'false') {
      v = false;
      parsed = true;
    }
  }

  final newDeclaration = DartDeclaration.fromCommand(
    valueCommands,
    self,
    testSubject: v,
    key: key,
    value: v,
  );

  self.jsonValue = v;
  self.type = newDeclaration.type ?? v.runtimeType.toString();

  return self;
}

final List<Command> keyComands = [
  Command(
    prefix: '@',
    command: 'import',
    callback: (DartDeclaration self, dynamic testSubject,
        {required String key, dynamic value}) {
      self.addImport(value);
      return self;
    },
  ),
  Command(
    prefix: '@',
    command: 'extends',
    callback: (DartDeclaration self, dynamic testSubject,
        {required String key, dynamic value}) {
      self.extendsClass = value as String;
      return self;
    },
  ),
  Command(
    prefix: '@',
    command: 'mixin',
    callback: (DartDeclaration self, dynamic testSubject,
        {required String key, dynamic value}) {
      self.mixinClass = value as String;
      return self;
    },
  ),
  Command(
    prefix: '@',
    command: 'ignore',
    callback: (DartDeclaration self, dynamic testSubject,
        {required String key, dynamic value}) {
      self.setIgnored();
      return defaultCommandCallback(self, testSubject, key: key, value: value);
    },
  ),
  Command(
    prefix: '@',
    command: 'override',
    callback: (DartDeclaration self, dynamic testSubject,
        {required String key, dynamic value}) {
      self.enableOverridden();
      return defaultCommandCallback(self, testSubject, key: key, value: value);
    },
  ),
  Command(
    prefix: '@',
    command: '_',
    callback: (DartDeclaration self, dynamic testSubject,
        {required String key, dynamic value}) {
      self.type = key.substring(2);
      self.name = value as String;
      return self;
    },
  ),
  Command(
    type: String,
    callback: defaultCommandCallback,
  ),
];

final List<Command> valueCommands = [
  Command(
    prefix: '#',
    callback: (DartDeclaration self, dynamic testSubject,
        {required String key, dynamic value}) {
      final subject = testSubject as String;
      self.type = subject.substring(1);
      return self;
    },
  ),
  Command(
    prefix: '\$',
    command: '[]',
    callback: (DartDeclaration self, dynamic testSubject,
        {required String key, dynamic value}) {
      final subject = testSubject as String;

      final typeName =
          subject.substring(3).split('/').last.split('\\').last.toCamelCase();
      final toImport = subject.substring(3);
      self.addImport(toImport);
      self.type = 'List<${typeName.toTitleCase()}>';
      return self;
    },
  ),
  Command(
    prefix: '\$',
    notprefix: '\$[]',
    callback: (DartDeclaration self, dynamic testSubject,
        {required String key, dynamic value}) {
      final subject = testSubject as String;
      self.setName(key);
      self.addImport(subject.substring(1));

      final typeName =
          subject.substring(1).split('/').last.split('\\').last.toCamelCase();
      final type = typeName.toTitleCase();

      self.type = type;

      return self;
    },
  ),
  Command(
    prefix: '@',
    command: 'datetime',
    notprefix: '\$[]',
    callback: (DartDeclaration self, dynamic testSubject,
        {required String key, dynamic value}) {
      self.setName(key);
      self.type = 'DateTime';
      return self;
    },
  ),
  Command(
    prefix: '@',
    command: 'template',
    notprefix: '\$[]',
    callback: (DartDeclaration self, dynamic testSubject,
        {required String key, dynamic value}) {
      self.setName(key);
      self.type = 'T';
      return self;
    },
  ),
  Command(
    prefix: '@',
    command: 'enum',
    notprefix: '\$[]',
    callback: (DartDeclaration self, dynamic testSubject,
        {required String key, dynamic value}) {
      self.setEnumValues(
          (value as String).substring('@enum:'.length).split(','));
      self.setName(key);
      return self;
    },
  ),
  Command(
    type: dynamic,
    callback: (DartDeclaration self, dynamic testSubject,
        {required String key, dynamic value}) {
      self.setName(key);

      if (value == null) {
        self.type = 'dynamic';
        return self;
      }
      if (value is Map) {
        self.type = key.toTitleCase();
        self.nestedClasses
            .add(JsonModel.fromMap('nested', value as Map<String, dynamic>));
        return self;
      }
      self.type = value.runtimeType.toString();
      return self;
    },
  ),
];
