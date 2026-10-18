# atmos_filesystem

Portable, **VS Code–inspired** filesystem API for Dart by [Atom735](https://github.com/Atom735).

URI-based resources, capability flags, and a provider interface similar to
VS Code’s posix-like layer (`stat` / `readDirectory` / `readFile` / `writeFile` /
optional `open` · `read` · `write` · `close`) — without claiming full POSIX.1.

## Install

```yaml
dependencies:
  atmos_filesystem: ^0.1.0
```

## Quick start

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

## Related packages

| Package | Role |
|---------|------|
| [`atmos_filesystem_web`](https://pub.dev/packages/atmos_filesystem_web) | Browser adapter (File System Access API) |
| [`atmos_web_files_system_access_api`](https://pub.dev/packages/atmos_web_files_system_access_api) | Low-level FSA bindings |
| [`atmos_web_js_utils`](https://pub.dev/packages/atmos_web_js_utils) | JS Promise / property helpers |

## Example (Flutter web)

Pickers (directory / open / save) and `fsa://` read/write via `AtmosFileSystem`:

```bash
cd packages/atmos_filesystem/example
flutter pub get
flutter run -d chrome
```

## License

MIT — see [LICENSE](LICENSE).
