import 'dart:convert';

import 'package:expressions/expressions.dart';

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
    var newMap = {
      for (var demo in newList) '${demo.first}': demo.last,
    };
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
