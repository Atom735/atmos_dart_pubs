# atmos_vsc_keybindings

Pure-Dart дефолтные хоткеи **VS Code / Cursor** и движок разрешения нажатий от
[Atom735](https://github.com/Atom735).

English: [README.md](README.md).

- Бандл OS-дампов через git-субмодуль
  [`lib/assets/vs-code-default-keybindings`](lib/assets/vs-code-default-keybindings)
  из
  [vs-code-default-keybindings](https://github.com/codebling/vs-code-default-keybindings)
  (VS Code **1.144.0**, включая `*.negative.*`)
- Движок с аккордами, `when`-клаузами и слоями default + user
- Пунктуация (`ctrl+/`), `=~ /regex/`, `replaceBindings` / диагностика skip
- Владеет `VscKeybinding` (пакет commands зависит от этого, не наоборот)
- Без Flutter — см.
  [`atmos_vsc_keybindings_flutter`](../atmos_vsc_keybindings_flutter) для
  ассетов / виджетов

## Установка

```yaml
dependencies:
  atmos_vsc_keybindings: ^0.0.1-alpha
```

## Быстрый старт

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
// match?.commandId == 'workbench.action.files.save' (если context подходит)
```

## Обновление дампов

```bash
git submodule update --init --recursive
git -C packages/atmos_vsc_keybindings/lib/assets/vs-code-default-keybindings pull
# при смене заголовка JSON — bump VscBundledKeybindings.vscodeVersion
```

## Flutter

Используйте [`atmos_vsc_keybindings_flutter`](../atmos_vsc_keybindings_flutter):
загрузка JSON через `AssetBundle` и хост аккордов в дереве виджетов.

## Лицензия

MIT. Бандл JSON: см. [lib/assets/NOTICE.md](lib/assets/NOTICE.md).
