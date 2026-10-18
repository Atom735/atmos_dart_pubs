import 'color.dart';

/// One TextMate token coloring rule from a color theme.
///
/// ## ENG
/// [scope] may be a single selector or several; [foreground] / [fontStyle]
/// come from `settings`.
///
/// ## RU
/// [scope] — один или несколько селекторов; [foreground] / [fontStyle]
/// берутся из `settings`.
class VscodeTokenColor {
  /// Creates a token color rule.
  const VscodeTokenColor({
    this.name,
    this.scope = const [],
    this.foreground,
    this.background,
    this.fontStyle,
  });

  /// Optional human-readable rule name.
  final String? name;

  /// TextMate scope selectors (empty if the rule has no scope).
  final List<String> scope;

  /// Foreground color from `settings.foreground`.
  final VscodeColor? foreground;

  /// Background color from `settings.background`.
  final VscodeColor? background;

  /// Font style string such as `bold`, `italic`, `underline`, or combinations.
  final String? fontStyle;

  /// Parses a `tokenColors` array element.
  factory VscodeTokenColor.fromJson(Map<String, Object?> json) {
    final settings = json['settings'];
    Map<String, Object?>? settingsMap;
    if (settings is Map) {
      settingsMap = settings.cast<String, Object?>();
    }

    return VscodeTokenColor(
      name: json['name'] as String?,
      scope: _parseScope(json['scope']),
      foreground: _colorOf(settingsMap?['foreground']),
      background: _colorOf(settingsMap?['background']),
      fontStyle: settingsMap?['fontStyle'] as String?,
    );
  }

  static List<String> _parseScope(Object? value) {
    if (value == null) return const [];
    if (value is String) {
      final parts = value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      return List<String>.unmodifiable(parts);
    }
    if (value is List) {
      return List<String>.unmodifiable(
        value
            .whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty),
      );
    }
    return const [];
  }

  static VscodeColor? _colorOf(Object? value) {
    if (value is! String) return null;
    return VscodeColor.tryParse(value);
  }
}
