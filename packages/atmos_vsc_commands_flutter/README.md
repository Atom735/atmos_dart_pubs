# atmos_vsc_commands_flutter

Flutter layer for [`atmos_vsc_commands`](../atmos_vsc_commands) by
[Atom735](https://github.com/Atom735).

Русский: [README_RU.md](README_RU.md).

- **`VscCommandHost`** — canonical path: keybindings Host →
  `VscCommandService.executeMatch` (chords + `when`)
- `VscCommandAction` / `VscShortcuts` — optional single-step Shortcuts helpers
- Re-exports `atmos_vsc_keybindings_flutter` (no local key parser)

## Install

```yaml
dependencies:
  atmos_vsc_commands_flutter: ^0.0.1-alpha
```

## Quick start

```dart
import 'package:atmos_vsc_commands_flutter/atmos_vsc_commands_flutter.dart';
import 'package:flutter/widgets.dart';

Future<Widget> buildHost() async {
  final service = VscCommandService(
    context: {'editorTextFocus': true},
  );
  service.register('workbench.action.files.save', (_) => null);

  final defaults = await VscKeybindingsAssetLoader.loadPlatform(
    VscFlutterKeyBridge.currentPlatform,
  );
  final engine = service.createEngine(
    defaults: defaults,
    platform: VscFlutterKeyBridge.currentPlatform,
  );

  return VscCommandHost(
    service: service,
    engine: engine,
    child: const SizedBox.expand(),
  );
}
```

## License

MIT.
