import 'dart:convert';
import 'dart:io';

import 'package:expressions/expressions.dart';
import '../utils/extensions.dart';

typedef Callback = DartDeclaration Function(
    DartDeclaration self, dynamic testSubject,
    {String key, dynamic value});

class Command {
  Type type = String;
  String notprefix;
  String prefix;
  String command;
  Function callback;
  Command({
    this.type,
    this.prefix,
    this.notprefix,
    this.command,
    this.callback,
  });
}

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
    keyComands = _keyComands;
    valueCommands = _valueCommands;
    jsonKey = JsonKeyMutate();
  }

  String strigifyAssignment(value) {
    return value != null ? ' = $value' : '';
  }

  String stringifyDecorator(deco) {
    return deco != null ? '$deco ' : '';
  }

  String getDecorator() {
    return decorators?.join('\n');
  }

  void addImport(import) {
    if (import == null && !import.isNotEmpty) return;
    if (import is List) {
      imports.addAll(import.map((e) => e));
    }
    if (import != null && import.isNotEmpty) imports.add(import);
  }

  String getImportStrings() {
    return imports
        .where((element) => element != null && element.isNotEmpty)
        .map((e) => "import '$e.dart';")
        .join('\n');
  }

  @override
  String toString() {
    return '${stringifyDecorator(getDecorator())}$type $name${strigifyAssignment(assignment)};';
  }

  static final List<Command> _keyComands = [
    Command(
      prefix: '\@',
      command: 'JsonKey',
      callback: (DartDeclaration self, dynamic testSubject,
          {String key, dynamic value}) {
        var jsonKey = JsonKeyMutate.fromJsonKeyParamaString(testSubject);
        self.jsonKey &= jsonKey;
        var newDeclaration = fromCommand(_valueCommands, self,
            testSubject: value, key: key, value: value);

        self.decorators.replaceDecorator(Decorator(self.jsonKey.toString()));
        self.type =
            getTypeFromJsonKey(testSubject) ?? newDeclaration.type ?? self.type;
        self.name =
            getNameFromJsonKey(testSubject) ?? newDeclaration.name ?? self.name;
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
        self.type = value.runtimeType.toString();
        return self;
      },
    ),
  ];
  static final List<Command> _valueCommands = [
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
    dartDeclaration = fromCommand(_valueCommands, dartDeclaration,
        testSubject: val, key: key, value: val);

    dartDeclaration = fromCommand(_keyComands, dartDeclaration,
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
}

class Decorator {
  String prfix = '';
  String string = '';
  Decorator(String fullString) {
    prfix = fullString.split('(').first;
    string = fullString;
  }
  @override
  String toString() {
    return string;
  }
}

extension on List<Decorator> {
  void replaceDecorator(Decorator decorator) {
    removeWhere((element) => element.prfix == decorator.prfix);
    add(decorator);
  }
}

class JsonKeyMutate {
  Object defaultValue;
  bool disallowNullValue;
  Function fromJson;
  bool ignore;
  bool includeIfNull;
  String name;
  bool nullable;
  bool required;
  Function toJson;
  Object unknownEnumValue;
  JsonKeyMutate({
    this.defaultValue,
    this.disallowNullValue,
    this.fromJson,
    this.ignore,
    this.includeIfNull,
    this.name,
    this.nullable,
    this.required,
    this.toJson,
    this.unknownEnumValue,
  });
  void addKey({
    defaultValue,
    disallowNullValue,
    fromJson,
    ignore,
    includeIfNull,
    name,
    nullable,
    required,
    toJson,
    unknownEnumValue,
  }) {
    this.defaultValue = defaultValue ?? this.defaultValue;
    this.disallowNullValue = disallowNullValue ?? this.disallowNullValue;
    this.fromJson = fromJson ?? this.fromJson;
    this.ignore = ignore ?? this.ignore;
    this.includeIfNull = includeIfNull ?? this.includeIfNull;
    this.name = name ?? this.name;
    this.nullable = nullable ?? this.nullable;
    this.required = required ?? this.required;
    this.toJson = toJson ?? this.toJson;
    this.unknownEnumValue = unknownEnumValue ?? this.unknownEnumValue;
  }

  Map toMap() {
    return {
      'defaultValue': defaultValue,
      'disallowNullValue': disallowNullValue,
      'fromJson': fromJson,
      'ignore': ignore,
      'includeIfNull': includeIfNull,
      'name': name,
      'nullable': nullable,
      'required': required,
      'toJson': toJson,
      'unknownEnumValue': unknownEnumValue,
    };
  }

  static String writeParamIfnotNull(Map maps) {
    var theString = [];
    maps.forEach((key, value) {
      if (value != null) {
        if (value is String) value = "'$value'";
        if (value is List) value = "[${value.join(',')}]";
        if (value is Map) value = JsonEncoder.withIndent('').convert(value);
        theString.add('$key: ${value}');
      }
    });
    return theString.join(', ');
  }

  static String getParameterString(String theString) {
    return theString.split('(')[1].split(')')[0];
  }

  factory JsonKeyMutate.fromJsonKeyParamaString(String theString) {
    theString = getParameterString(theString);
    var newList = theString
        .split(',')
        .map((e) => e.split(':'))
        .where((element) => element.length > 1)
        .map(
      (e) {
        var theValue = e.last.trim();
        var expression = Expression.parse(theValue);
        final evaluator = const ExpressionEvaluator();
        var theMap = [
          e.first,
          evaluator.eval(expression, null),
        ];
        return theMap;
      },
    );
    var newMap =
        Map.fromIterable(newList, key: (v) => v[0], value: (v) => v[1]);
    return JsonKeyMutate(
      defaultValue: newMap['defaultValue'],
      disallowNullValue: newMap['disallowNullValue'],
      fromJson: newMap['fromJson'],
      ignore: newMap['ignore'],
      includeIfNull: newMap['includeIfNull'],
      name: newMap['name'],
      nullable: newMap['nullable'],
      required: newMap['required'],
      toJson: newMap['toJson'],
      unknownEnumValue: newMap['unknownEnumValue'],
    );
  }

  JsonKeyMutate operator &(JsonKeyMutate jsonKey) {
    addKey(
      defaultValue: jsonKey.defaultValue,
      disallowNullValue: jsonKey.disallowNullValue,
      fromJson: jsonKey.fromJson,
      ignore: jsonKey.ignore,
      includeIfNull: jsonKey.includeIfNull,
      name: jsonKey.name,
      nullable: jsonKey.nullable,
      required: jsonKey.required,
      toJson: jsonKey.toJson,
      unknownEnumValue: jsonKey.unknownEnumValue,
    );
    return this;
  }

  @override
  String toString() {
    return '@JsonKey(${writeParamIfnotNull(toMap())})';
  }
}
