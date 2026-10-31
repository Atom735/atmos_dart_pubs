import 'package:atmos_vsc_theme_flutter/atmos_vsc_theme_flutter.dart';
import 'package:flutter/widgets.dart';

/// Color tokens for VS Code-like chrome.
///
/// ## ENG
/// Plain tokens (not Material ThemeExtension). Prefer
/// [VscUiTheme.fromColorTheme] or wrap with [VscUiThemeScope].
///
/// ## RU
/// Простые токены (не Material ThemeExtension). Удобнее
/// [VscUiTheme.fromColorTheme] или [VscUiThemeScope].
@immutable
class VscUiTheme {
  /// Creates UI chrome tokens.
  const VscUiTheme({
    required this.activityBarBackground,
    required this.activityBarForeground,
    required this.activityBarInactiveForeground,
    required this.activityBarBorder,
    required this.sideBarBackground,
    required this.sideBarForeground,
    required this.sideBarBorder,
    required this.titleBarBackground,
    required this.titleBarForeground,
    required this.tabActiveBackground,
    required this.tabInactiveBackground,
    required this.tabActiveForeground,
    required this.tabInactiveForeground,
    required this.tabBorder,
    required this.editorBackground,
    required this.editorForeground,
    required this.statusBarBackground,
    required this.statusBarForeground,
    required this.statusBarBorder,
    required this.focusBorder,
    required this.widgetBackground,
    required this.listHoverBackground,
    required this.listActiveSelectionBackground,
    required this.inputBackground,
    required this.inputForeground,
    required this.inputBorder,
  });

