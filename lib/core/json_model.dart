import 'package:json_to_model/core/dart_declaration.dart';

import '../utils/extensions.dart';

class JsonModel {
  String fileName;
  String className;
  String declaration;
  String imports;
  List<String> imports_raw;
  String enums;
  String enumConverters;
  String nestedClasses;

  JsonModel(String fileName, List<DartDeclaration> dartDeclarations) {
    this.fileName = fileName;
    className = fileName.toTitleCase();
    declaration = dartDeclarations.toDeclarationStrings();
    imports = dartDeclarations.toImportStrings();
    imports_raw = dartDeclarations.getImportRaw();
    enums = dartDeclarations.getEnums();
    enumConverters = dartDeclarations.getEnumConverters();
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
