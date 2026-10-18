/// Base error for filesystem operations.
class FileSystemException implements Exception {
  /// Creates an exception with [message] for optional [uri].
  FileSystemException(this.message, {this.uri, this.cause});

  /// Human-readable description.
  final String message;

  /// Related resource, if any.
  final Uri? uri;

  /// Underlying error.
  final Object? cause;

  @override
  String toString() {
    final loc = uri == null ? '' : ' ($uri)';
    final why = cause == null ? '' : ': $cause';
    return 'FileSystemException: $message$loc$why';
  }
}

/// Resource does not exist.
class FileNotFoundException extends FileSystemException {
  /// Creates a not-found error.
  FileNotFoundException(Uri uri, {Object? cause})
      : super('File not found', uri: uri, cause: cause);
}

/// Resource already exists and overwrite was not allowed.
class FileExistsException extends FileSystemException {
  /// Creates an exists error.
  FileExistsException(Uri uri, {Object? cause})
      : super('File already exists', uri: uri, cause: cause);
}

/// Operation is not supported by the provider / capabilities.
class FileSystemUnavailableException extends FileSystemException {
  /// Creates an unavailable/unsupported error.
  FileSystemUnavailableException(String message, {Uri? uri, Object? cause})
      : super(message, uri: uri, cause: cause);
}
