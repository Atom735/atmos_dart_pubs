import 'color.dart';
import 'token_color.dart';

/// Theme base kind (`dark` / `light` / high-contrast variants).
///
/// ## ENG
/// Mirrors VS Code `type` when present; otherwise inferred from UI colors.
///
/// ## RU
/// Соответствует `type` VS Code, либо выводится из UI-цветов.
enum VscodeThemeType {
  /// Dark UI (`"dark"`).
  dark,

  /// Light UI (`"light"`).
  light,

  /// High contrast dark (`"hcDark"` / `"hc-black"` style).
  hcDark,

  /// High contrast light (`"hcLight"`).
  hcLight,
}

/// Resolved VS Code / Cursor color theme after `include` merge.
///
/// ## ENG
/// [colors] are workbench color keys; [tokenColors] are TextMate rules in
/// cascade order (base first, overrides last).
///
/// ## RU
/// [colors] — ключи workbench; [tokenColors] — TextMate-правила в порядке
/// каскада (база первой, оверрайды последними).
class VscodeColorTheme {
  /// Creates a resolved theme.
  const VscodeColorTheme({
    this.name,
    this.type,
    this.semanticHighlighting,
    this.colors = const {},
    this.tokenColors = const [],
    this.semanticTokenColors = const {},
  });

  /// Display name from the leaf theme JSON.
  final String? name;

  /// Declared or inferred theme type.
  final VscodeThemeType? type;

  /// Whether semantic highlighting is enabled (`semanticHighlighting`).
  final bool? semanticHighlighting;

  /// Merged workbench colors (`editor.background`, …).
  final Map<String, VscodeColor> colors;

  /// Merged TextMate token rules (parent rules first).
  final List<VscodeTokenColor> tokenColors;

  /// Merged semantic token colors (string values kept as raw hex or style).
  final Map<String, String> semanticTokenColors;

  /// Looks up a workbench color by key.
  VscodeColor? operator [](String key) => colors[key];

  /// Convenience: `editor.background`.
  VscodeColor? get editorBackground => colors['editor.background'];

  /// Convenience: `editor.foreground`.
  VscodeColor? get editorForeground => colors['editor.foreground'];

  /// Effective brightness: uses [type], else luminance of [editorBackground].
  bool get isDark {
    switch (type) {
      case VscodeThemeType.dark:
      case VscodeThemeType.hcDark:
        return true;
      case VscodeThemeType.light:
      case VscodeThemeType.hcLight:
        return false;
      case null:
        return editorBackground?.isDark ?? true;
    }
  }
}
