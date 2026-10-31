import 'package:atmos_vsc_theme_flutter/atmos_vsc_theme_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads dark_modern from package assets with include chain', () async {
    final theme = await VscThemeAssetLoader.load(VscBundledThemes.darkModern);
    expect(theme.name, 'Default Dark Modern');
    expect(theme.colors.editor.background, isNotNull);
    expect(theme.tokenColors.length, greaterThan(20));
  });

  test('loads 2026 dark from assets', () async {
    final theme = await VscThemeAssetLoader.load(VscBundledThemes.dark2026);
    expect(theme.name, '2026 Dark');
    expect(
      theme.colors.editor.background?.toHex().toUpperCase(),
      '#121314',
    );
  });
}
