# atmos_vsc_keybindings_flutter

Flutter-слой для [`atmos_vsc_keybindings`](../atmos_vsc_keybindings) от
[Atom735](https://github.com/Atom735).

English: [README.md](README.md).

- Загрузка OS / negative дампов через `AssetBundle`
- Мост `LogicalKeyboardKey` ↔ `VscKeyStroke`
- `VscKeybindingsHost` — аккорды, не перехватывать печать в `EditableText`,
  без Material

## Установка

```yaml
dependencies:
  atmos_vsc_keybindings_flutter: ^0.0.1-alpha
```

## Быстрый старт

```dart
import 'package:atmos_vsc_keybindings_flutter/atmos_vsc_keybindings_flutter.dart';
import 'package:flutter/widgets.dart';

Future<Widget> buildHost() async {
  final defaults = await VscKeybindingsAssetLoader.loadPlatform(
    VscFlutterKeyBridge.currentPlatform,
  );
  final engine = VscKeybindingEngine.merge(
    defaults: defaults,
    platform: VscFlutterKeyBridge.currentPlatform,
    context: {'editorTextFocus': true},
  );
  return VscKeybindingsHost(
    engine: engine,
    onCommand: (match) {
      // выполнить match.commandId
    },
    child: const SizedBox.expand(),
  );
}
```

## Лицензия

MIT.
