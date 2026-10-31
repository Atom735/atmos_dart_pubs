# atmos_vsc_l10n_flutter

Flutter-слой для [`atmos_vsc_l10n`](../atmos_vsc_l10n) от
[Atom735](https://github.com/Atom735).

English: [README.md](README.md).

- `VscNlsAssetLoader` — NLS / l10n из `AssetBundle`
- `VscL10nScope` — InheritedWidget; rebuild при смене локали
- Без Material

## Установка

```yaml
dependencies:
  atmos_vsc_l10n_flutter: ^0.0.1-alpha
```

Ассеты `package.nls*.json` / `bundle.l10n*.json` объявляйте в **приложении**.

## Быстрый старт

```dart
import 'package:atmos_vsc_l10n_flutter/atmos_vsc_l10n_flutter.dart';
import 'package:flutter/widgets.dart';

Future<Widget> buildApp() async {
  final bundle = await VscNlsAssetLoader.loadBundleL10n(
    defaultAsset: 'assets/l10n/bundle.l10n.json',
    localeAssets: {
      VscLocale('ru'): 'assets/l10n/bundle.l10n.ru.json',
    },
    preferredLocale: VscLocale('ru'),
  );
  final l10n = VscL10n(bundle: bundle, locale: VscLocale('ru'));

  return VscL10nScope(
    l10n: l10n,
    child: Builder(
      builder: (context) {
        final t = VscL10nScope.of(context);
        return Text(t.t('Hello {0}', args: ['World']));
      },
    ),
  );
}
```

## Лицензия

MIT.
