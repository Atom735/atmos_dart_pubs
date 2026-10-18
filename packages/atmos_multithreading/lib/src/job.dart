/// A named parallel job handler.
///
/// [input] / return value should be JSON-like (or otherwise transferable) when
/// crossing isolate / worker boundaries.
typedef ParallelJobHandler = Object? Function(Object? input);

/// Registry of job name → handler.
typedef ParallelJobRegistry = Map<String, ParallelJobHandler>;
