# atmos_local_fonts

Portable **local font** model for Dart by [Atom735](https://github.com/Atom735).

Русский: [README_RU.md](README_RU.md).

A font face plus a source that can list faces. No browser and no Flutter
types: platform packages implement `LocalFontSource`.

## Install

```yaml
dependencies:
  atmos_local_fonts: ^0.1.0
```

## Quick start

```dart
import 'dart:typed_data';

import 'package:atmos_local_fonts/atmos_local_fonts.dart';

Future<Uint8List> bytes() async => Uint8List(0);

final source = MemoryLocalFontSource(<LocalFontFace>[
  LocalFontFace(
    family: 'Arial',
    fullName: 'Arial',
    postscriptName: 'ArialMT',
    style: 'Regular',
    readBytes: bytes,
  ),
]);

Future<void> main() async {
  final faces = await source.query();
  print(faces.single.family);
}
```

## Related

| Package | Role |
|---------|------|
| [atmos_local_fonts_web](https://github.com/Atom735/atmos_dart_pubs/tree/main/packages/atmos_local_fonts_web) | Browser source (Local Font Access API) |
| [atmos_local_fonts_flutter](https://github.com/Atom735/atmos_dart_pubs/tree/main/packages/atmos_local_fonts_flutter) | Register face bytes with Flutter |
| [atmos_web_local_font_access_api](https://github.com/Atom735/atmos_dart_pubs/tree/main/packages/atmos_web_local_font_access_api) | Low-level browser bindings |

## License

MIT — see [LICENSE](LICENSE).
