import 'color.dart';
import 'generated/workbench_colors.g.dart';
import 'token_color.dart';

/// Theme base kind (`dark` / `light` / high-contrast variants).
///
/// ## ENG
/// Mirrors VS Code `type` when present; otherwise inferred from UI colors.
///
/// ## RU
/// Соответствует `type` VS Code, либо выводится из UI-цветов.
enum VscThemeType {
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
/// Use [colors] for typed access (`theme.colors.editor.background`),
/// [colorMap] / `[]` for raw keys. [tokenColors] are TextMate rules in
/// cascade order (base first, overrides last).
///
/// ## RU
/// [colors] — типизированный доступ (`theme.colors.editor.background`),
/// [colorMap] / `[]` — сырые ключи. [tokenColors] — TextMate-правила.
class VscColorTheme {
  /// Creates a resolved theme.
  ///
  /// [colors] is the merged workbench map (same as [colorMap]).
  const VscColorTheme({
    this.name,
    this.type,
    this.semanticHighlighting,
    Map<String, VscColor> colors = const {},
    this.tokenColors = const [],
    this.semanticTokenColors = const {},
  }) : colorMap = colors;

  /// Display name from the leaf theme JSON.
  final String? name;

  /// Declared or inferred theme type.
  final VscThemeType? type;

  /// Whether semantic highlighting is enabled (`semanticHighlighting`).
  final bool? semanticHighlighting;

  /// Merged workbench colors (`editor.background`, …).
  final Map<String, VscColor> colorMap;

  /// Typed workbench colors (`colors.editor.background`).
  VscWorkbenchColors get colors => VscWorkbenchColors(colorMap);

  /// Merged TextMate token rules (parent rules first).
  final List<VscTokenColor> tokenColors;

  /// Merged semantic token styles.
  final Map<String, VscSemanticTokenStyle> semanticTokenColors;

  /// Looks up a workbench color by key.
  VscColor? operator [](String key) => colorMap[key];

  /// Looks up [key], falling back to [or].
  VscColor? color(String key, {VscColor? or}) => colorMap[key] ?? or;

  /// Convenience: `editor.background`.
  VscColor? get editorBackground => colorMap['editor.background'];

  /// Convenience: `editor.foreground`.
  VscColor? get editorForeground => colorMap['editor.foreground'];

  /// Effective brightness: uses [type], else luminance of [editorBackground].
  bool get isDark {
    switch (type) {
      case VscThemeType.dark:
      case VscThemeType.hcDark:
        return true;
      case VscThemeType.light:
      case VscThemeType.hcLight:
        return false;
      case null:
        return editorBackground?.isDark ?? true;
    }
  }

  /// High-contrast theme (`hcDark` / `hcLight`).
  bool get isHighContrast =>
      type == VscThemeType.hcDark || type == VscThemeType.hcLight;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VscColorTheme) return false;
    if (other.name != name ||
        other.type != type ||
        other.semanticHighlighting != semanticHighlighting) {
      return false;
    }
    if (other.colorMap.length != colorMap.length) return false;
    for (final e in colorMap.entries) {
      if (other.colorMap[e.key] != e.value) return false;
    }
    if (other.tokenColors.length != tokenColors.length) return false;
    for (var i = 0; i < tokenColors.length; i++) {
      if (other.tokenColors[i] != tokenColors[i]) return false;
    }
    if (other.semanticTokenColors.length != semanticTokenColors.length) {
      return false;
    }
    for (final e in semanticTokenColors.entries) {
      if (other.semanticTokenColors[e.key] != e.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        name,
        type,
        semanticHighlighting,
        Object.hashAll(
          colorMap.entries.map((e) => Object.hash(e.key, e.value)),
        ),
        Object.hashAll(tokenColors),
        Object.hashAll(
          semanticTokenColors.entries.map((e) => Object.hash(e.key, e.value)),
        ),
      );
}
