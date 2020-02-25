import '../utils/extensions.dart';

import '../models/json_key_map.dart';

class JsonModel {
  String fileName;
  String className;
  String declaration;
  String imports;
  List imports_raw;
  JsonModel(String fileName, List<JsonKeyModel> jsonKeyModel) {
    this.fileName = fileName.toCamelCase();
    className = fileName.toTitleCase();
    declaration = jsonKeyModel.toDeclarationStrings();
    imports = jsonKeyModel.toImportStrings();
    imports_raw = jsonKeyModel.getImportRaw();
  }

  // model string from json map
  static JsonModel jsonModelFromMap(Map jsonMap, String fileName) {
    var jsonKeyModel = <JsonKeyModel>[];
    jsonMap.forEach((key, value) => jsonKeyModel.add(JsonKeyModel(key, value)));
    // add key to templatestring
    // add valuetype to templatestring
    return JsonModel(fileName, jsonKeyModel);
  }
}
