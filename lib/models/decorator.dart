class Decorator {
  String prfix = '';
  String string = '';
  Decorator(String fullString) {
    prfix = fullString.split('(').first;
    string = fullString;
  }
  @override
  String toString() {
    return string;
  }
}

extension DecoratorList on List<Decorator> {
  void replaceDecorator(Decorator decorator) {
    removeWhere((element) => element.prfix == decorator.prfix);
    add(decorator);
  }
}
