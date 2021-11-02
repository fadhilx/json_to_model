import 'package:json_to_model/core/json_model.dart';

typedef JsonModelConverter = String Function(JsonModel data, [bool isNested]);

String modelFromJsonModel(JsonModel data, {bool isNested = false}) =>
    _defaultJsonTemplate(
        isNested: isNested,
        constructor: data.constructor,
        imports: data.imports,
        fileName: data.fileName,
        relativePath: data.relativePath,
        className: data.className,
        extendsClass: data.extendsClass,
        mixinClass: data.mixinClass,
        equalsDeclarations: data.equalsDeclarations,
        hashDeclarations: data.hashDeclarations,
        declaration: data.declaration,
        copyWith: data.copyWith,
        cloneFunction: data.cloneFunction,
        jsonFunctions: data.jsonFunctions,
        isTemplate: data.isTemplate,
        enums: data.enums,
        enumConverters: data.enumConverters,
        nestedClasses: data.nestedClasses);

String _defaultJsonTemplate({
  required bool isNested,
  required String constructor,
  required String imports,
  required String fileName,
  required String className,
  required String mixinClass,
  required String equalsDeclarations,
  required String hashDeclarations,
  required String declaration,
  required String copyWith,
  required String cloneFunction,
  required String jsonFunctions,
  required bool isTemplate,
  String? relativePath,
  String? enums,
  String? enumConverters,
  String? nestedClasses,
  String? extendsClass,
}) {
  var indexPathPrefix = '';

  if (relativePath != null) {
    final matches = RegExp(r'\/').allMatches(relativePath).length;
    String addPrefix(_) => indexPathPrefix = '$indexPathPrefix../';
    List.filled(matches, (i) => i).forEach(addPrefix);
  }

  var template = '';

  if (!isNested) {
    template += '''
import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';
import '${indexPathPrefix}index.dart';

$imports

''';
  }

  template += '''
@immutable
class $className${isTemplate ? '<T>' : ''}${extendsClass != null ? ' extends $extendsClass ' : ''}${mixinClass.isNotEmpty ? ' with $mixinClass' : ''} {

$constructor

  $declaration

$jsonFunctions

  $cloneFunction

''';

  if ((enumConverters?.length ?? 0) > 0) {
    template += '\n$enumConverters';
  }

  template += '''

$copyWith

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is $className && $equalsDeclarations;

  @override
  int get hashCode => $hashDeclarations;

''';
  if (!isTemplate) {
    template += '''
  // for template usage in case
  static $className fromJsonModel(Map<String, dynamic> json) => $className.fromJson(json);
  static Map<String, dynamic> toJsonModel() => $className.toJsonModel();

''';
  }

  template += '}\n';

  if ((enums?.length ?? 0) > 0) {
    template += '\n$enums\n';
  }

  if ((nestedClasses?.length ?? 0) > 0) {
    template += '\n$nestedClasses';
  }

  return template;
}
