import 'dart_declaration.dart';

typedef Callback = DartDeclaration Function(
    DartDeclaration self, String testSubject,
    {String key, dynamic value});

class Command {
  Type type = String;
  String notprefix;
  String prefix;
  String command;
  Callback callback;
  Command({
    this.type,
    this.prefix,
    this.notprefix,
    this.command,
    this.callback,
  });
}
