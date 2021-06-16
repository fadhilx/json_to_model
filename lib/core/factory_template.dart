import 'package:json_to_model/core/json_model.dart';

typedef JsonModelConverter = String Function(JsonModel data, [bool isNested]);

String factoryFromJsonModel(
  JsonModel data, {
  bool isNested = false,
}) {
  final mockDeclarations = data.mockDeclaration;
  final nestedClasses = data.nestedFactoryClasses;
  final relativePath = data.relativePath;
  var indexPathPrefix = '';

  if (relativePath != null) {
    final matches = RegExp(r'\/').allMatches(relativePath).length;
    String addPrefix(_) => indexPathPrefix = '$indexPathPrefix../';
    List.filled(matches, (i) => i).forEach(addPrefix);
  }
  final packageName = data.packageName;
  final indexPath = data.indexPath;

  var template = '';

  if (!isNested) {
    template += '''
import 'package:faker/faker.dart';
import 'package:clock/clock.dart';
import 'package:quiver/core.dart';

import 'package:$packageName/$indexPath';
import '${indexPathPrefix}index.dart';
''';
  }

  template += mockDeclarations;

  if ((nestedClasses?.length ?? 0) > 0) {
    template += nestedClasses.toString();
  }

  return template;
}
