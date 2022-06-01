import 'package:json_to_model/core/json_model.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('All keys must have a value, or an error will be thrown', () {
    const content = <String, dynamic>{
      "name": "Mark",
      "age?": 25,
      "city?": null, // So we can catch the dynamic type error
      "birthdate": "@datetime",
      "timeStamp": "@timestamp"
    };

    try {
      JsonModel.fromMap(
        'types',
        content,
        relativePath: './',
        packageName: 'core',
        indexPath: 'index.dart',
      );
    } on String catch (e) {
      expect(
        e,
        equals(
          'Cannot infer type of key "city" in class "Types". Could it be `null`? If so try adding a value to the key.',
        ),
      );
    }
  });
}
