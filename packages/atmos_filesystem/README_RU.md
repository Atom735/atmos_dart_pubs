# atmos_filesystem

English: [README.md](README.md).

Портабельный filesystem API в духе **VS Code** для Dart от [Atom735](https://github.com/Atom735).

Ресурсы по URI, флаги capabilities и интерфейс провайдера, похожий на
posix-подобный слой VS Code (`stat` / `readDirectory` / `readFile` / `writeFile` /
опционально `open` · `read` · `write` · `close`) — без претензии на полный POSIX.1.
`readFileRange` читает срез; реализация по умолчанию всё ещё загружает
файл целиком.

## Установка

```yaml
dependencies:
  atmos_filesystem: ^0.1.1
```

## Быстрый старт

```dart
import 'dart:typed_data';

import 'package:atmos_filesystem/atmos_filesystem.dart';

Future<void> main() async {
  final fs = AtmosFileSystem()
    ..register(MemoryFileSystemProvider());

  await fs.createDirectory(Uri.parse('mem:///docs'));
  await fs.writeFile(
    Uri.parse('mem:///docs/hi.txt'),
    Uint8List.fromList('hello'.codeUnits),
  );
  print(await fs.readDirectory(Uri.parse('mem:///docs')));
}
```

## Связанные пакеты

| Пакет | Роль |
|-------|------|
| [`atmos_filesystem_web`](https://pub.dev/packages/atmos_filesystem_web) | Браузерный адаптер (File System Access API) |
| [`atmos_web_files_system_access_api`](https://pub.dev/packages/atmos_web_files_system_access_api) | Низкоуровневые биндинги FSA |
| [`atmos_web_js_utils`](https://pub.dev/packages/atmos_web_js_utils) | Хелперы JS Promise / свойств |

## Пример (Flutter web)

Пикеры (directory / open / save) и чтение/запись `fsa://` через `AtmosFileSystem`:

```bash
cd packages/atmos_filesystem/example
flutter pub get
flutter run -d chrome
```

## Лицензия

MIT — см. [LICENSE](LICENSE).
