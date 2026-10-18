/// Runs named parallel jobs and returns their results.
abstract class ParallelExecutor {
  /// Executes [job] with [input]; completes with the handler result.
  Future<Object?> run(String job, Object? input);

  /// Whether this executor is still accepting work.
  bool get isClosed;

  /// Shuts down workers / releases resources.
  Future<void> close();
}

/// Thrown when a job name is unknown or execution fails.
class ParallelException implements Exception {
  /// Creates an exception.
  ParallelException(this.message, {this.cause});

  /// Human-readable description.
  final String message;

  /// Underlying error, if any.
  final Object? cause;

  @override
  String toString() {
    if (cause == null) return 'ParallelException: $message';
    return 'ParallelException: $message ($cause)';
  }
}
