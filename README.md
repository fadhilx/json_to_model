# json_to_model

Gernerating Dart model class(json_serializable) from Json file.
inspired by json_model [json_model](https://github.com/flutterchina/json_model)

## instalation

on `pubspec.yaml`

```yaml
dependencies:
  json_to_mobile: ^1.0.0
```

install using `pub get` command or if you using dart vscode/android studio, you can use install option

## Getting started

1. Create a `jsons`(default) directory in the root of your project
2. Put all or Create json files inside `jsons` directory
3. run `pub run json_to_model`. or `flutter pub run json_to_model` flutter project

## Usage

### basic

this package will read `.json` file, and generate `.dart` file, asign the `type of the value` as `variable type` and `key` as the `variable name`.

#### Example

_Source File_

`./jsons/user.json`

```js
{
  "id": 2,
  "username": "John Doe",
  "blocked": false
}
```

_Generated_

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

_Source File_

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

_Generated_

`./lib/models/user.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

import 'address.dart'; // imported

part 'user.g.dart';

@JsonSerializable()
class User {
      User();

  int id;
  String username;
  bool blocked;
  Address addresses; // Asigned type

  factory User.fromJson(Map<String,dynamic> json) => _$UserFromJson(json);

```

### Asign List<Type> variable

you can use `$[]` to specify the value to be List of Type of variable

_Source File_

`./jsons/user.json`

```js
{
  "id": 2,
  "username": "John Doe",
  "blocked": false,
  "addresses": "$address" // prefix $
}
```

_Generated_

`./lib/models/user.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

import 'address.dart'; // imported

part 'user.g.dart';

@JsonSerializable()
class User {
      User();

  int id;
  String username;
  bool blocked;
  List<Address> addresses; // Asigned List<Type>

  factory User.fromJson(Map<String,dynamic> json) => _$UserFromJson(json);

```
