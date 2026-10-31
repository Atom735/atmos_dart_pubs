import 'package:atmos_vsc_ui/atmos_vsc_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('VscWorkbench renders chrome', (tester) async {
    await tester.pumpWidget(
      WidgetsApp(
        color: const Color(0xFF1E1E1E),
        pageRouteBuilder: <T>(settings, builder) {
          return PageRouteBuilder<T>(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) {
              return builder(context);
            },
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return child;
            },
          );
        },
        home: VscUiThemeScope(
          theme: VscUiTheme.dark(),
          child: const VscWorkbench(
            title: 'Demo',
            activityItems: [
              VscActivityBarItem(
                id: 'explorer',
                icon: VscCodicon(VscCodicons.files, size: 24),
              ),
            ],
            selectedActivityId: 'explorer',
            sideBarTitle: 'Explorer',
            sideBar: Text('tree'),
            tabs: [
              VscEditorTab(id: 'a', label: 'a.dart'),
            ],
            selectedTabId: 'a',
            editor: Text('editor'),
            statusLeading: [Text('Ln 1')],
          ),
        ),
      ),
    );

    expect(find.text('Demo'), findsOneWidget);
    expect(find.text('EXPLORER'), findsOneWidget);
    expect(find.text('a.dart'), findsOneWidget);
    expect(find.text('editor'), findsOneWidget);
    expect(find.text('Ln 1'), findsOneWidget);
  });

  testWidgets('command palette draws a product icon', (tester) async {
    const command = VscCommand(
      command: 'demo.book',
      title: VscLocalizedString('Open Book'),
      icon: VscCommandProductIcon(r'$(book)'),
    );

    await tester.pumpWidget(
      WidgetsApp(
        color: const Color(0xFF1E1E1E),
        pageRouteBuilder: <T>(settings, builder) {
          return PageRouteBuilder<T>(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) {
              return builder(context);
            },
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return child;
            },
          );
        },
        home: VscUiThemeScope(
          theme: VscUiTheme.dark(),
          child: const VscCommandPalette(
            commands: [command],
            onCommand: _noopCommand,
          ),
        ),
      ),
    );

    expect(find.text('Open Book'), findsOneWidget);
    expect(find.byType(VscCodicon), findsOneWidget);
  });

  test('VscUiTheme.fromColorTheme uses editor background', () {
    const theme = VscColorTheme(
      type: VscThemeType.dark,
      colors: {
        'editor.background': VscColor(0x11, 0x22, 0x33),
      },
    );
    final ui = VscUiTheme.fromColorTheme(theme);
    expect(ui.editorBackground, const Color(0xFF112233));
  });
}

void _noopCommand(VscCommand command) {}
