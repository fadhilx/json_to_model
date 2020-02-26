# json_to_model

Gernerating Dart model class(json\*serializable) from Json file.\
_partly inspired by [json_model](https://github.com/flutterchina/json_model)._

## Instalation

on `pubspec.yaml`

```yaml
dependencies:
  json_to_mobile: ^1.0.0
```

install using `pub get` command or if you using dart vscode/android studio, you can use install option.

## Getting started

1. Create a `jsons`(default) directory in the root of your project
2. Put all or Create json files inside `jsons` directory
3. run `pub run json_to_model`. or `flutter pub run json_to_model` flutter project

## Usage

this package will read `.json` file, and generate `.dart` file, asign the `type of the value` as `variable type` and `key` as the `variable name`.

## Default Feature

| Description                                           | Expression                   | Input                                                                | Output(declaration)                                        | Output(import)                                    |
| :---------------------------------------------------- | ---------------------------- | -------------------------------------------------------------------- | ---------------------------------------------------------- | ------------------------------------------------- |
| import model and asign type                           | {`...`:`'$value'`}           | `{"auth':'$user'}`                                                   | `User auth;`                                               | `import 'user.dart'`                              |
| import recursively                                    | {`...`:`'$../pathto/value'`} | `{"price':'$../product/price'}`                                      | `Price price;`                                             | `import '../product/price.dart'`                  |
| asign list of type and import (can also be recursive) | {`...`:`'$[]value'`}         | `{"addreses':'$[]address'}`                                          | `List<Address> addreses;`                                  | `import 'address.dart'`                           |
| use `json_annotation` `@JsonKey`                      | {`'@JsonKey(...)'`:`...`}    | `{"@JsonKey(ignore: true) dynamic': 'val'}`                          | `@JsonKey(ignore: true) dynamic val;`                      | -                                                 |
| import other library(input value can be array)        | {`'@import'`:`...`}          | `{"@import':'package:otherlibrary/otherlibrary.dart'}`               | -                                                          | `import 'package:otherlibrary/otherlibrary.dart'` |
| write code independentally(experimental)              | {`'@_...'`:`...`}            | `{"@_ // any code her':',its like an escape to write yourown code'}` | `// any code her,its like an escape to write yourown code` | -                                                 |

## Examples

you can copy json below and generate using `pub run json_to_model` command

### Basic

**Source File**

`./jsons/user.json`

```js
{
  "id": 2,
  "username": "John Doe",
  "blocked": false
}
```

**Generated**

`./lib/models/user.dart`

```dart
import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';
@JsonSerializable()
class User {
      User();

  int id;
  String username;
  bool blocked;

  factory User.fromJson(Map<String,dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

After that, `json_serializable` will automatically genereate `.g.dart` files

`./lib/models/user.g.dart`

```dart
part of 'user.dart';
User _$UserFromJson(Map<String, dynamic> json) {
  return User()
    ..id = json['id'] as int
    ..username = json['username'] as String
    ..blocked = json['blocked'] as bool;
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'blocked': instance.blocked,
    };
```

### Asign Type variable

you can use `$` to specify the value to be Type of variable

**Source File**

`./jsons/user.json`

```js
{
  "id": 2,
  "username": "John Doe",
  "blocked": false,
  "addresses": "$address" // prefix $
}
```

In this case, `$address` is like telling the generator to import `address.dart` and asign the titled case `Address` as it is the type of the variable `addresses`.

**Generated**

`./lib/models/user.dart`

```dart
import 'package:json_annotation/json_annotation.dart';
import 'address.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  User();
  int id;
  String username;
  bool blocked;
  Address addresses;
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

### Asign List<Type> variable

you can use `$[]` to specify the value to be List of Type of variable

**Source File**

`./jsons/user.json`

```js
{
  "id": 2,
  "username": "John Doe",
  "blocked": false,
  "addresses": "$[]address" // prefix $[]
}
```

**Generated**

`./lib/models/user.dart`

```dart
import 'package:json_annotation/json_annotation.dart';
import 'address.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  User();
  int id;
  String username;
  bool blocked;
  List<Address> addresses;
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

### json_serializable JsonKey

you can use `@JsonKey` in `key` to specify @JsonKey

**Source File**

`./jsons/cart.json`

```js
{
  "@JsonKey(ignore: true) dynamic": "md", //jsonKey alias
  "@JsonKey(name: '+1') int": "fsdafsfg", //jsonKey alias
  "name": "wendux",
  "age": 20
}
```

**Generated**

`./lib/models/cart.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'cart.g.dart';

@JsonSerializable()
class Cart {
      Cart();

  @JsonKey(ignore: true) dynamic md; // jsonKey generated
  @JsonKey(name: '+1') int loved; // jsonKey generated
  String name;
  int age;

  factory Cart.fromJson(Map<String,dynamic> json) => _$CartFromJson(json);
  Map<String, dynamic> toJson() => _$CartToJson(this);
}

```

## Contribution

i'm open contribution for documentation, bug report, code maintenance, etc. pPlease properly send a pull request. Thanks for your support.
