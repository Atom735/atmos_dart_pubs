# atmos_web_files_system_access_api

Dart bindings for the browser **[File System Access API](https://developer.mozilla.org/en-US/docs/Web/API/File_System_Access_API)** by [Atom735](https://github.com/Atom735).

Low-level wrappers over pickers, handles, and writable streams. Built on
[`atmos_web_js_utils`](https://pub.dev/packages/atmos_web_js_utils).

## Install

```yaml
dependencies:
  atmos_web_files_system_access_api: ^0.1.0
```

## Quick start

```dart
import 'package:atmos_web_files_system_access_api/atmos_web_files_system_access_api.dart';

Future<void> openFolder() async {
  if (!isFileSystemAccessApiSupported) return;
  final dir = await showDirectoryPicker();
  print(dir.name);
}
```

## Platform

Requires a Chromium-based browser (or another engine that implements FSA).
On VM / unsupported browsers the API throws or reports unsupported.

## Related

| Package | Role |
|---------|------|
| [`atmos_filesystem_web`](https://pub.dev/packages/atmos_filesystem_web) | Higher-level `AtmosFileSystem` adapter |
| [`atmos_web_js_utils`](https://pub.dev/packages/atmos_web_js_utils) | JS interop helpers |

## License

MIT — see [LICENSE](LICENSE).
