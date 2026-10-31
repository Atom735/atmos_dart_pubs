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
class VscTokenColor {
  /// Creates a token color rule.
  const VscTokenColor({
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
  final VscColor? foreground;

  /// Background color from `settings.background`.
  final VscColor? background;

  /// Font style string such as `bold`, `italic`, `underline`, or combinations.
  final String? fontStyle;

  /// Parses a `tokenColors` array element.
  factory VscTokenColor.fromJson(Map<String, Object?> json) {
    final settings = json['settings'];
    Map<String, Object?>? settingsMap;
    if (settings is Map) {
      settingsMap = settings.cast<String, Object?>();
    }

    return VscTokenColor(
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

  static VscColor? _colorOf(Object? value) {
    if (value is! String) return null;
    return VscColor.tryParse(value);
  }

  @override
  bool operator ==(Object other) =>
      other is VscTokenColor &&
      other.name == name &&
      _listEquals(other.scope, scope) &&
      other.foreground == foreground &&
      other.background == background &&
      other.fontStyle == fontStyle;

  @override
  int get hashCode => Object.hash(
        name,
        Object.hashAll(scope),
        foreground,
        background,
        fontStyle,
      );
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Style for one semantic token selector (`semanticTokenColors` entry).
///
/// ## ENG
/// Values may be a bare hex string or an object with `foreground` / `fontStyle`.
///
/// ## RU
/// Значение — hex-строка или объект с `foreground` / `fontStyle`.
class VscSemanticTokenStyle {
  /// Creates a semantic token style.
  const VscSemanticTokenStyle({this.foreground, this.fontStyle});

  /// Foreground color when present.
  final VscColor? foreground;

  /// Font style string (`italic`, `bold`, …) when present.
  final String? fontStyle;

  /// Parses a `semanticTokenColors` map value.
  factory VscSemanticTokenStyle.fromJson(Object? value) {
    if (value is String) {
      return VscSemanticTokenStyle(foreground: VscColor.tryParse(value));
    }
    if (value is Map) {
      final map = value.cast<String, Object?>();
      return VscSemanticTokenStyle(
        foreground: map['foreground'] is String
            ? VscColor.tryParse(map['foreground']! as String)
            : null,
        fontStyle: map['fontStyle'] as String?,
      );
    }
    return const VscSemanticTokenStyle();
  }

  @override
  bool operator ==(Object other) =>
      other is VscSemanticTokenStyle &&
      other.foreground == foreground &&
      other.fontStyle == fontStyle;

  @override
  int get hashCode => Object.hash(foreground, fontStyle);
}
