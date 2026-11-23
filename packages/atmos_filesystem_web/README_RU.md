# atmos_filesystem_web

English: [README.md](README.md).

Браузерный адаптер **File System Access** для
[`atmos_filesystem`](https://pub.dev/packages/atmos_filesystem) от
[Atom735](https://github.com/Atom735).

Маппит URI `fsa:///relative/path` на выбранный пользователем directory handle.
`readFileRange` режет файл через `Blob.slice`.

## Установка

```yaml
dependencies:
  atmos_filesystem_web: ^0.1.1
```

## Быстрый старт

```dart
import 'package:atmos_filesystem/atmos_filesystem.dart';
import 'package:atmos_filesystem_web/atmos_filesystem_web.dart';

Future<void> main() async {
  final fs = AtmosFileSystem();
  await registerPickedDirectory(fs); // показывает directory picker

  final bytes = await fs.readFile(Uri.parse('fsa:///README.md'));
  print(bytes.length);
}
```

## Связанные пакеты

| Пакет | Роль |
|-------|------|
| [`atmos_filesystem`](https://pub.dev/packages/atmos_filesystem) | Портабельный FS API |
| [`atmos_web_files_system_access_api`](https://pub.dev/packages/atmos_web_files_system_access_api) | Низкоуровневые биндинги FSA |

## Лицензия

MIT — см. [LICENSE](LICENSE).