  /// Dark defaults close to VS Code Dark+.
  factory VscUiTheme.dark() => const VscUiTheme(
        activityBarBackground: Color(0xFF333333),
        activityBarForeground: Color(0xFFFFFFFF),
        activityBarInactiveForeground: Color(0xFFFFFFFF),
        activityBarBorder: Color(0xFF2B2B2B),
        sideBarBackground: Color(0xFF252526),
        sideBarForeground: Color(0xFFCCCCCC),
        sideBarBorder: Color(0xFF2B2B2B),
        titleBarBackground: Color(0xFF3C3C3C),
        titleBarForeground: Color(0xFFCCCCCC),
        tabActiveBackground: Color(0xFF1E1E1E),
        tabInactiveBackground: Color(0xFF2D2D2D),
        tabActiveForeground: Color(0xFFFFFFFF),
        tabInactiveForeground: Color(0xFFFFFFFF),
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

  /// Light defaults close to VS Code Light+.
  factory VscUiTheme.light() => const VscUiTheme(
        activityBarBackground: Color(0xFF2C2C2C),
        activityBarForeground: Color(0xFFFFFFFF),
        activityBarInactiveForeground: Color(0xFFFFFFFF),
        activityBarBorder: Color(0xFF2C2C2C),
        sideBarBackground: Color(0xFFF3F3F3),
        sideBarForeground: Color(0xFF616161),
        sideBarBorder: Color(0xFFC8C8C8),
        titleBarBackground: Color(0xFFDDDDDD),
        titleBarForeground: Color(0xFF333333),
        tabActiveBackground: Color(0xFFFFFFFF),
        tabInactiveBackground: Color(0xFFECECEC),
        tabActiveForeground: Color(0xFF333333),
        tabInactiveForeground: Color(0xFF333333),
        tabBorder: Color(0xFFF3F3F3),
        editorBackground: Color(0xFFFFFFFF),
        editorForeground: Color(0xFF000000),
        statusBarBackground: Color(0xFF007ACC),
        statusBarForeground: Color(0xFFFFFFFF),
        statusBarBorder: Color(0xFF007ACC),
        focusBorder: Color(0xFF0090F1),
        widgetBackground: Color(0xFFF3F3F3),
        listHoverBackground: Color(0xFFE8E8E8),
        listActiveSelectionBackground: Color(0xFF0060C0),
        inputBackground: Color(0xFFFFFFFF),
        inputForeground: Color(0xFF333333),
        inputBorder: Color(0xFFCECECE),
      );

  /// Maps common workbench keys from a resolved [VscColorTheme].
  factory VscUiTheme.fromColorTheme(VscColorTheme theme) {
    final base = theme.isDark ? VscUiTheme.dark() : VscUiTheme.light();
    final c = theme.colors;
    Color pick(Color? v, Color or) => v ?? or;
    Color? fl(VscColor? v) => v.toFlutterColor();

    return VscUiTheme(
      activityBarBackground: pick(
        fl(c.activityBar.background),
        base.activityBarBackground,
      ),
      activityBarForeground: pick(
        fl(c.activityBar.foreground),
        base.activityBarForeground,
      ),
      activityBarInactiveForeground: pick(
        fl(c.activityBar.inactiveForeground),
        base.activityBarInactiveForeground,
      ),
      activityBarBorder:
          pick(fl(c.activityBar.border), base.activityBarBorder),
      sideBarBackground:
          pick(fl(c.sideBar.background), base.sideBarBackground),
      sideBarForeground:
          pick(fl(c.sideBar.foreground), base.sideBarForeground),
      sideBarBorder: pick(fl(c.sideBar.border), base.sideBarBorder),
      titleBarBackground: pick(
        fl(c.titleBar.activeBackground),
        base.titleBarBackground,
      ),
      titleBarForeground: pick(
        fl(c.titleBar.activeForeground),
        base.titleBarForeground,
      ),
      tabActiveBackground:
          pick(fl(c.tab.activeBackground), base.tabActiveBackground),
      tabInactiveBackground:
          pick(fl(c.tab.inactiveBackground), base.tabInactiveBackground),
      tabActiveForeground:
          pick(fl(c.tab.activeForeground), base.tabActiveForeground),
      tabInactiveForeground:
          pick(fl(c.tab.inactiveForeground), base.tabInactiveForeground),
      tabBorder: pick(fl(c.tab.border), base.tabBorder),
      editorBackground:
          pick(fl(c.editor.background), base.editorBackground),
      editorForeground:
          pick(fl(c.editor.foreground), base.editorForeground),
      statusBarBackground:
          pick(fl(c.statusBar.background), base.statusBarBackground),
      statusBarForeground:
          pick(fl(c.statusBar.foreground), base.statusBarForeground),
      statusBarBorder: pick(fl(c.statusBar.border), base.statusBarBorder),
      focusBorder: pick(fl(c.focusBorder), base.focusBorder),
      widgetBackground:
          pick(fl(c.editorWidget.background), base.widgetBackground),
      listHoverBackground:
          pick(fl(c.list.hoverBackground), base.listHoverBackground),
      listActiveSelectionBackground: pick(
        fl(c.list.activeSelectionBackground),
        base.listActiveSelectionBackground,
      ),
      inputBackground: pick(fl(c.input.background), base.inputBackground),
      inputForeground: pick(fl(c.input.foreground), base.inputForeground),
      inputBorder: pick(fl(c.input.border), base.inputBorder),
    );
  }

  /// Reads theme from [context], falling back to dark defaults.
  ///
  /// Order: [VscUiThemeScope], then [VscThemeScope], then [VscUiTheme.dark].
  factory VscUiTheme.of(BuildContext context) {
    final scoped =
        context.dependOnInheritedWidgetOfExactType<VscUiThemeScope>();
    if (scoped != null) return scoped.theme;
    final colorTheme = VscThemeScope.maybeOf(context);
    if (colorTheme != null) return VscUiTheme.fromColorTheme(colorTheme);
    return VscUiTheme.dark();
  }

  final Color activityBarBackground;
  final Color activityBarForeground;
  final Color activityBarInactiveForeground;
  final Color activityBarBorder;
  final Color sideBarBackground;
  final Color sideBarForeground;
  final Color sideBarBorder;
  final Color titleBarBackground;
  final Color titleBarForeground;
  final Color tabActiveBackground;
  final Color tabInactiveBackground;
  final Color tabActiveForeground;
  final Color tabInactiveForeground;
  final Color tabBorder;
  final Color editorBackground;
  final Color editorForeground;
  final Color statusBarBackground;
  final Color statusBarForeground;
  final Color statusBarBorder;
  final Color focusBorder;
  final Color widgetBackground;
  final Color listHoverBackground;
  final Color listActiveSelectionBackground;
  final Color inputBackground;
  final Color inputForeground;
  final Color inputBorder;

  /// Copy with selective overrides.
  VscUiTheme copyWith({
    Color? activityBarBackground,
    Color? activityBarForeground,
    Color? activityBarInactiveForeground,
    Color? activityBarBorder,
    Color? sideBarBackground,
    Color? sideBarForeground,
    Color? sideBarBorder,
    Color? titleBarBackground,
    Color? titleBarForeground,
    Color? tabActiveBackground,
    Color? tabInactiveBackground,
    Color? tabActiveForeground,
    Color? tabInactiveForeground,
    Color? tabBorder,
    Color? editorBackground,
    Color? editorForeground,
    Color? statusBarBackground,
    Color? statusBarForeground,
    Color? statusBarBorder,
    Color? focusBorder,
    Color? widgetBackground,
    Color? listHoverBackground,
    Color? listActiveSelectionBackground,
    Color? inputBackground,
    Color? inputForeground,
    Color? inputBorder,
  }) {
    return VscUiTheme(
      activityBarBackground:
          activityBarBackground ?? this.activityBarBackground,
      activityBarForeground:
          activityBarForeground ?? this.activityBarForeground,
      activityBarInactiveForeground: activityBarInactiveForeground ??
          this.activityBarInactiveForeground,
      activityBarBorder: activityBarBorder ?? this.activityBarBorder,
      sideBarBackground: sideBarBackground ?? this.sideBarBackground,
      sideBarForeground: sideBarForeground ?? this.sideBarForeground,
      sideBarBorder: sideBarBorder ?? this.sideBarBorder,
      titleBarBackground: titleBarBackground ?? this.titleBarBackground,
      titleBarForeground: titleBarForeground ?? this.titleBarForeground,
      tabActiveBackground: tabActiveBackground ?? this.tabActiveBackground,
      tabInactiveBackground:
          tabInactiveBackground ?? this.tabInactiveBackground,
      tabActiveForeground: tabActiveForeground ?? this.tabActiveForeground,
      tabInactiveForeground:
          tabInactiveForeground ?? this.tabInactiveForeground,
      tabBorder: tabBorder ?? this.tabBorder,
      editorBackground: editorBackground ?? this.editorBackground,
      editorForeground: editorForeground ?? this.editorForeground,
      statusBarBackground: statusBarBackground ?? this.statusBarBackground,
      statusBarForeground: statusBarForeground ?? this.statusBarForeground,
      statusBarBorder: statusBarBorder ?? this.statusBarBorder,
      focusBorder: focusBorder ?? this.focusBorder,
      widgetBackground: widgetBackground ?? this.widgetBackground,
      listHoverBackground: listHoverBackground ?? this.listHoverBackground,
      listActiveSelectionBackground: listActiveSelectionBackground ??
          this.listActiveSelectionBackground,
      inputBackground: inputBackground ?? this.inputBackground,
      inputForeground: inputForeground ?? this.inputForeground,
      inputBorder: inputBorder ?? this.inputBorder,
    );
  }
}

/// Provides a [VscUiTheme] to descendants.
class VscUiThemeScope extends InheritedWidget {
  /// Creates a UI theme scope.
  const VscUiThemeScope({
    super.key,
    required this.theme,
    required super.child,
  });

  /// Active chrome tokens.
  final VscUiTheme theme;

  @override
  bool updateShouldNotify(VscUiThemeScope oldWidget) =>
      theme != oldWidget.theme;
}
