import 'package:json_to_model/core/dart_declaration.dart';

import '../utils/extensions.dart';

class JsonModel {
  late String fileName;
  late String constructor;
  late String className;
  late String mixinClass;
  late String declaration;
  late String mockDeclaration;
  late String copyWith;
  late String cloneFunction;
  late String jsonFunctions;
  late String hashDeclarations;
  late String equalsDeclarations;
  late String imports;
  String? packageName;
  String? indexPath;
  String? enums;
  String? enumConverters;
  String? nestedClasses;
  String? nestedFactoryClasses;
  String? extendsClass;
  String? relativePath;

  JsonModel(
    this.fileName,
    List<DartDeclaration> dartDeclarations, {
    this.packageName,
    this.indexPath,
    this.relativePath,
  }) {
    className = fileName.toTitleCase();
    constructor = dartDeclarations.toConstructor(className);
    mixinClass = dartDeclarations
        .where(
          (element) => element.mixinClass != null,
        )
        .map((element) => element.mixinClass)
        .join(', ');
    declaration = dartDeclarations.toDeclarationStrings(className);
    mockDeclaration = dartDeclarations.toMockDeclarationStrings(className);
    copyWith = dartDeclarations.toCopyWith(className);
    cloneFunction = dartDeclarations.toCloneFunction(className);
    jsonFunctions = dartDeclarations.toJsonFunctions(className);
    equalsDeclarations = dartDeclarations.toEqualsDeclarationString();
    hashDeclarations = dartDeclarations.toHashDeclarationString();
    imports = dartDeclarations.toImportStrings(relativePath);
    enums = dartDeclarations.getEnums(className);
    nestedClasses = dartDeclarations.getNestedModelClasses();
    nestedFactoryClasses = dartDeclarations.getNestedFactoryClasses();

    final extendsClass = dartDeclarations.where((element) => element.extendsClass != null).toList();
    if (extendsClass.isNotEmpty) {
      this.extendsClass = extendsClass[0].extendsClass;
    }
  }

  // model string from json map
  factory JsonModel.fromMap(
    String fileName,
    Map<String, dynamic> jsonMap, {
    String? packageName,
    String? indexPath,
    String? relativePath,
  }) {
    final dartDeclarations = <DartDeclaration>[];
    jsonMap.forEach((key, value) {
      return dartDeclarations.add(DartDeclaration.fromKeyValue(key, value));
    });
    // add key to templatestring
    // add valuetype to templatestring
    return JsonModel(
      fileName,
      dartDeclarations,
      relativePath: relativePath,
      packageName: packageName,
      indexPath: indexPath,
    );
  }
}
