# atmos_parser

Русский: [README_RU.md](README_RU.md).

Composable typed parsers with context and warnings for Dart by Atom735.

## Install

```yaml
dependencies:
  atmos_parser: ^0.1.0
```

## Quick start

```dart
import 'package:atmos_parser/atmos_parser.dart';

class User {
  User({required this.name, required this.age});
  final String name;
  final int age;
}

class UserParser extends AtmosParser<User> {
  const UserParser();

  @override
  User? parse(Object? input) {
    if (input is User?) return input;
    return User(
      name: v('name') ?? '',
      age: v('age') ?? 0,
    );
  }

  @override
  Object? serialize(User? input) {
    if (input == null) return null;
    return {
      'name': s(input.name),
      'age': s(input.age),
    };
  }
}
```

## License

BSD 3-Clause. See [LICENSE](LICENSE).
