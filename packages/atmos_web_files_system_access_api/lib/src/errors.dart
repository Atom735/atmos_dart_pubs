/// Thrown when the File System Access API is missing or a call fails.
class FileSystemAccessException implements Exception {
  /// Creates an exception with [message] and optional JS [cause].
  FileSystemAccessException(this.message, {this.cause});

  /// Human-readable description.
  final String message;

  /// Underlying JS / Dart error if any.
  final Object? cause;

  @override
  String toString() {
    if (cause == null) return 'FileSystemAccessException: $message';
    return 'FileSystemAccessException: $message ($cause)';
  }
}

/// Thrown when the user cancels a picker (`AbortError`).
class FileSystemAccessAbortException extends FileSystemAccessException {
  /// Creates an abort/cancel exception.
  FileSystemAccessAbortException([super.message = 'User cancelled picker']);
}
