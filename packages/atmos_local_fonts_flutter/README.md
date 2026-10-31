# atmos_local_fonts_flutter

Registers local font files with Flutter by [Atom735](https://github.com/Atom735).

Русский: [README_RU.md](README_RU.md).

Takes any [atmos_local_fonts](https://github.com/Atom735/atmos_dart_pubs/tree/main/packages/atmos_local_fonts)
`LocalFontSource`, reads face bytes, and loads them with `FontLoader`.
`isLoading` is true while a query or a load is running.

## Install

```yaml
dependencies:
  atmos_local_fonts: ^0.1.0
  atmos_local_fonts_flutter: ^0.1.0
  atmos_local_fonts_web: ^0.1.0
```

## Quick start

```dart
import 'package:atmos_local_fonts_flutter/atmos_local_fonts_flutter.dart';
import 'package:atmos_local_fonts_web/atmos_local_fonts_web.dart';
import 'package:flutter/widgets.dart';

final fonts = FlutterLocalFonts(WebLocalFontSource());

Future<void> useArial() async {
  if (!fonts.isSupported) return;
  await fonts.query();
  await fonts.loadFamily('Arial');
  // Text(style: TextStyle(fontFamily: 'Arial'))
}

Widget spinner() {
  return ListenableBuilder(
    listenable: fonts,
    builder: (context, child) {
      if (fonts.isLoading) return child!;
      return const SizedBox.shrink();
    },
    child: const Text('…'),
  );
}
```

`isLoaded` is per face (PostScript name) and survives a later `query`
in the same session.

`loadFamily` reads every installed face of that family (regular, bold,
italic, and the rest), not a single file. Load one family at a time.

On the web, call `query` from a user gesture.

## Example

```bash
cd packages/atmos_local_fonts_flutter/example
flutter run -d chrome
```

The demo lists system families on the left and renders sample text
(Lorem, pangrams, alphabet, or a custom field) with the selected family.

## License

MIT — see [LICENSE](LICENSE).
