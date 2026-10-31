import 'package:atmos_vsc_theme/atmos_vsc_theme.dart';
import 'package:flutter/widgets.dart';

/// Provides a [VscColorTheme] to descendants.
///
/// ## ENG
/// Read with [of] / [maybeOf], or `context.vscTheme`.
///
/// ## RU
/// Чтение через [of] / [maybeOf] или `context.vscTheme`.
class VscThemeScope extends InheritedWidget {
  /// Creates a scope that exposes [theme].
  const VscThemeScope({
    super.key,
    required this.theme,
    required super.child,
  });

  /// Active color theme for the subtree.
  final VscColorTheme theme;

  /// Theme from the nearest [VscThemeScope], or throws if missing.
  static VscColorTheme of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<VscThemeScope>();
    assert(scope != null, 'No VscThemeScope found in context');
    return scope!.theme;
  }

  /// Theme from the nearest [VscThemeScope], or `null`.
  static VscColorTheme? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<VscThemeScope>()?.theme;

  @override
  bool updateShouldNotify(VscThemeScope oldWidget) =>
      theme != oldWidget.theme;
}

/// [BuildContext] helpers for [VscThemeScope].
extension VscThemeContext on BuildContext {
  /// Nearest [VscColorTheme] (`context.vscTheme.colors.editor.background`).
  VscColorTheme get vscTheme => VscThemeScope.of(this);

  /// Nearest [VscColorTheme], or `null` if no [VscThemeScope].
  VscColorTheme? get maybeVscTheme => VscThemeScope.maybeOf(this);
}
