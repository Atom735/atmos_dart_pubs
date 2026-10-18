import 'dart:async';

import 'executor.dart';
import 'job.dart';

/// Same-isolate [ParallelExecutor] (no real parallelism — useful for tests).
class LocalParallelExecutor implements ParallelExecutor {
  /// Creates an executor from a [registry] of job handlers.
  LocalParallelExecutor(this.registry);

  /// Job name → handler.
  final ParallelJobRegistry registry;

  var _closed = false;
  var _nextId = 0;

  @override
  bool get isClosed => _closed;

  @override
  Future<Object?> run(String job, Object? input) async {
    if (_closed) {
      throw ParallelException('Executor is closed');
    }
    final handler = registry[job];
    if (handler == null) {
      throw ParallelException('Unknown job "$job"');
    }
    // Yield so callers behave like an async backend.
    await Future<void>.delayed(Duration.zero);
    try {
      return handler(input);
    } on Object catch (e) {
      throw ParallelException('Job "$job" failed', cause: e);
    }
  }

  /// Allocates a unique request id (for backends that need correlation).
  String nextRequestId() => 'local-${_nextId++}';

  @override
  Future<void> close() async {
    _closed = true;
  }
}
