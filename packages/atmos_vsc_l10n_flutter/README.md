# atmos_vsc_l10n_flutter

Flutter layer for [`atmos_vsc_l10n`](../atmos_vsc_l10n) by
[Atom735](https://github.com/Atom735).

Русский: [README_RU.md](README_RU.md).

- `VscNlsAssetLoader` — load NLS / l10n JSON from `AssetBundle`
- `VscL10nScope` — InheritedWidget; rebuilds when locale changes
- No Material

## Install

```yaml
dependencies:
  atmos_vsc_l10n_flutter: ^0.0.1-alpha
```

Declare your `package.nls*.json` / `bundle.l10n*.json` under the **app**
`flutter: assets:`.

## Quick start

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

## License

MIT.
