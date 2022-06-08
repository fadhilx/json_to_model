import 'dart:convert';
import 'dart:io';

import 'package:json_to_model/config/options.dart';
import 'package:json_to_model/core/factory_template.dart';
import 'package:json_to_model/core/json_model.dart';
import 'package:json_to_model/core/model_template.dart';
import 'package:path/path.dart' as path;

class JsonModelRunner {
  final Options _options;

  String get _srcDir => _options.getOption<String>(kSource).value;
  String get _distDir => _options.getOption<String>(kOutput).value;
  String get _factoryOutput => _options.getOption<String>(kFactoryOutput).value;
  bool get _createFactories => _options.getOption<bool>(kCreateFactories).value;

  JsonModelRunner(this._options);

  void run() {
    // Ensure the dirs exist
    _createDirectory(_distDir);
    _createDirectory(_factoryOutput);

    // Iterate and create all models+factories
    _iterateOverJsonFiles();
  }

  void _createDirectory(String dir) {
    if (!Directory(dir).existsSync()) {
      Directory(dir).createSync(recursive: true);
    }
  }

  bool _iterateOverJsonFiles() {
    var indexFile = '';
    Directory(_srcDir).listSync(recursive: true).forEach((f) {
      if (FileSystemEntity.isFileSync(f.path)) {
        const fileExtension = '.json';
        if (f.path.endsWith(fileExtension)) {
          final file = File(f.path);
          final dartPath = f.path.replaceFirst(_srcDir, _distDir).replaceAll(fileExtension, '.dart');
          final factoryPath = f.path.replaceFirst(_srcDir, _factoryOutput).replaceAll(fileExtension, '.dart');

          final basenameString = path.basename(f.path).split('.');
          final fileName = basenameString.first;
          final jsonMap = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
          final relative = dartPath.replaceFirst(_distDir + path.separator, '').replaceAll(path.separator, '/');
          final jsonModel = JsonModel.fromMap(
            fileName,
            jsonMap,
            relativePath: relative,
            packageName: _options.getOption<String>(kPackageName).value,
            indexPath: path.join(_distDir.replaceAll('./lib/', ''), 'index.dart'),
          );

          File(dartPath)
            ..createSync(recursive: true)
            ..writeAsStringSync(modelFromJsonModel(jsonModel));

          print('model: $dartPath');
          if (_createFactories) {
            print('factory: $factoryPath');

            File(factoryPath)
              ..createSync(recursive: true)
              ..writeAsStringSync(factoryFromJsonModel(jsonModel));
          }

          indexFile += "export '$relative';\n";
        }
      }
    });

    if (indexFile.isNotEmpty) {
      if (_createFactories) {
        File(path.join(_factoryOutput, 'index.dart')).writeAsStringSync(indexFile);
      }

      // * The models index file has some helper methods
      indexFile += '''
import 'package:quiver/core.dart';

T? checkOptional<T>(Optional<T?>? optional, T? Function()? def) {
  // No value given, just take default value
  if (optional == null) return def?.call();

  // We have an input value
  if (optional.isPresent) return optional.value;

  // We have a null inside the optional
  return null;
}
''';

      File(path.join(_distDir, 'index.dart')).writeAsStringSync(indexFile);
    }
    return indexFile.isNotEmpty;
  }
}
