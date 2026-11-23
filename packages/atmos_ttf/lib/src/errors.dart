/// Thrown when font bytes are not a valid `sfnt` container.
///
/// Бросается, если байты не являются корректным контейнером `sfnt`.
class TtfFormatException implements Exception {
  /// Creates an exception with [message].
  ///
  /// Создаёт исключение с [message].
  TtfFormatException(this.message);

  /// Human-readable reason.
  ///
  /// Человекочитаемая причина.
  final String message;

  @override
  String toString() => 'TtfFormatException: $message';
}

/// Thrown when a requested table or glyph is missing or unsupported.
///
/// Бросается, если таблица или глиф отсутствуют или не поддерживаются.
class TtfUnsupportedException implements Exception {
  /// Creates an exception with [message].
  ///
  /// Создаёт исключение с [message].
  TtfUnsupportedException(this.message);

  /// Human-readable reason.
  ///
  /// Человекочитаемая причина.
  final String message;

  @override
  String toString() => 'TtfUnsupportedException: $message';
}
