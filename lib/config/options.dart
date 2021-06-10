const kSource = 'source';
const kSourceAbbr = 's';

const kOutput = 'output';
const kOutputAbbr = 'o';

const kFactoryOutput = 'factory_output';
const kFactoryOutputAbbr = 'f';

const kPackageName = 'package_name';
const kPackageNameAbbr = 'p';

const kCreateFactories = 'create_factories';

class Option<T> {
  final String name;
  final String? abbr;
  final String help;
  final T defaultValue;

  T? _value;
  T get value => _value ?? defaultValue;
  set value(T value) {
    // * All string options are paths at the moment, sanitize the path
    if (value is String && value.contains('/')) {
      _value = _addRoot(_removeEndSlash(value)) as T;
    } else {
      _value = value;
    }
  }

  Option(this.name, this.defaultValue, this.help, [this.abbr]);

  Option<T> copy() => Option<T>(name, defaultValue, help, abbr);

  Option<T> operator +(Option<T> other) {
    if (name != other.name) throw 'Cannot add to options of different type';
    final newOption = copy();
    newOption.value = _getValue(value, other.value, defaultValue);
    return newOption;
  }

  @override
  String toString() {
    return '$name: $value';
  }
}

class Options {
  List<Option> options = [
    Option<String>(
      kSource,
      './jsons',
      'Specify the json input directory.',
      kSourceAbbr,
    ),
    Option<String>(
      kOutput,
      './lib/models',
      'Specify models output directory.',
      kOutputAbbr,
    ),
    Option<String>(
      kFactoryOutput,
      './test/models',
      'Specify models factory directory.',
      kFactoryOutputAbbr,
    ),
    Option<String>(
      kPackageName,
      '',
      'Specify the package model (default is automatically got from pubspec).',
      kPackageNameAbbr,
    ),
    Option<bool>(
      kCreateFactories,
      false,
      'Enable of disable the factory generation.',
    ),
  ];

  Option<T> getOption<T>(String name) {
    final results = options.where((element) => element.name == name);
    if (results.isEmpty) throw 'Cannot find option with name `$name`';
    return results.first as Option<T>;
  }

  void setOption<T>(String name, T? value) {
    if (value != null) {
      getOption(name).value = value;
    }
  }

  @override
  String toString() {
    return '''
Options:
  $options
''';
  }

  Options operator +(Options other) {
    final result = Options();

    void mergeOption(Option option) {
      result.setOption(option.name, (option + other.getOption(option.name)).value);
    }

    options.forEach(mergeOption);

    return result;
  }
}

T _getValue<T>(T first, T second, T defaultValue) {
  // Same doesnt matter what we return
  if (first == second) return first;
  // first is default, return second
  if (first == defaultValue) return second;
  // second is default, return first
  if (second == defaultValue) return first;
  // second takes precedent when both are not the default value
  return second;
}

String _removeEndSlash(String input) {
  if (input.endsWith('/')) return input.substring(0, input.length - 1);
  return input;
}

String _addRoot(String input) {
  if (!input.startsWith('./')) return './$input';
  return input;
}
