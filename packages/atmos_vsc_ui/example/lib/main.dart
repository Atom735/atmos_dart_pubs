import 'package:atmos_vsc_l10n_flutter/atmos_vsc_l10n_flutter.dart';
import 'package:atmos_vsc_ui/atmos_vsc_ui.dart';
import 'package:flutter/widgets.dart';

import 'demo_app.dart';
import 'demo_data.dart';

/// atmos_vsc_ui web example (WidgetsApp, no Material).
///
/// ```bash
/// cd packages/atmos_vsc_ui/example
/// flutter run -d chrome
/// ```
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const initialId = 'darkModern';
  late VscColorTheme theme;
  try {
    theme = await VscThemeAssetLoader.load(VscBundledThemes.darkModern);
  } on Object {
    theme = const VscColorTheme(
      name: 'Fallback Dark',
      type: VscThemeType.dark,
    );
  }

  final l10nBundle = await VscNlsAssetLoader.loadBundleL10n(
    defaultAsset: 'assets/l10n/bundle.l10n.json',
    localeAssets: {
      VscLocale('ru'): 'assets/l10n/bundle.l10n.ru.json',
    },
    preferredLocale: VscLocale('ru'),
  );
  final l10n = VscL10n(bundle: l10nBundle, locale: VscLocale('ru'));

  runApp(
    DemoApp(
      initialTheme: theme,
      initialThemeId: initialId,
      commands: DemoData.buildCommands(),
      l10n: l10n,
    ),
  );
}
