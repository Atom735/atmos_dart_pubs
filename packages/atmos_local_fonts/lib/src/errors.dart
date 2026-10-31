/// Thrown when a local-font operation fails.
///
/// Бросается, если операция с локальными шрифтами не удалась.
class LocalFontsException implements Exception {
  /// Creates an exception with [message] and optional [cause].
  ///
  /// Создаёт исключение с текстом [message] и необязательной причиной [cause].
  const LocalFontsException(this.message, {this.cause});

  /// Human-readable description.
  ///
  /// Человекочитаемое описание.
  final String message;

  /// Underlying error, if any.
  ///
  /// Исходная ошибка, если есть.
  final Object? cause;

  @override
  String toString() {
    final why = cause == null ? '' : ' ($cause)';
    return 'LocalFontsException: $message$why';
  }
}

/// Thrown when the runtime cannot list local fonts.
///
/// Бросается, если в этом окружении нельзя получить список шрифтов.
class LocalFontsUnsupportedException extends LocalFontsException {
  /// Creates an unsupported-runtime exception.
  ///
  /// Создаёт исключение неподдерживаемого окружения.
  const LocalFontsUnsupportedException([
    super.message = 'Local fonts are not available in this runtime',
  ]);
}

/// Thrown when the user or the platform denies local-font access.
///
/// Бросается, если пользователь или платформа запретили доступ.
class LocalFontsNotAllowedException extends LocalFontsException {
  /// Creates a not-allowed exception.
  ///
  /// Создаёт исключение отказа в доступе.
  const LocalFontsNotAllowedException({super.cause})
      : super('Local font access was denied');
}
