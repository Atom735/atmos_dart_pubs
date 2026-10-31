# atmos_web_local_font_access_api

Dart bindings for the browser **[Local Font Access API](https://developer.mozilla.org/en-US/docs/Web/API/Local_Font_Access_API)** by [Atom735](https://github.com/Atom735).

Русский: [README_RU.md](README_RU.md).

Low-level wrappers over `queryLocalFonts` and `FontData.blob()`. Built on
[`atmos_web_js_utils`](https://pub.dev/packages/atmos_web_js_utils).

## Install

```yaml
dependencies:
  atmos_web_local_font_access_api: ^0.1.0
```

## Quick start

```dart
import 'package:atmos_web_local_font_access_api/atmos_web_local_font_access_api.dart';

Future<void> listFonts() async {
  if (!isLocalFontAccessApiSupported) return;
  final fonts = await queryLocalFonts();
  print(fonts.first.family);
}
```

## Platform

Chromium-only (Chrome, Edge), secure context, and a user gesture — the
browser may prompt for permission. On VM and other browsers
`isLocalFontAccessApiSupported` is false and calls throw
`LocalFontAccessException`. A denied prompt throws
`LocalFontAccessNotAllowedException`.

## Related

| Package | Role |
|---------|------|
| [atmos_local_fonts](https://github.com/Atom735/atmos_dart_pubs/tree/main/packages/atmos_local_fonts) | Portable face / source model |
| [atmos_local_fonts_web](https://github.com/Atom735/atmos_dart_pubs/tree/main/packages/atmos_local_fonts_web) | This API behind `LocalFontSource` |
| [atmos_local_fonts_flutter](https://github.com/Atom735/atmos_dart_pubs/tree/main/packages/atmos_local_fonts_flutter) | Register bytes with Flutter |

## License

MIT — see [LICENSE](LICENSE).
