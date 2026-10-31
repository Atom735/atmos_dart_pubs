# atmos_vsc_keybindings

Pure-Dart **VS Code / Cursor** default keybindings + hotkey engine by
[Atom735](https://github.com/Atom735).

- Bundled OS dumps via git submodule
  [`lib/assets/vs-code-default-keybindings`](lib/assets/vs-code-default-keybindings)
  from
  [vs-code-default-keybindings](https://github.com/codebling/vs-code-default-keybindings)
  (VS Code **1.144.0**, including `*.negative.*`)
- Chord-aware engine with `when`-clauses and default + user layers
- Punctuation keys (`ctrl+/`), `=~ /regex/`, `replaceBindings` / diagnostics
- Owns `VscKeybinding` (commands package depends on this, not the reverse)
- No Flutter dependency — see
  [`atmos_vsc_keybindings_flutter`](../atmos_vsc_keybindings_flutter) for assets
  / widgets

## Install

```yaml
dependencies:
  atmos_vsc_keybindings: ^0.0.1-alpha
```

## Quick start

```dart
import 'package:atmos_vsc_keybindings/atmos_vsc_keybindings.dart';

final defaults = VscKeybindingsLoader.loadBundledPlatform(
  VscKeyPlatform.windows,
  packageRoot: 'packages/atmos_vsc_keybindings',
);

final engine = VscKeybindingEngine.merge(
  defaults: defaults,
  platform: VscKeyPlatform.windows,
  context: {'editorTextFocus': true},
);

final match = engine.handleKey(
  const VscKeyStroke(key: 's', control: true),
);
// match?.commandId == 'workbench.action.files.save' (when context fits)
```

## Updating dumps

```bash
git submodule update --init --recursive
git -C packages/atmos_vsc_keybindings/lib/assets/vs-code-default-keybindings pull
# bump VscBundledKeybindings.vscodeVersion if the JSON header changed
```

## Flutter

Use [`atmos_vsc_keybindings_flutter`](../atmos_vsc_keybindings_flutter) to load
bundled JSON via `AssetBundle` and wire chords into the widget tree.

## License

MIT. Bundled JSON: see [lib/assets/NOTICE.md](lib/assets/NOTICE.md).
