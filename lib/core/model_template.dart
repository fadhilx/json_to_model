import 'package:json_to_model/core/json_model.dart';

typedef JsonModelConverter = String Function(JsonModel data, [bool isNested]);

class ModelTemplates {
  static JsonModelConverter fromJsonModel = (data, [isNested = false]) => ModelTemplates.defaultTemplate(
        isNested: isNested,
        imports: data.imports,
        fileName: data.fileName,
        className: data.className,
        extendsClass: data.extendsClass,
        mixinClass: data.mixinClass,
        equalsDeclarations: data.equalsDeclarations,
        hashDeclarations: data.hashDeclarations,
        declaration: data.declaration,
        cloneDeclarations: data.cloneDeclarations,
        enums: data.enums,
        enumConverters: data.enumConverters,
        nestedClasses: data.nestedClasses,
      );

  static String defaultTemplate({
    bool isNested,
    String imports,
    String fileName,
    String className,
    String extendsClass,
    String mixinClass,
    String equalsDeclarations,
    String hashDeclarations,
    String declaration,
    String cloneDeclarations,
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
class ${className ?? '/*TODO: className*/'}${extendsClass != null ? ' extends $extendsClass ' : ''}${mixinClass.isNotEmpty ? ' with $mixinClass' : ''} {
  
  ${className ?? '/*TODO: className*/'}();

  ${declaration ?? '/*TODO: declaration*/'}

  factory ${className ?? '/*TODO: className*/'}.fromJson(Map<String,dynamic> json) => _\$${className}FromJson(json);
  Map<String, dynamic> toJson() => _\$${className}ToJson(this);

  $className clone() => $className()
    $cloneDeclarations;

''';

    if ((enumConverters?.length ?? 0) > 0) {
      template += '\n$enumConverters';
    }

    template += '''

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is $className && $equalsDeclarations;

  @override
  int get hashCode => $hashDeclarations;
''';
    

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
