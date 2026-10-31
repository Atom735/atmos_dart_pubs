# atmos_vsc_keybindings_flutter

Flutter layer for [`atmos_vsc_keybindings`](../atmos_vsc_keybindings) by
[Atom735](https://github.com/Atom735).

- Load bundled OS dumps via `AssetBundle`
- Map `LogicalKeyboardKey` ↔ `VscKeyStroke`
- `VscKeybindingsHost` — chord-aware focus host (no Material)

## Install

```yaml
dependencies:
  atmos_vsc_keybindings_flutter: ^0.0.1-alpha
```

## Quick start

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
      // run match.commandId
    },
    child: const SizedBox.expand(),
  );
}
```

## License

MIT.
