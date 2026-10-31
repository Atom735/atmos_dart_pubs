# atmos_local_fonts_flutter

Регистрация файлов локальных шрифтов во Flutter от [Atom735](https://github.com/Atom735).

English: [README.md](README.md).

Берёт любой `LocalFontSource` из
[atmos_local_fonts](https://github.com/Atom735/atmos_dart_pubs/tree/main/packages/atmos_local_fonts),
читает байты начертаний и загружает их через `FontLoader`.
`isLoading` равен true, пока идёт запрос списка или загрузка.

## Установка

```yaml
dependencies:
  atmos_local_fonts: ^0.1.0
  atmos_local_fonts_flutter: ^0.1.0
  atmos_local_fonts_web: ^0.1.0
```

## Быстрый старт

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

`isLoaded` относится к одному начертанию (PostScript-имя) и сохраняется
при следующем `query` в той же сессии.

`loadFamily` читает все установленные начертания семейства (regular, bold,
italic и остальные), а не один файл. Загружайте по одному семейству.

В браузере `query` нужно вызывать из жеста пользователя.

## Пример

```bash
cd packages/atmos_local_fonts_flutter/example
flutter run -d chrome
```

Демо показывает системные семейства слева и рисует образец текста
(Lorem, панграммы, алфавит или своё поле) выбранным шрифтом.

## Лицензия

MIT — см. [LICENSE](LICENSE).
