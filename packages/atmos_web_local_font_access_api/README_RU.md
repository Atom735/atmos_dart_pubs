# atmos_web_local_font_access_api

Dart-привязки браузерного **[Local Font Access API](https://developer.mozilla.org/en-US/docs/Web/API/Local_Font_Access_API)** от [Atom735](https://github.com/Atom735).

English: [README.md](README.md).

Низкоуровневые обёртки над `queryLocalFonts` и `FontData.blob()`. Построены на
[`atmos_web_js_utils`](https://pub.dev/packages/atmos_web_js_utils).

## Установка

```yaml
dependencies:
  atmos_web_local_font_access_api: ^0.1.0
```

## Быстрый старт

```dart
import 'package:atmos_web_local_font_access_api/atmos_web_local_font_access_api.dart';

Future<void> listFonts() async {
  if (!isLocalFontAccessApiSupported) return;
  final fonts = await queryLocalFonts();
  print(fonts.first.family);
}
```

## Платформа

Только Chromium (Chrome, Edge), secure context и жест пользователя —
браузер может запросить разрешение. На VM и в других браузерах
`isLocalFontAccessApiSupported` равен false, вызовы бросают
`LocalFontAccessException`. Отказ в разрешении —
`LocalFontAccessNotAllowedException`.

## Связанные пакеты

| Пакет | Роль |
|-------|------|
| [atmos_local_fonts](https://github.com/Atom735/atmos_dart_pubs/tree/main/packages/atmos_local_fonts) | Переносимая модель начертания и источника |
| [atmos_local_fonts_web](https://github.com/Atom735/atmos_dart_pubs/tree/main/packages/atmos_local_fonts_web) | Этот API за `LocalFontSource` |
| [atmos_local_fonts_flutter](https://github.com/Atom735/atmos_dart_pubs/tree/main/packages/atmos_local_fonts_flutter) | Регистрация байтов во Flutter |

## Лицензия

MIT — см. [LICENSE](LICENSE).
