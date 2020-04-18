# json_to_model [![Pub Version](https://img.shields.io/pub/v/json_to_model?color=%2335d9ba&style=flat-square)](https://pub.dev/packages/json_to_model)

Command line tool for generating Dart models (json_serializable) from Json file.

_partly inspired by [json_model](https://github.com/flutterchina/json_model)._

## Installation

on `pubspec.yaml`

```yaml
dependencies:
  json_to_model: ^1.3.13
  build_runner: ^1.7.4
  json_serializable: ^3.2.5
  json_annotation: ^3.0.1
```

install using `pub get` command or if you using dart vscode/android studio, you can use install option.

## What?, Why?, How?

### What

Command line tool to convert `.json` files into `.dart` model files and finally will generate `.g.dart` file(json_serializable)

### Why

#### Problem

You might have a system or back-end REST app, and you want to build a dart app. you may start create models for your data. but to convert from Dart `Map` need extra work, so you can use `json_serializable`, but it just to let you handle data conversion, you still need to type it model by model, what if you have huge system that require huge amount of models. to write it all up might distress you.

#### Solution

This command line tool let your convert your existing `.json` files(that you might have) into dart(json_serializable) files

#### Why not just use the existing command line library `json_model` instead

The `json_model` is great, cool structure, but it doesnt have _recursive import_ which the feature that i want, and i want it automatically change variable to camelCase, i could write an issue and PR, but its hard to make a changes as it dont really have a clean code scalable structure, and have comments that i dont understand, and contributors last active on that repo is in June, i dont think i could wait any longer, so i made new one, some of core feature remain the same, but (may be) have a better structure.

### How

it run through your json file and find possible type, variable name, import uri, decorator and class name, and will write it into the templates.
Create/copy `.json` files into `./jsons/`(default) on root of your project, and run `pub run json_to_model`.

#### Example

```json
{
  "id": 2,
  "title": "Hello Guys!",
  "content": "$content",
  "tags": "$[]tag",
  "user": "$../user/user",
  "published": true
}
```

#### Command:

> `pub run json_to_model`

or

> `flutter pub run json_to_model`

**Output**

```dart
import 'package:json_annotation/json_annotation.dart';

import 'content.dart';
import 'tag.dart';
import '../user/user.dart';

part 'examples.g.dart';

@JsonSerializable()
class Examples {
      Examples();

  int id;
  String title;
  Content content;
  List<Tag> tags;
  User user;
  bool published;

  factory Examples.fromJson(Map<String,dynamic> json) => _$ExamplesFromJson(json);
  Map<String, dynamic> toJson() => _$ExamplesToJson(this);
}
```

## Contents

- [json_to_model ![Pub Version](https://pub.dev/packages/json_to_model)](#json_to_model-img-srchttpspubdevpackagesjson_to_model-altpub-version)
  - [Installation](#installation)
  - [What?, Why?, How?](#what-why-how)
    - [What](#what)
    - [Why](#why)
      - [Problem](#problem)
      - [Solution](#solution)
      - [Why not just use the existing command line library `json_model` instead](#why-not-just-use-the-existing-command-line-library-json_model-instead)
    - [How](#how)
      - [Example](#example)
      - [Command:](#command)
  - [Contents](#contents)
  - [Getting started](#getting-started)
  - [Usage](#usage)
  - [Examples](#examples)
    - [Basic](#basic)
      - [Source File](#source-file)
      - [Generated](#generated)
    - [Asign Type variable](#asign-type-variable)
      - [Source File](#source-file-1)
      - [Generated](#generated-1)
    - [Asign List<Type> variable](#asign-listtype-variable)
      - [Source File](#source-file-2)
      - [Generated](#generated-2)
    - [json_serializable JsonKey](#json_serializable-jsonkey)
      - [Source File](#source-file-3)
      - [Generated](#generated-3)
  - [Glossary](#glossary)
      - [Entities:](#entities)
      - [Template:](#template)
  - [Support](#support)
    - [Documentation](#documentation)
    - [Bug/Error](#bugerror)
    - [Feature request](#feature-request)
    - [Contribute](#contribute)
    - [Or](#or)

## Getting started

1. Create a directory `jsons`(default) at root of your project
2. Put all or Create json files inside `jsons` directory
3. run `pub run json_to_model`. or `flutter packages pub run json_to_model` flutter project

## Usage

this package will read `.json` file, and generate `.dart` file, asign the `type of the value` as `variable type` and `key` as the `variable name`.

| Description                                           | Expression                   | Input                                                                  | Output(declaration)                                          | Output(import)                                    |
| :---------------------------------------------------- | ---------------------------- | ---------------------------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------- |
| declare type depends on the json value                | {`...`:`any type`}           | `{"id": 1, "message':'hello world'}`,                                  | `int id;`<br>`String message;`                               | -                                                 |
| import model and asign type                           | {`...`:`'$value'`}           | `{"auth':'$user'}`                                                     | `User auth;`                                                 | `import 'user.dart'`                              |
| import recursively                                    | {`...`:`'$../pathto/value'`} | `{"price':'$../product/price'}`                                        | `Price price;`                                               | `import '../product/price.dart'`                  |
| asign list of type and import (can also be recursive) | {`...`:`'$[]value'`}         | `{"addreses':'$[]address'}`                                            | `List<Address> addreses;`                                    | `import 'address.dart'`                           |
| use `json_annotation` `@JsonKey`                      | {`'@JsonKey(...)'`:`...`}    | `{"@JsonKey(ignore: true) dynamic': 'val'}`                            | `@JsonKey(ignore: true) dynamic val;`                        | -                                                 |
| import other library(input value can be array)        | {`'@import'`:`...`}          | `{"@import':'package:otherlibrary/otherlibrary.dart'}`                 | -                                                            | `import 'package:otherlibrary/otherlibrary.dart'` |
| write code independentally(experimental)              | {`'@_...'`:`...`}            | `{"@_ // any code here':',its like an escape to write your own code'}` | `// any code here,its like an escape to write your own code` | -                                                 |

## Examples

you can copy json below and generate using `pub run json_to_model` command

### Basic

#### Source File

`./jsons/user.json`

```js
{
  "id": 2,
  "username": "John Doe",
  "blocked": false
}
```

#### Generated

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

#### Source File

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

#### Generated

`./lib/models/user.dart`

```dart
import 'package:json_annotation/json_annotation.dart';
import 'address.dart';  // automatic import
part 'user.g.dart';

@JsonSerializable()
class User {
  User();
  int id;
  String username;
  bool blocked;
  Address addresses;  // $address converted to Address as type
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

### Asign List<Type> variable

you can use `$[]` to specify the value to be List of Type of variable

#### Source File

`./jsons/user.json`

```js
{
  "id": 2,
  "username": "John Doe",
  "blocked": false,
  "addresses": "$[]address" // prefix $[]
}
```

#### Generated

`./lib/models/user.dart`

```dart
import 'package:json_annotation/json_annotation.dart';
import 'address.dart'; // write address as import
part 'user.g.dart';

@JsonSerializable()
class User {
  User();
  int id;
  String username;
  bool blocked;
  List<Address> addresses; // List of Type
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

### json_serializable JsonKey

you can use `@JsonKey` in `key` to specify @JsonKey

#### Source File

`./jsons/cart.json`

```js
{
  "@JsonKey(ignore: true) dynamic": "md", //jsonKey alias
  "@JsonKey(name: '+1') int": "loved", //jsonKey alias
  "name": "wendux",
  "age": 20
}
```

#### Generated

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

## Glossary

#### Entities:

- `imports` import statement strings. Got from `.json` value with prefix `$`, suffixed it with `.dart` interpolate into `import '$import';\n`.
- `fileName` file name. Got from `.json` value with prefix `$`, but the non-word caracter(`\W`) being removed, turn it in`toCamelCase()`
- `className` class name. Basically `fileName` but turned in`toTitleCase()`.
- `declarations` declaration statement strings. basically list of [`DartDeclaration`](lib/core/dart_declaration.dart) object and turned it in`toString()` .

#### Template:

```dart
String defaultTemplate({
    imports,
    fileName,
    className,
    declarations,
  }) =>  """
import 'package:json_annotation/json_annotation.dart';

$imports

part '$fileName.g.dart';

@JsonSerializable()
class $className {
      $className();

  $declarations

  factory $className.fromJson(Map<String,dynamic> json) => _\$${className}FromJson(json);
  Map<String, dynamic> toJson() => _\$${className}ToJson(this);
}""";
```

_for more info read [model_template.dart](/lib/core/model_template.dart)_

## Support

I'm open contribution for documentation, bug report, code maintenance, etc. properly submit an issue or send a pull request.

### Documentation

any typos, grammar error, unintended word, or ambiguous meaning. you can PR. _or maybe create an issue_. **this is the one i really need your help**

### Bug/Error

any bugs, unintended word comments, confusing variable naming. you can create an issue, _but also a PR really appreciated_.

### Feature request

any missing feature, cool feature, like prefix json key command, or dynamic changing. you can create an issue, or _write a dart extension for it_.

### Contribute

if you want to help maintain this library, kindly read [Contributing.md](CONTRIBUTING.md).

### Or

you can buy me a coffee:

[![Donate Now](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=UNME938XE8XJC&source=url)<br>
[<img src='https://www.iklanlah.com/images/toyyibpay-widget-sm-p.png' alt='ToyyibPay' height='60'/>](https://toyyibpay.com/fadhilx-open-source)<br>
Thanks for your support.
