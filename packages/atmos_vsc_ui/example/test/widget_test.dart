import 'package:atmos_vsc_ui/atmos_vsc_ui.dart';
import 'package:atmos_vsc_ui_example/demo_app.dart';
import 'package:atmos_vsc_ui_example/demo_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('demo workbench renders explorer chrome', (tester) async {
    const theme = VscColorTheme(
      name: 'Test Dark',
      type: VscThemeType.dark,
      colors: {
        'editor.background': VscColor(0x1E, 0x1E, 0x1E),
        'editor.foreground': VscColor(0xCC, 0xCC, 0xCC),
        'activityBar.background': VscColor(0x33, 0x33, 0x33),
        'activityBar.foreground': VscColor.white,
        'sideBar.background': VscColor(0x25, 0x25, 0x26),
        'sideBar.foreground': VscColor(0xCC, 0xCC, 0xCC),
        'titleBar.activeBackground': VscColor(0x3C, 0x3C, 0x3C),
        'titleBar.activeForeground': VscColor(0xCC, 0xCC, 0xCC),
        'statusBar.background': VscColor(0x00, 0x7A, 0xCC),
        'statusBar.foreground': VscColor.white,
      },
    );

    final l10n = VscL10n(
      bundle: VscNlsBundle(
        defaults: const VscNlsTable({
          'Workbench': 'Workbench',
          'atmos_vsc_ui example': 'atmos_vsc_ui example',
          'Locale: {0}': 'Locale: {0}',
        }),
      ),
    );

    await tester.pumpWidget(
      DemoApp(
        initialTheme: theme,
        initialThemeId: 'darkModern',
        commands: DemoData.buildCommands(),
        l10n: l10n,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('atmos_vsc_ui'), findsWidgets);
    expect(find.text('main.dart'), findsWidgets);
    expect(find.text('TERMINAL'), findsWidgets);

    await tester.tap(find.bySemanticsLabel('Widgets'));
    await tester.pumpAndSettle();
    expect(find.text('Components'), findsWidgets);
    expect(find.text('VscButton'), findsWidgets);
    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('VscCheckbox'), findsWidgets);
    expect(find.text('VscMenuBar'), findsWidgets);
  });
}
