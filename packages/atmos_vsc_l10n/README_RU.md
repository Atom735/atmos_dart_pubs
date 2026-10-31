# atmos_vsc_l10n

Локализация в стиле **VS Code / Cursor** от [Atom735](https://github.com/Atom735).

English: [README.md](README.md).

- таблицы `package.nls` / `bundle.l10n` (JSONC)
- резолв `%contribution.keys%`
- runtime `VscL10n.t` — `{0}`, `{name}`, comment-ключи, pseudo
- ядро без `dart:io`; файлы —
  [`atmos_vsc_l10n_io.dart`](lib/atmos_vsc_l10n_io.dart)
- Flutter: [`atmos_vsc_l10n_flutter`](../atmos_vsc_l10n_flutter)

## Установка

```yaml
dependencies:
  atmos_vsc_l10n: ^0.0.1-alpha
```

## Быстрый старт

```dart
import 'package:atmos_vsc_l10n/atmos_vsc_l10n.dart';

final bundle = VscNlsBundle(
  defaults: VscNlsLoader.parseTable(r'''
  {
    "Hello {0}/who": { "message": "Hello {0}", "comment": ["who"] },
    "ext.hello.title": "Hello"
  }
  '''),
)..addTable(
  VscNlsLoader.parseTable(
    r'''{
      "Hello {0}/who": "Привет, {0}",
      "ext.hello.title": "Привет"
    }''',
    locale: VscLocale('ru'),
  ),
);

final l10n = VscL10n(bundle: bundle, locale: VscLocale('ru'));
l10n.t('Hello {0}', args: ['Ada'], comment: ['who']); // Привет, Ada
```

## Лицензия

MIT. См. [LICENSE](LICENSE).
