import 'package:json_to_model/core/dart_declaration.dart';

import '../utils/extensions.dart';

class JsonModel {
  String fileName;
  String className;
  String extendsClass;
  String mixinClass;
  String declaration;
  String hashDeclarations;
  String equalsDeclarations;
  String imports;
  List<String> imports_raw;
  String enums;
  String enumConverters;
  String nestedClasses;

  JsonModel(String fileName, List<DartDeclaration> dartDeclarations) {
    this.fileName = fileName;
    className = fileName.toTitleCase();
    extendsClass = dartDeclarations.firstWhere((element) => element.extendsClass != null, orElse: () => null)?.extendsClass;
    mixinClass = dartDeclarations.where((element) => element.mixinClass != null).map((element) => element.mixinClass).join(', ');
    declaration = dartDeclarations.toDeclarationStrings(className);
    equalsDeclarations = dartDeclarations.toEqualsDeclarationString();
    hashDeclarations = dartDeclarations.toHashDeclarationString();
    imports = dartDeclarations.toImportStrings();
    imports_raw = dartDeclarations.getImportRaw();
    enums = dartDeclarations.getEnums(className);
    nestedClasses = dartDeclarations.getNestedClasses();
  }

  // model string from json map
  static JsonModel fromMap(String fileName, Map jsonMap) {
    var dartDeclarations = <DartDeclaration>[];
    jsonMap.forEach((key, value) {
      var declaration = DartDeclaration.fromKeyValue(key, value);

      return dartDeclarations.add(declaration);
    });
    // add key to templatestring
    // add valuetype to templatestring
    return JsonModel(fileName, dartDeclarations);
  }
}
