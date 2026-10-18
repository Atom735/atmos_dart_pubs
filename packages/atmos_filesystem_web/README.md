# atmos_filesystem_web

Browser **File System Access** adapter for
[`atmos_filesystem`](https://pub.dev/packages/atmos_filesystem) by
[Atom735](https://github.com/Atom735).

Maps `fsa:///relative/path` URIs onto a user-picked directory handle.

## Install

```yaml
dependencies:
  atmos_filesystem_web: ^0.1.0
```

## Quick start

```dart
import 'package:atmos_filesystem/atmos_filesystem.dart';
import 'package:atmos_filesystem_web/atmos_filesystem_web.dart';

Future<void> main() async {
  final fs = AtmosFileSystem();
  await registerPickedDirectory(fs); // shows directory picker

  final bytes = await fs.readFile(Uri.parse('fsa:///README.md'));
  print(bytes.length);
}
```

## Related

| Package | Role |
|---------|------|
| [`atmos_filesystem`](https://pub.dev/packages/atmos_filesystem) | Portable FS API |
| [`atmos_web_files_system_access_api`](https://pub.dev/packages/atmos_web_files_system_access_api) | Low-level FSA bindings |

## License

MIT — see [LICENSE](LICENSE).
