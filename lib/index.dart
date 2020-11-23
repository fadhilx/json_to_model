import 'dart:convert';
import 'dart:io';

import 'package:apn_json2model/core/model_template.dart';
import 'package:apn_json2model/utils/build_script.dart';
import 'package:path/path.dart' as path;

import './core/json_model.dart';

class JsonModelRunner {
  String srcDir = './jsons/';
  String distDir = './lib/models/';
  String? onlyFile = './lib/models/';
  List<FileSystemEntity> list = [];

  JsonModelRunner({
    required String source,
    required String output,
    String? onlyFile,
  })   : srcDir = source,
        distDir = output,
        onlyFile = onlyFile;

  void setup() {
    if (srcDir.endsWith('/')) srcDir = srcDir.substring(0, srcDir.length - 1);
    if (distDir.endsWith('/')) {
      distDir = distDir.substring(0, distDir.length - 1);
    }
  }

  bool run({command}) {
    // run
    // get all json files ./jsons
    list = onlyFile == null ? getAllJsonFiles() : [File(path.join(srcDir, onlyFile))];
    if (!generateModelsDirectory()) return false;
    if (!iterateJsonFile()) return false;

    return true;
  }

  void cleanup() async {
    // wrapup cleanup

    if (onlyFile != null) {
      var dotSplit = path.join(srcDir, onlyFile).split('.');
      BuildScript(['run', (dotSplit..removeLast()).join('.') + '.dart']).build();
    }
  }

  // all json files
  List<FileSystemEntity> getAllJsonFiles() {
    var src = Directory(srcDir);
    return src.listSync(recursive: true);
  }

  bool generateModelsDirectory() {
    if (list.isEmpty) return false;
    if (!Directory(distDir).existsSync()) {
      Directory(distDir).createSync(recursive: true);
    }
    return true;
  }

  // iterate json files
  bool iterateJsonFile() {
    var error = StringBuffer();

    var indexFile = '';
    list.forEach((f) {
      if (FileSystemEntity.isFileSync(f.path)) {
        var fileExtension = '.json';
        if (f.path.endsWith(fileExtension)) {
          var file = File(f.path);
          var dartPath = f.path.replaceFirst(srcDir, distDir).replaceFirst(
                fileExtension,
                '.dart',
                f.path.length - fileExtension.length - 1,
              );
          List basenameString = path.basename(f.path).split('.');
          String fileName = basenameString.first;
          Map<String, dynamic> jsonMap = json.decode(file.readAsStringSync());

          var relative = dartPath.replaceFirst(distDir + path.separator, '').replaceAll(path.separator, '/');

          var jsonModel = JsonModel.fromMap(fileName, jsonMap, relativePath: relative);
          if (!generateFileFromJson(dartPath, jsonModel, fileName)) {
            error.write('cant write $dartPath');
          }

          print('generated: $relative');
          indexFile += "export '$relative';\n";
        }
      }
    });
    if (indexFile.isNotEmpty) {
      File(path.join(distDir, 'index.dart')).writeAsStringSync(indexFile);
    }
    return indexFile.isNotEmpty;
  }

  // generate models from the json file
  bool generateFileFromJson(outputPath, JsonModel jsonModel, name) {
    try {
      File(outputPath)
        ..createSync(recursive: true)
        ..writeAsStringSync(
          ModelTemplates.fromJsonModel(jsonModel),
        );
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }
}
