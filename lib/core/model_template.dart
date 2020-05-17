import 'package:json_to_model/core/json_model.dart';

typedef JsonModelConverter = String Function(JsonModel data, [bool isNested]);

class ModelTemplates {
  static JsonModelConverter fromJsonModel = (data, [isNested = false]) => ModelTemplates.defaultTemplate(
        isNested: isNested,
        imports: data.imports,
        fileName: data.fileName,
        className: data.className,
        declaration: data.declaration,
        enums: data.enums,
        enumConverters: data.enumConverters,
        nestedClasses: data.nestedClasses,
      );

  static String defaultTemplate({
    bool isNested,
    String imports,
    String fileName,
    String className,
    String declaration,
    String enums,
    String enumConverters,
    String nestedClasses,
  }) {
    var template = '';

    if (!isNested) {
      template += '''
import 'package:json_annotation/json_annotation.dart';
$imports

part '$fileName.g.dart';

''';
    }

    template += '''
@JsonSerializable()
class ${className ?? '/*TODO: className*/'} {
      ${className ?? '/*TODO: className*/'}();

  ${declaration ?? '/*TODO: declaration*/'}

  factory ${className ?? '/*TODO: className*/'}.fromJson(Map<String,dynamic> json) => _\$${className}FromJson(json);
  Map<String, dynamic> toJson() => _\$${className}ToJson(this);
''';

    if ((enumConverters?.length ?? 0) > 0) {
      template += '\n$enumConverters';
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

  static String indented(String content, {int indent}) {
    indent = indent ?? 1;
    var indentString = (List(indent)..fillRange(0, indent, '  ')).join('');

    content = content.replaceAll('\n', '\n$indentString');

    return '$indentString$content';
  }
}
