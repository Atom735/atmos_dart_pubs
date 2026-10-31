# atmos_vsc_commands

Хаб команд **VS Code / Cursor** + парсинг contributions от
[Atom735](https://github.com/Atom735).

English: [README.md](README.md).

- `VscCommandService` — register / execute / enablement / общий `context`
- JSONC contributions (`contributes.commands` / `keybindings`)
- Движок хоткеев реэкспортируется из
  [`atmos_vsc_keybindings`](../atmos_vsc_keybindings)
- Строки / `%nls.keys%` через [`atmos_vsc_l10n`](../atmos_vsc_l10n)
- Flutter: [`atmos_vsc_commands_flutter`](../atmos_vsc_commands_flutter)
  (`VscCommandHost`)

## Установка

```yaml
dependencies:
  atmos_vsc_commands: ^0.0.1-alpha
```

## Быстрый старт

```dart
import 'package:atmos_vsc_commands/atmos_vsc_commands.dart';

final service = VscCommandService(
  context: {'editorTextFocus': true},
);

service.register('workbench.action.files.save', (inv) {
  // сохранить…
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

## Flutter

[`VscCommandHost`](../atmos_vsc_commands_flutter) — аккорды / `when` через
engine в `executeMatch`.

## Лицензия

MIT. См. [LICENSE](LICENSE).
