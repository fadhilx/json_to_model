## 3.2.4

- Added isJsonable property to dart time to fix .toJson/.fromJson generation on unsupported types
## 3.2.3

- Loosen factory type requirements. If type is not found the factory will return a `null` value
- Fixed a bug in the @import declaration
- Added test for @extends, @import and @override
- Fix fromJson generation on type override
- Add test for @mixin 
- Remove const in constructor when using @extends of @mixin

## 3.2.0

- Promote beta
- Fix double fromJson convertion when the input is an int

## 3.1.8+beta

- Fix bug in imports of nested models

## 3.1.8

- Improve 'Unable to infer type' error when adding a `null` value in a json.

## 3.1.7

- Add support for @timestamp to convert unix timestamps automatically from int to DateTime and back

## 3.1.6

- Guess model name of list objects by their parent key (genres: [{}, {}] will singularize genres and create a subclass called Genre)

## 3.1.5

- Add support for #num

## 3.1.4

- Convert string to with toString instead of `as String` for better conversion if value is accidentally an int.
- Fix lint warnings

## 3.1.3

- Make checkOptional default value a builder, so we can avoid infinite recursion in fake models.

## 3.0.3

- Fix bug in double faker in test factories

## 3.0.2

- Add double support in factories (Thanks to @saad4software) (#23)
- Fix quiver error message when thats missing (#27)

## 3.0.1

- Fix typo in missing dependencies error message

## 3.0.0

- Stable 3.0
- Generate fakers to use in tests
- Add explicit type declaration with value prefix `#`

## 3.0.0-beta

- Pre-release onder beta flag
- Major internal cleanup
- Added support for creating mocks backed with faker
- Breaking change in copyWith so we can support Optional.of(null) in copyWith (and in mocks)

## 2.3.1

- Use enum value type as return type for value getter

## 2.3.0

- Preserve original case for fromJson and toJson

## 2.2.7

- Bugfix in fromJson/toJson/clone list conversions when values in list are primitives

## 2.2.5

- Bugfix in fromJson list deserialisation

## 2.2.4

- Bugfix in toJson enum serialisation

## 2.2.3

- Make generated enum property nullable if the linked property is nullable

## 2.2.2

- Drop all unused dependencies
- Speed up generation with a factor of 10

## 2.2.1

- Fixed a generating null-safe code
- Added @ignore option to exclude that declaration from toJson/fromJson

## 2.1.0-nullsafety

- Dropped **json_serializable** and make toJson and fromJson ourselves

## 2.0.0-nullsafety

- Converted code to nullsafety. To soon for enabling sound null safety because almost all dependencies are not ready yet.
- Generated code is now also compatible with nullsafety (Add ? to property key to indicate nullability)
- All generated models are now @immutable
- Generated constructors are now different because we have immutable classes and final properties

## 1.6.1

- Add basic support for nested json models (fixed imports for used classes)

## 1.6.0

- Upgrade build_runner and build_runner_core

## 1.5.6

- Ignore generated enum types in toJson

## 1.5.5

- Support for Flutter 1.22 (Updated build dependencies)

## 1.5.3

- Allow nullable support for **.clone()** method

## 1.5.2

- Make toJson explicitToJson: true to always call nested classes `toJson` method.

## 1.5.1

- Bugfix in multiple @imports via a list

## 1.5.0

- Support for @extends, @mixin and @override
- Some minor improvements and bugfixes

## 1.4.0

- Enum support

## 1.3.13

- Better usage peek on doc

## 1.3.12

- fix file .g.dart not generated

## 1.3.11

- fix TitleCase error on className

## 1.2.0

- rename directory `models` to `core

## 1.0.0

- Initial version, created by Stagehand

