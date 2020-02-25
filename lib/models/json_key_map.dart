import 'package:json_to_model/models/model_template.dart';

import '../utils/extensions.dart';

class Command {
  String command;
  Function callback;
  Command({this.command, this.callback});
}

class JsonKeyModel {
  String type;
  String key;
  dynamic value;
  List import = [];

  static bool isFirst = true;

  List<Command> commands = [
    Command(
      command: '@JsonKey',
      callback: (type, key, value, self) {
        return ModelTemplates.indented(
          JsonKeyModel.getKey(key, type, value, alternateKey: true),
        );
      },
    ),
    Command(
      command: '@import',
      callback: (type, key, value, JsonKeyModel self) {
        if (value is List) {
          self.import.addAll(value);
        } else {
          self.import.addAll([value]);
        }
        return '';
      },
    )
  ];
  JsonKeyModel(this.key, this.value) {
    var typemap = getType(value);
    type = typemap['type'];
    import.addAll([typemap['import']]);
  }

  static Map getJsonKey(value, originalKey, jsonKeyParemeters) {
    var valueName = value.substring(1);

    var newType = getType(value)['type'];
    var afterkey =
        originalKey.split(')')[1].split(' ').where((String s) => s.isNotEmpty);

    // if have own json key string
    if (afterkey.length > 1) {
      valueName = afterkey.last;
    }
    jsonKeyParemeters = "name: '$valueName'";
    // get parameter inside: @JsonKey
    var jsonkeystringlist = originalKey.split('@JsonKey');
    var typeJsonkeyParams = jsonkeystringlist[1].split('(')[1].split(')')[0];

    // merge params if contains name:
    if (typeJsonkeyParams.replaceAll(' ', '').contains('name:')) {
      jsonKeyParemeters = typeJsonkeyParams; //replace
    } else {
      jsonKeyParemeters += ', ' + typeJsonkeyParams; //concate
    }

    // if have own Type on json key
    if (originalKey.split(')')[1].replaceAll(' ', '').isNotEmpty) {
      newType = afterkey.first;
    }

    return {
      'newType': newType,
      'valueName': valueName,
      'jsonKeyParemeters': jsonKeyParemeters,
    };
  }

  static String getKey(String type, String key, dynamic value, {alternateKey}) {
    key = key.trim();

    // inside @JsonKey([here]);
    var jsonKeyParemeters = "name: '$key'";
    if (alternateKey ?? false) {
      if (value.startsWith('\$')) {
        // if starts with $
        var jsonKeyMap = getJsonKey(value, type, jsonKeyParemeters);

        jsonKeyParemeters = jsonKeyMap['jsonKeyParemeters'];
        type = jsonKeyMap['newType'];
        value = jsonKeyMap['valueName'];
      }
      key = pathToName(value);

      var camelKey = key.toCamelCase();
      return '\n@JsonKey($jsonKeyParemeters)\n$type $camelKey';
    }

    if (key.isTitleCase() || key.contains('_') || key.contains(' ')) {
      var camelKey = key.toCamelCase();
      return '@JsonKey($jsonKeyParemeters)\n$type $camelKey';
    }
    return '$type $key';
  }

  static String pathToName(pathstring) {
    return pathstring.split('/').last.split('\\').last;
  }

  static Map getTypeMap(value, [import]) {
    return {
      'type': value,
      'import': import,
    };
  }

  static Map getType(value) {
    var import;
    if (value.runtimeType == Null) return getTypeMap('dynamic');
    if (value.runtimeType != String) {
      return getTypeMap(value.runtimeType.toString());
    }
    if (!value.toString().startsWith('\$')) {
      return getTypeMap(value.runtimeType.toString());
    }

    var valueString = value.toString();

    // if value startsWith $
    var afterDolar = valueString.substring(1);

    Function listType = (type) => 'List<$type>';

    // if start with []
    if (afterDolar.startsWith('[]')) {
      var afterBracket = afterDolar.substring(2);
      import = afterBracket;
      String typeString = getType('\$$afterBracket')['type'];
      return getTypeMap(listType(typeString), import);
    }

    import = afterDolar;
    afterDolar = pathToName(afterDolar);
    return getTypeMap(afterDolar.toTitleCase(), import);
  }

  String toDeclarationString() {
    var result;
    for (final cmd in commands) {
      if (key != null && key.startsWith('${cmd.command}')) {
        // yupskit
        result = cmd.callback(type, key, value, this);
        break;
      }
    }
    if (result != null) return result;
    return ModelTemplates.indented(getKey(type, key, value) + ';');
  }

  String toImportString() {
    return ModelTemplates.indented(
        import
            .where((element) => element != null && element.isNotEmpty)
            .map((e) => "import '$e.dart';")
            .join('\n'),
        indent: 0);
  }
}
