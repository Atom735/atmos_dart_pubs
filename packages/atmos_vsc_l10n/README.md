# atmos_vsc_l10n

VS Code / Cursor style **localization** by [Atom735](https://github.com/Atom735).

Русский: [README_RU.md](README_RU.md).

- `package.nls` / `bundle.l10n` tables (JSONC)
- Resolve `%contribution.keys%` in manifests
- Runtime `VscL10n.t` — `{0}`, `{name}`, comment keys, pseudo-locale
- Pure Dart core; filesystem via
  [`atmos_vsc_l10n_io.dart`](lib/atmos_vsc_l10n_io.dart)
- Flutter: [`atmos_vsc_l10n_flutter`](../atmos_vsc_l10n_flutter)

## Install

```yaml
dependencies:
  atmos_vsc_l10n: ^0.0.1-alpha
```

## Quick start

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
l10n.tNamed('Hi {name}', {'name': 'Ada'});

final title = VscNls.resolveString(
  '%ext.hello.title%',
  bundle: bundle,
  locale: VscLocale('ru'),
);
```

## Files (VM)

```dart
import 'package:atmos_vsc_l10n/atmos_vsc_l10n_io.dart';

final nls = VscNlsFileLoader.loadAllPackageNls(Directory('path/to/ext'));
final l10nBundle = VscNlsFileLoader.loadBundleL10n(
  Directory('path/to/ext/l10n'),
  locale: VscLocale('ru'),
);
```

## License

MIT. See [LICENSE](LICENSE).
