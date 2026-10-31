# atmos_local_fonts_web

Браузерный `LocalFontSource` от [Atom735](https://github.com/Atom735).

English: [README.md](README.md).

Построен на [atmos_web_local_font_access_api](https://github.com/Atom735/atmos_dart_pubs/tree/main/packages/atmos_web_local_font_access_api)
(`queryLocalFonts` / `FontData.blob`).

## Установка

```yaml
dependencies:
  atmos_local_fonts: ^0.1.0
  atmos_local_fonts_web: ^0.1.0
```

## Быстрый старт

```dart
import 'package:atmos_local_fonts_web/atmos_local_fonts_web.dart';

Future<void> listFamilies() async {
  final source = WebLocalFontSource();
  if (!source.isSupported) return;
  final faces = await source.query();
  print(faces.first.family);
}
```

`query` нужно вызывать из жеста пользователя. Chromium может запросить
разрешение. Байты во Flutter регистрирует
[atmos_local_fonts_flutter](https://github.com/Atom735/atmos_dart_pubs/tree/main/packages/atmos_local_fonts_flutter).

## Платформа

Только Chromium (Chrome, Edge) и secure context. В остальных окружениях
`isSupported` равен false, а `query` бросает
`LocalFontsUnsupportedException`. Отказ в разрешении —
`LocalFontsNotAllowedException`.

## Лицензия

MIT — см. [LICENSE](LICENSE).
