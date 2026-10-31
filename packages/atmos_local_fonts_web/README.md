# atmos_local_fonts_web

Browser `LocalFontSource` for [Atom735](https://github.com/Atom735).

Русский: [README_RU.md](README_RU.md).

Uses [atmos_web_local_font_access_api](https://github.com/Atom735/atmos_dart_pubs/tree/main/packages/atmos_web_local_font_access_api)
(`queryLocalFonts` / `FontData.blob`).

## Install

```yaml
dependencies:
  atmos_local_fonts: ^0.1.0
  atmos_local_fonts_web: ^0.1.0
```

## Quick start

```dart
import 'package:atmos_local_fonts_web/atmos_local_fonts_web.dart';

Future<void> listFamilies() async {
  final source = WebLocalFontSource();
  if (!source.isSupported) return;
  final faces = await source.query();
  print(faces.first.family);
}
```

Call `query` from a user gesture. Chromium may prompt for permission.
Pair with [atmos_local_fonts_flutter](https://github.com/Atom735/atmos_dart_pubs/tree/main/packages/atmos_local_fonts_flutter)
to register the bytes.

## Platform

Chromium (Chrome, Edge) in a secure context. Elsewhere
`isSupported` is false and `query` throws
`LocalFontsUnsupportedException`. A denied prompt throws
`LocalFontsNotAllowedException`.

## License

MIT — see [LICENSE](LICENSE).
