# atmos_vsc_commands

**VS Code / Cursor** command hub + contribution parsing by
[Atom735](https://github.com/Atom735).

Русский: [README_RU.md](README_RU.md).

- `VscCommandService` — register / execute / enablement / shared `context`
- JSONC contributions (`contributes.commands` / `keybindings`)
- Keybinding engine re-exported from
  [`atmos_vsc_keybindings`](../atmos_vsc_keybindings)
- Localized strings / `%nls.keys%` via [`atmos_vsc_l10n`](../atmos_vsc_l10n)
- Flutter: [`atmos_vsc_commands_flutter`](../atmos_vsc_commands_flutter)
  (`VscCommandHost`)

## Install

```yaml
dependencies:
  atmos_vsc_commands: ^0.0.1-alpha
```

## Quick start

```dart
import 'package:atmos_vsc_commands/atmos_vsc_commands.dart';

final service = VscCommandService(
  context: {'editorTextFocus': true},
);

service.register('workbench.action.files.save', (inv) {
  // save…
  return null;
});

final engine = service.createEngine(
  defaults: VscKeybindingsLoader.loadBundledPlatform(
    VscKeyPlatform.windows,
    packageRoot: 'packages/atmos_vsc_keybindings',
  ),
);

final match = engine.handleKey(
  const VscKeyStroke(key: 's', control: true),
);
if (match != null) {
  service.executeMatch(match);
}
```

## Contributions

```dart
final contrib = VscCommandsLoader.parseContributions(r'''
{
  "contributes": {
    "commands": [
      { "command": "extension.sayHello", "title": "Say Hello", "category": "Demo" }
    ],
    "keybindings": [
      { "command": "extension.sayHello", "key": "ctrl+f1", "mac": "cmd+f1" }
    ]
  }
}
''');
service.registerContributions(contrib);
```

## Flutter

Use [`VscCommandHost`](../atmos_vsc_commands_flutter) so chords / `when` go
through the keybindings engine into `executeMatch`.

## License

MIT. See [LICENSE](LICENSE).
