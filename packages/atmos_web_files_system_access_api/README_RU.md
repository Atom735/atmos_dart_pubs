# atmos_web_files_system_access_api

English: [README.md](README.md).

Dart-биндинги браузерного
**[File System Access API](https://developer.mozilla.org/en-US/docs/Web/API/File_System_Access_API)**
от [Atom735](https://github.com/Atom735).

Низкоуровневые обёртки над пикерами, handles и writable streams. Построены на
[`atmos_web_js_utils`](https://pub.dev/packages/atmos_web_js_utils).

## Установка

```yaml
dependencies:
  atmos_web_files_system_access_api: ^0.1.0
```

## Быстрый старт

```dart
import 'package:atmos_web_files_system_access_api/atmos_web_files_system_access_api.dart';

Future<void> openFolder() async {
  if (!isFileSystemAccessApiSupported) return;
  final dir = await showDirectoryPicker();
  print(dir.name);
}
```

## Платформа

Нужен Chromium-based браузер (или другой движок с FSA).
На VM / неподдерживаемых браузерах API бросает или сообщает unsupported.

## Связанные пакеты

| Пакет | Роль |
|-------|------|
| [`atmos_filesystem_web`](https://pub.dev/packages/atmos_filesystem_web) | Высокоуровневый адаптер `AtmosFileSystem` |
| [`atmos_web_js_utils`](https://pub.dev/packages/atmos_web_js_utils) | Хелперы JS interop |

## Лицензия

MIT — см. [LICENSE](LICENSE).
