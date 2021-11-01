# json_to_model [![Pub Version](https://img.shields.io/pub/v/json_to_model?color=%2335d9ba&style=flat-square)](https://pub.dev/packages/json_to_model)

Command line tool for generating Dart models (json_serializable) from Json file.

_inspired by [json_model](https://github.com/flutterchina/json_model)._

_based of the [json_to_model](https://pub.dev/packages/json_to_model)_

## Contents

  - [Features](#features)
  - [Installation](#installation)
  - [What does this library do](#what-does-this-library-do)
    - [Get started](#get-started)
    - [Examples](#examples)
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
  json_to_model: ^3.0.1
  quiver: ^3.0.1+1
```

install using `pub get` command or if you using dart vscode/android studio, you can use install option.

## What does this library do

Command line tool to convert `.json` files into immutable `.dart` models.

### Get started

The command will run through your json files and find possible type, variable name, import uri, decorator and class name, and will write it into the templates.

Create/copy `.json` files into `./jsons/`(default) on root of your project, and run `flutter pub run json_to_model`.

### Examples

**Input**
Consider this files named product.json and employee.json

product.json
```json
{
  "id": "123",
  "caseId?": "123",
  "startDate?": "2020-08-08",
  "endDate?": "2020-10-10",
  "placementDescription?": "Description string"
}
```

eployee.json
```json
{
  "id": "123",
  "displayName?": "Jan Jansen",
  "@ignore products?": "$[]product"
}
```

**Output**
This will generate this product.dart and employee.dart

product.dart

```dart
import 'package:flutter/foundation.dart';

@immutable
class Product {

  const Product({
    required this.id,
    this.caseId,
    this.startDate,
    this.endDate,
    this.placementDescription,
  });

  final String id;
  final String? caseId;
  final String? startDate;
  final String? endDate;
  final String? placementDescription;

  factory Product.fromJson(Map<String,dynamic> json) => Product(
    id: json['id'] as String,
    caseId: json['caseId'] != null ? json['caseId'] as String : null,
    startDate: json['startDate'] != null ? json['startDate'] as String : null,
    endDate: json['endDate'] != null ? json['endDate'] as String : null,
    placementDescription: json['placementDescription'] != null ? json['placementDescription'] as String : null
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'caseId': caseId,
    'startDate': startDate,
    'endDate': endDate,
    'placementDescription': placementDescription
  };

  Product clone() => Product(
    id: id,
    caseId: caseId,
    startDate: startDate,
    endDate: endDate,
    placementDescription: placementDescription
  );


  Product copyWith({
    String? id,
    String? caseId,
    String? startDate,
    String? endDate,
    String? placementDescription
  }) => Product(
    id: id ?? this.id,
    caseId: caseId ?? this.caseId,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    placementDescription: placementDescription ?? this.placementDescription,
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is Product && id == other.id && caseId == other.caseId && startDate == other.startDate && endDate == other.endDate && placementDescription == other.placementDescription;

  @override
  int get hashCode => id.hashCode ^ caseId.hashCode ^ startDate.hashCode ^ endDate.hashCode ^ placementDescription.hashCode;
}

```

eployee.dart
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


**Input**
Consider this file named location.json

```json
{
    "locationId?": 93,
    "locationTypeId?": "1234",
    "updatedAt": "@datetime",
    "name?": "Lunet 10a, Veenendaal",
    "confidential?": false,
    "locationType?": "@enum:INSIDE,OUTSIDE,CLIENT,HOME,ROOM,UNKNOWN",
    "point?": {
        "longitude": 58.1234,
        "latitude": 12.123
    }
}
```

**Output**
This will generate this location.dart

```dart
import 'package:flutter/foundation.dart';

@immutable
class Location {

  const Location({
    this.locationId,
    this.locationTypeId,
    required this.updatedAt,
    this.name,
    this.confidential,
    this.locationType,
    this.point,
  });

  final int? locationId;
  final String? locationTypeId;
  final DateTime updatedAt;
  final String? name;
  final bool? confidential;
  LocationLocationTypeEnum
    get locationLocationTypeEnum => _locationLocationTypeEnumValues.map[locationType]!;
  final String? locationType;
  final Point? point;

  factory Location.fromJson(Map<String,dynamic> json) => Location(
    locationId: json['locationId'] != null ? json['locationId'] as int : null,
    locationTypeId: json['locationTypeId'] != null ? json['locationTypeId'] as String : null,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    name: json['name'] != null ? json['name'] as String : null,
    confidential: json['confidential'] != null ? json['confidential'] as bool : null,
    locationType: json['locationType'] != null ? json['locationType'] as String : null,
    point: json['point'] != null ? Point.fromJson(json['point'] as Map<String, dynamic>) : null
  );

  Map<String, dynamic> toJson() => {
    'locationId': locationId,
    'locationTypeId': locationTypeId,
    'updatedAt': updatedAt.toIso8601String(),
    'name': name,
    'confidential': confidential,
    'locationType': _locationLocationTypeEnumValues.reverse[locationType],
    'point': point?.toJson()
  };

  Location clone() => Location(
    locationId: locationId,
    locationTypeId: locationTypeId,
    updatedAt: updatedAt,
    name: name,
    confidential: confidential,
    locationType: locationType,
    point: point?.clone()
  );

  Location copyWith({
    int? locationId,
    String? locationTypeId,
    DateTime? updatedAt,
    String? name,
    bool? confidential,
    String? locationType,
    Point? point
  }) => Location(
    locationId: locationId ?? this.locationId,
    locationTypeId: locationTypeId ?? this.locationTypeId,
    updatedAt: updatedAt ?? this.updatedAt,
    name: name ?? this.name,
    confidential: confidential ?? this.confidential,
    locationType: locationType ?? this.locationType,
    point: point ?? this.point,
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is Location && locationId == other.locationId && locationTypeId == other.locationTypeId && updatedAt == other.updatedAt && name == other.name && confidential == other.confidential && locationType == other.locationType && point == other.point;

  @override
  int get hashCode => locationId.hashCode ^ locationTypeId.hashCode ^ updatedAt.hashCode ^ name.hashCode ^ confidential.hashCode ^ locationType.hashCode ^ point.hashCode;
}

enum LocationLocationTypeEnum { INSIDE, OUTSIDE, CLIENT, HOME, ROOM, UNKNOWN }

extension LocationLocationTypeEnumEx on LocationLocationTypeEnum{
  String? get value => _locationLocationTypeEnumValues.reverse[this];
}

final _locationLocationTypeEnumValues = _LocationLocationTypeEnumConverter({
  'INSIDE': LocationLocationTypeEnum.INSIDE,
  'OUTSIDE': LocationLocationTypeEnum.OUTSIDE,
  'CLIENT': LocationLocationTypeEnum.CLIENT,
  'HOME': LocationLocationTypeEnum.HOME,
  'ROOM': LocationLocationTypeEnum.ROOM,
  'UNKNOWN': LocationLocationTypeEnum.UNKNOWN,
});

class _LocationLocationTypeEnumConverter<String, O> {
  final Map<String, O> map;
  Map<O, String>? reverseMap;

  _LocationLocationTypeEnumConverter(this.map);

  Map<O, String> get reverse => reverseMap ??= map.map((k, v) => MapEntry(v, k));
}

@immutable
class Point {

  const Point({
    required this.longitude,
    required this.latitude,
  });

  final double longitude;
  final double latitude;

  factory Point.fromJson(Map<String,dynamic> json) => Point(
    longitude: json['longitude'] as double,
    latitude: json['latitude'] as double
  );

  Map<String, dynamic> toJson() => {
    'longitude': longitude,
    'latitude': latitude
  };

  Point clone() => Point(
    longitude: longitude,
    latitude: latitude
  );


  Point copyWith({
    double? longitude,
    double? latitude
  }) => Point(
    longitude: longitude ?? this.longitude,
    latitude: latitude ?? this.latitude,
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is Point && longitude == other.longitude && latitude == other.latitude;

  @override
  int get hashCode => longitude.hashCode ^ latitude.hashCode;
}
```



## Getting started

1. Create a directory `jsons`(default) at root of your project
2. Put all or Create json files inside `jsons` directory
3. run `pub run json_to_model`. or `flutter packages pub run json_to_model` flutter project

## Usage

this package will read `.json` file, and generate `.dart` file, asign the `type of the value` as `variable type` and `key` as the `variable name`.

| Description | Expression | Input (Example) | Output(declaration) | Output(import) |
| :- | - | - | - | - |
| declare type depends on the json value | {`...`:`any type`} | `{"id": 1, "message":"hello world"}`, | `int id;`<br>`String message;` |  |
| import model and asign type | {`...`:`"$value"`} | `{"auth":"$user"}` | `User auth;` | `import 'user.dart'` |
| import from path | {`...`:`"$pathto/value"`} | `{"price":"$product/price"}` | `Price price;` | `import '../product/price.dart'` |
| asign list of type and import (can also be recursive) | {`...`:`"$[]value"`} | `{"addreses":"$[]address"}` | `List<Address> addreses;` | `import 'address.dart'` |
| import other library(input value can be array) | {`"@import"`:`...`} | `{"@import":"package:otherlibrary/otherlibrary.dart"}` | | `import 'package:otherlibrary/otherlibrary.dart'` |
| Datetime type | {`...`:`"@datetime"`} | `{"createdAt": "@datetime:2020-02-15T15:47:51.742Z"}` | `DateTime createdAt;` | |
| Enum type | {`...`:`"@enum:(folowed by enum separated by ',')"`} | `{"@import":"@enum:admin,app_user,normal"}` | `enum UserTypeEnum { Admin, AppUser, Normal }` |
| Enum type with values  {`...`:`"@enum:(folowed by enum separated by ',')"`} | `{"@import":"@enum:admin(0),app_user(1),normal(2)"}`                            | `enum UserTypeEnum { Admin, AppUser, Normal }`| |
