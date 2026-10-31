/// Thrown when the Local Font Access API is missing or a call fails.
///
/// Бросается, если API недоступен или вызов завершился ошибкой.
class LocalFontAccessException implements Exception {
  /// Creates an exception with [message] and optional JS [cause].
  ///
  /// Создаёт исключение с текстом [message] и необязательной причиной [cause].
  const LocalFontAccessException(this.message, {this.cause});

  /// Human-readable description.
  ///
  /// Человекочитаемое описание.
  final String message;

  /// Underlying JS or Dart error, if any.
  ///
  /// Исходная JS- или Dart-ошибка, если есть.
  final Object? cause;

  @override
  String toString() {
    if (cause == null) return 'LocalFontAccessException: $message';
    return 'LocalFontAccessException: $message ($cause)';
  }
}

/// Thrown when local fonts cannot be read (`NotAllowedError`).
///
/// Нет доступа (`NotAllowedError`): отказ пользователя или вызов
/// без user gesture.
class LocalFontAccessNotAllowedException extends LocalFontAccessException {
  /// Creates a not-allowed exception.
  ///
  /// Создаёт исключение отказа в доступе.
  const LocalFontAccessNotAllowedException({super.cause})
      : super('Local font access was denied');
}
