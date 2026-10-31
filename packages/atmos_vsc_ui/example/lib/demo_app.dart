import 'package:atmos_vsc_l10n_flutter/atmos_vsc_l10n_flutter.dart';
import 'package:atmos_vsc_ui/atmos_vsc_ui.dart';
import 'package:flutter/widgets.dart';

import 'demo_data.dart';
import 'demo_workbench.dart';

/// Root demo app: theme scope + l10n scope + workbench (no Material).
class DemoApp extends StatefulWidget {
  const DemoApp({
    super.key,
    required this.initialTheme,
    required this.initialThemeId,
    required this.commands,
    required this.l10n,
  });

  final VscColorTheme initialTheme;
  final String initialThemeId;
  final List<VscCommand> commands;
  final VscL10n l10n;

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  late VscColorTheme _theme = widget.initialTheme;
  late String _themeId = widget.initialThemeId;
  bool _loadingTheme = false;

  Future<void> _selectTheme(String id) async {
    DemoThemeOption? option;
    for (final t in DemoData.themes) {
      if (t.id == id) {
        option = t;
        break;
      }
    }
    if (option == null || id == _themeId) return;

    setState(() => _loadingTheme = true);
    try {
      final loaded = await VscThemeAssetLoader.load(option.bundled);
      if (!mounted) return;
      setState(() {
        _theme = loaded;
        _themeId = id;
        _loadingTheme = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() => _loadingTheme = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ui = VscUiTheme.fromColorTheme(_theme);
    return VscL10nScope(
      l10n: widget.l10n,
      child: VscThemeScope(
        theme: _theme,
        child: VscUiThemeScope(
          theme: ui,
          child: WidgetsApp(
            title: 'atmos_vsc_ui',
            color: ui.editorBackground,
            debugShowCheckedModeBanner: false,
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
            home: Stack(
              fit: StackFit.expand,
              children: [
                DemoWorkbench(
                  commands: widget.commands,
                  themeOptionId: _themeId,
                  onSelectTheme: _selectTheme,
                ),
                if (_loadingTheme)
                  const Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        '…',
                        style: TextStyle(
                          color: Color(0xFFCCCCCC),
                          fontSize: 18,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
