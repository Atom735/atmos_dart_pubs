/// A `message` event delivered to the worker global.
class WorkerScopeMessage {
  /// Wraps the JS event and its [data].
  WorkerScopeMessage(this.jsObject, this.data);

  /// Underlying JS `MessageEvent`.
  final Object jsObject;

  /// Payload (`event.data`). May already be a JS object.
  final Object? data;
}
