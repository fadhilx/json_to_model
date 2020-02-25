import 'package:json_to_model/models/json_model.dart';

class ModelTemplates {
  static String Function(JsonModel) fromJsonModel =
      (JsonModel data) => ModelTemplates.defaultTemplate(
            imports: data.imports,
            fileName: data.fileName,
            className: data.className,
            declaration: data.declaration,
          );

  static String defaultTemplate({
    imports,
    fileName,
    className,
    declaration,
  }) =>
      """
import 'package:json_annotation/json_annotation.dart';

${imports ?? '/*TODO: imports*/'}

part '${fileName ?? '/*TODO: fileName*/'}.g.dart';

@JsonSerializable()
class ${className ?? '/*TODO: className*/'} {
      ${className ?? '/*TODO: className*/'}();

  ${declaration ?? '/*TODO: declaration*/'}

  factory ${className ?? '/*TODO: className*/'}.fromJson(Map<String,dynamic> json) => _\$${className ?? '/*TODO: className*/'}FromJson(json);
  Map<String, dynamic> toJson() => _\$${className ?? '/*TODO: className*/'}ToJson(this);
}
    """;

  static String indented(String content, {int indent}) {
    indent = indent ?? 1;
    var indentString = (List(indent)..fillRange(0, indent, '  ')).join('');

    content = content.replaceAll('\n', '\n$indentString');

    return '$indentString$content';
  }
}
