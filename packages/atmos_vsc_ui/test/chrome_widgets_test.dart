import 'package:atmos_vsc_ui/atmos_vsc_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('checkbox, tree, dropdown and panel respond', (tester) async {
    await tester.pumpWidget(
      WidgetsApp(
        color: const Color(0xFF1E1E1E),
        pageRouteBuilder: _route,
        home: const VscUiThemeScope(
          theme: _dark,
          child: _ChromeHost(),
        ),
      ),
    );

    expect(find.text('Checked'), findsOneWidget);
    await tester.tap(find.text('Checked'));
    await tester.pump();
    expect(find.text('Unchecked'), findsOneWidget);

    expect(find.text('main.dart'), findsNothing);
    await tester.tap(find.text('lib'));
    await tester.pump();
    expect(find.text('main.dart'), findsOneWidget);

    await tester.tap(find.text('Dark Modern'));
    await tester.pump();
    await tester.tap(find.text('Light Modern'));
    await tester.pump();
    expect(find.text('Light Modern'), findsOneWidget);

    expect(find.text(r'$ flutter test'), findsOneWidget);
    await tester.tap(find.text('PROBLEMS'));
    await tester.pump();
    expect(find.text('No problems'), findsOneWidget);
  });

  testWidgets('menu item invokes its callback', (tester) async {
    var opened = 0;
    await tester.pumpWidget(
      WidgetsApp(
        color: const Color(0xFF1E1E1E),
        pageRouteBuilder: _route,
        home: VscUiThemeScope(
          theme: _dark,
          child: VscMenuBar(
            entries: [
              VscMenuEntry(
                label: 'File',
                items: [
                  VscMenuItem(
                    label: 'New File',
                    onSelected: () => opened++,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('File'));
    await tester.pump();
    await tester.tap(find.text('New File'));
    await tester.pump();
    expect(opened, 1);
  });
}

const _dark = VscUiTheme(
  activityBarBackground: Color(0xFF333333),
  activityBarForeground: Color(0xFFFFFFFF),
  activityBarInactiveForeground: Color(0xFFCCCCCC),
  activityBarBorder: Color(0xFF2B2B2B),
  sideBarBackground: Color(0xFF252526),
  sideBarForeground: Color(0xFFCCCCCC),
  sideBarBorder: Color(0xFF2B2B2B),
  titleBarBackground: Color(0xFF3C3C3C),
  titleBarForeground: Color(0xFFCCCCCC),
  tabActiveBackground: Color(0xFF1E1E1E),
  tabInactiveBackground: Color(0xFF2D2D2D),
  tabActiveForeground: Color(0xFFFFFFFF),
  tabInactiveForeground: Color(0xFFCCCCCC),
  tabBorder: Color(0xFF252526),
  editorBackground: Color(0xFF1E1E1E),
  editorForeground: Color(0xFFD4D4D4),
  statusBarBackground: Color(0xFF007ACC),
  statusBarForeground: Color(0xFFFFFFFF),
  statusBarBorder: Color(0xFF007ACC),
  focusBorder: Color(0xFF007ACC),
  widgetBackground: Color(0xFF252526),
  listHoverBackground: Color(0xFF2A2D2E),
  listActiveSelectionBackground: Color(0xFF094771),
  inputBackground: Color(0xFF3C3C3C),
  inputForeground: Color(0xFFCCCCCC),
  inputBorder: Color(0xFF3C3C3C),
);

class _ChromeHost extends StatefulWidget {
  const _ChromeHost();

  @override
  State<_ChromeHost> createState() => _ChromeHostState();
}

class _ChromeHostState extends State<_ChromeHost> {
  bool _checked = true;
  String _theme = 'dark';
  String _panel = 'terminal';

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        VscCheckbox(
          value: _checked,
          label: _checked ? 'Checked' : 'Unchecked',
          onChanged: (v) => setState(() => _checked = v),
        ),
        const VscTree(
          nodes: [
            VscTreeNode(
              id: 'lib',
              label: 'lib',
              children: [
                VscTreeNode(id: 'main', label: 'main.dart'),
              ],
            ),
          ],
        ),
        VscDropdown<String>(
          value: _theme,
          items: const [
            VscDropdownItem(value: 'dark', label: 'Dark Modern'),
            VscDropdownItem(value: 'light', label: 'Light Modern'),
          ],
          onChanged: (v) => setState(() => _theme = v),
        ),
        SizedBox(
          height: 120,
          child: VscPanel(
            selectedId: _panel,
            onSelected: (id) => setState(() => _panel = id),
            tabs: const [
              VscPanelTab(id: 'terminal', label: 'TERMINAL'),
              VscPanelTab(id: 'problems', label: 'PROBLEMS'),
            ],
            child: Text(
              _panel == 'terminal' ? r'$ flutter test' : 'No problems',
            ),
          ),
        ),
      ],
    );
  }
}

PageRoute<T> _route<T>(
  RouteSettings settings,
  WidgetBuilder builder,
) {
  return PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        child,
  );
}
