/// Thrown when IndexedDB is missing or a request fails.
class IndexedDbException implements Exception {
  /// Creates an exception with [message], optional DOM [name], and [cause].
  const IndexedDbException(this.message, {this.name, this.cause});

  /// Human-readable description.
  final String message;

  /// DOMException name (`ConstraintError`, `NotFoundError`, …), if any.
  final String? name;

  /// Underlying JS / Dart error, if any.
  final Object? cause;

  @override
  String toString() {
    if (name == null) return 'IndexedDbException: $message';
    return 'IndexedDbException: $message [$name]';
  }
}

/// Thrown when `indexedDB` is not available (VM, or a browser without it).
class IndexedDbUnsupportedException extends IndexedDbException {
  /// Creates an unsupported-API exception.
  const IndexedDbUnsupportedException() : super('IndexedDB is not available');
}
