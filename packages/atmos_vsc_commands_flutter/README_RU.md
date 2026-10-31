# atmos_vsc_commands_flutter

Flutter-слой для [`atmos_vsc_commands`](../atmos_vsc_commands) от
[Atom735](https://github.com/Atom735).

English: [README.md](README.md).

- **`VscCommandHost`** — канон: Host → `executeMatch` (аккорды + `when`)
- `VscCommandAction` / `VscShortcuts` — опциональные single-step Shortcuts
- Реэкспорт `atmos_vsc_keybindings_flutter` (без локального парсера клавиш)

## Установка

```yaml
dependencies:
  atmos_vsc_commands_flutter: ^0.0.1-alpha
```

## Быстрый старт

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

## Лицензия

MIT.
