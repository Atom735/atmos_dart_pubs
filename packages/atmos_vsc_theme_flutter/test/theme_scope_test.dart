import 'package:atmos_vsc_theme_flutter/atmos_vsc_theme_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('context.vscTheme reads VscThemeScope', (tester) async {
    const theme = VscColorTheme(
      name: 'Test',
      type: VscThemeType.dark,
      colors: {
        'editor.background': VscColor(0x1E, 0x1E, 0x1E),
      },
    );

    late VscColorTheme seen;
    await tester.pumpWidget(
      VscThemeScope(
        theme: theme,
        child: Builder(
          builder: (context) {
            seen = context.vscTheme;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(seen.name, 'Test');
    expect(
      seen.colors.editor.background?.toHex().toUpperCase(),
      '#1E1E1E',
    );
  });
}
