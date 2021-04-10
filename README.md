# apn_json2model [![Pub Version](https://img.shields.io/pub/v/apn_json2model?color=%2335d9ba&style=flat-square)](https://pub.dev/packages/apn_json2model)

Command line tool for generating Dart models (json_serializable) from Json file.

_inspired by [json_model](https://github.com/flutterchina/json_model)._

_based of the [json_to_model](https://pub.dev/packages/json_to_model)_

## Contents

  - [Features](#features)
  - [Installation](#installation)
  - [What does this library do](#what-does-this-library-do)
    - [How](#how)
      - [Example](#example)
      - [Command:](#command)
  - [Getting started](#getting-started)
  - [Usage](#usage)


## Features

| Feature                   | Status   |
| :----                     |     ---: |
| Null safety               |       ✅ |
| toJson/fromJson           |       ✅ |
| immutable classes         |       ✅ |
| copyWith generation       |       ✅ |
| clone and deepclone       |       ✅ |
| nested json classes       |       ✅ |
| enum support              |       ✅ |

## Installation

on `pubspec.yaml`

```yaml
dev_dependencies:
  apn_json2model: ^2.2.0
```

install using `pub get` command or if you using dart vscode/android studio, you can use install option.

## What does this library do

**Command line tool to convert `.json` files into immutable `.dart` models.**

### How

it run through your json file and find possible type, variable name, import uri, decorator and class name, and will write it into the templates.
Create/copy `.json` files into `./jsons/`(default) on root of your project, and run `pub run apn_json2model`.

#### Example
Consider this file named employee.json

```json
{
  "id": "123",
  "displayName?": "Jan Jansen",
  "@ignore products?": "$[]product"
}
```

#### Command:

> `pub run apn_json2model`

or

> `flutter pub run apn_json2model`

**Output**
This will generate this employee.dart

```dart
import 'package:flutter/foundation.dart';
import 'product.dart';

@immutable
class Employee {

  const Employee({
    required this.id,
    this.displayName,
    this.products,
  });

  final String id;
  final String? displayName;
  final List<Product>? products;

  factory Employee.fromJson(Map<String,dynamic> json) => Employee(
    id: json['id'] as String,
    displayName: json['displayName'] != null ? json['displayName'] as String : null
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName
  };

  Employee clone() => Employee(
    id: id,
    displayName: displayName,
    products: products?.map((e) => e.clone()).toList()
  );


  Employee copyWith({
    String? id,
    String? displayName,
    List<Product>? products
  }) => Employee(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    products: products ?? this.products,
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is Employee && id == other.id
    && displayName == other.displayName
    && products == other.products;

  @override
  int get hashCode => id.hashCode ^
    displayName.hashCode ^
    products.hashCode;
}
```

## Getting started

1. Create a directory `jsons`(default) at root of your project
2. Put all or Create json files inside `jsons` directory
3. run `pub run apn_json2model`. or `flutter packages pub run apn_json2model` flutter project

## Usage

this package will read `.json` file, and generate `.dart` file, asign the `type of the value` as `variable type` and `key` as the `variable name`.

| Description | Expression | Input (Example) | Output(declaration) | Output(import) |
| :- | - | - | - | - |
| declare type depends on the json value | {`...`:`any type`} | `{"id": 1, "message":"hello world"}`, | `int id;`<br>`String message;` |  |
| import model and asign type | {`...`:`"$value"`} | `{"auth":"$user"}` | `User auth;` | `import 'user.dart'` |
| import from path | {`...`:`"$../pathto/value"`} | `{"price":"$../product/price"}` | `Price price;` | `import '../product/price.dart'` |
| asign list of type and import (can also be recursive) | {`...`:`"$[]value"`} | `{"addreses":"$[]address"}` | `List<Address> addreses;` | `import 'address.dart'` |
| import other library(input value can be array) | {`"@import"`:`...`} | `{"@import":"package:otherlibrary/otherlibrary.dart"}` | | `import 'package:otherlibrary/otherlibrary.dart'` |
| Datetime type | {`...`:`"@datetime"`} | `{"createdAt": "@datetime:2020-02-15T15:47:51.742Z"}` | `DateTime createdAt;` | |
| Enum type | {`...`:`"@enum:(folowed by enum separated by ',')"`} | `{"@import":"@enum:admin,app_user,normal"}` | `enum UserTypeEnum { Admin, AppUser, Normal }` |
| Enum type with values  {`...`:`"@enum:(folowed by enum separated by ',')"`} | `{"@import":"@enum:admin(0),app_user(1),normal(2)"}`                            | `enum UserTypeEnum { Admin, AppUser, Normal }`| |
