/// Localized string as used in VS Code contribution points.
///
/// ## ENG
/// Either a plain [value] or a `{ "value", "original" }` pair from NLS.
///
/// ## RU
/// Либо обычная строка [value], либо пара `{ "value", "original" }` из NLS.
class VscLocalizedString {
  /// Creates a localized string.
  const VscLocalizedString(this.value, {this.original});

  /// Parses a JSON string or `{ value, original }` object.
  factory VscLocalizedString.fromJson(Object? json) {
    if (json is String) {
      return VscLocalizedString(json);
    }
    if (json is Map) {
      final map = json.cast<String, Object?>();
      final value = map['value'];
      final original = map['original'];
      if (value is String) {
        return VscLocalizedString(
          value,
          original: original is String ? original : null,
        );
      }
    }
    throw FormatException(
      'Expected string or {value, original}, got ${json.runtimeType}',
    );
  }

  /// Display / translated text.
  final String value;

  /// Original (usually English) source text when NLS-split.
  final String? original;

  /// Prefer [value], fall back to [original].
  String get text => value.isNotEmpty ? value : (original ?? '');

  /// JSON suitable for contribution points.
  Object toJson() {
    if (original == null) return value;
    return <String, Object?>{
      'value': value,
      'original': original,
    };
  }

  @override
  String toString() => text;

  @override
  bool operator ==(Object other) =>
      other is VscLocalizedString &&
      other.value == value &&
      other.original == original;

  @override
  int get hashCode => Object.hash(value, original);
}
