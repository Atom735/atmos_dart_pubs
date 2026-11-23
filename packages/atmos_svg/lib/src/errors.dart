/// Thrown when SVG / path text cannot be parsed.
///
/// Бросается, если SVG / path-текст нельзя разобрать.
class SvgFormatException implements Exception {
  /// Creates an exception with [message].
  ///
  /// Создаёт исключение с [message].
  SvgFormatException(this.message);

  /// Human-readable reason.
  ///
  /// Человекочитаемая причина.
  final String message;

  @override
  String toString() => 'SvgFormatException: $message';
}
