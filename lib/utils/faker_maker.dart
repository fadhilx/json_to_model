import 'package:json_to_model/core/dart_declaration.dart';
import 'package:json_to_model/utils/extensions.dart';

class FakerMaker {
  final DartDeclaration declaration;
  final String className;
  final String type;
  final bool isModel;

  FakerMaker(
    this.declaration,
    this.className,
    this.type,
    // ignore: avoid_positional_boolean_parameters
    this.isModel,
  );

  String generate() {
    if (isModel) {
      return 'mock$type()';
    } else if (declaration.isEnum) {
      return _enumFaker(declaration.getEnum(className));
    } else if (declaration.fakerDeclaration != null) {
      return _interpretFaker(declaration.fakerDeclaration!);
    } else if (type == 'int') {
      return 'faker.randomGenerator.integer(100)';
    } else if (type == 'String') {
      return _guessString(declaration.jsonValue as String?);
    } else if (type == 'bool') {
      return 'faker.randomGenerator.boolean()';
    } else if (type == 'double' || type == 'num') {
      return 'faker.randomGenerator.decimal()';
    } else if (type == 'DateTime') {
      return 'faker.date.dateTime(minYear: 1900, maxYear: 2025)';
    } else if (type.startsWith('Map')) {
      return '{}';
    } else {
      return 'null';
    }
  }

  String _interpretFaker(String input) {
    // * The declaration is a raw faker instruction.
    if (input.contains('faker')) return input;

    final options = input.split(',');

    if (type == 'String') {
      return createForString(options);
    }
    if (type == 'int') {
      return createForInt(options);
    }
    if (type == 'DateTime') {
      return createForDateTime(options);
    }

    return 'Faker not found';
  }

  String _guessString(String? value) {
    if (value != null) {
      if (value.contains('@')) {
        return 'faker.internet.email()';
      }
      if (value.startsWith('https')) {
        return 'faker.internet.httpsUrl()';
      }
      if (value.startsWith('http')) {
        return 'faker.internet.httpUrl()';
      }
    }
    return 'faker.randomGenerator.string(100)';
  }

  String _enumFaker(Enum e) {
    var values = e.values.map((e) {
      final valueOverride = e.between('(', ')');
      return valueOverride ?? e;
    }).toList();

    if (type == 'String') {
      values = values.map((e) => "'$e'").toList();
    }

    if (e.isNullable) {
      values.add('null');
    }

    return 'faker.randomGenerator.element<$type${e.isNullableString}>([${values.join(', ')}])';
  }

  String createForString(List<String> options) {
    // Handle person case
    if (options.hasStartsWith('person')) {
      return _personFaker(options);
    }

    // Handle url
    if (options.hasStartsWith('url')) {
      return _urlFaker(options);
    }

    // Handle min/max options
    if (options.hasStartsWithOr(['max', 'min', 'chars'])) {
      return _minMaxFaker(options, type);
    }
    throw 'No faker could be generated for type `String` with options $options';
  }

  String createForInt(List<String> options) {
    if (options.hasStartsWithOr(['max', 'min', 'chars'])) {
      return _minMaxFaker(options, type);
    }

    throw 'No faker could be generated for type `int` with options $options';
  }

  String createForDateTime(List<String> options) {
    if (options.hasStartsWith('now')) {
      return 'clock.now()';
    }
    if (options.hasStartsWithOr(['max', 'min'])) {
      return _minMaxDateFaker(options);
    }

    throw 'No faker could be generated for type `DateTime` with options $options';
  }
}

String _minMaxDateFaker(List<String> options) {
  var max = '2025';
  var min = '1900';
  _loopOptions(options, (String param, String? value) {
    if (param == 'max' && value != null) {
      max = value;
    }
    if (param == 'min' && value != null) {
      min = value;
    }
  });

  return 'faker.date.dateTime(minYear: $min, maxYear: $max)';
}

String _minMaxFaker(List<String> options, String type) {
  final ftype = type == 'String' ? 'string' : 'integer';

  var max = '100';
  var min = '1';
  String? length;
  var charset = 'abc';

  _loopOptions(options, (String param, String? value) {
    if (param == 'max' && value != null) {
      max = value;
    }
    if (param == 'min' && value != null) {
      min = value;
    }
    if (param == 'chars' && value != null) {
      charset = value;
    }
    if (param == 'length' && value != null) {
      length = value;
    }
  });

  if (type == 'String') {
    final lengthProperty =
        (max == min || length != null) ? length ?? max : 'faker.randomGenerator.integer($max, min: $min)';
    return "faker.randomGenerator.fromCharSet('$charset', $lengthProperty)";
  }

  return 'faker.randomGenerator.$ftype($max, min: $min)';
}

String _personFaker(List<String> options) {
  assert(options.isNotEmpty, 'faker param `person` cannot be called without a opion (e.g. person(first_name))');

  var field = 'first_name';
  _loopOptions(options, (String param, String? value) {
    if (value != null) field = value;
  });

  return 'faker.person.${field.toCamelCase()}()';
}

String _urlFaker(List<String> options) {
  return 'faker.internet.httpsUrl()';
}

void _loopOptions(List<String> options, void Function(String, String?) callback) {
  for (final option in options) {
    final param = option.split('(')[0];
    final value = option.between('(', ')');

    callback(param, value);
  }
}
