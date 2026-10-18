import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

/// A `message` event from a worker.
class WorkerMessageEvent {
  /// Wraps a JS `MessageEvent`.
  WorkerMessageEvent(this.jsObject)
      : data = jsGetProperty<Object?>(jsObject, 'data'),
        origin = jsGetProperty<Object?>(jsObject, 'origin') as String? ?? '',
        lastEventId =
            jsGetProperty<Object?>(jsObject, 'lastEventId') as String? ?? '';

  /// Underlying JS event.
  final Object jsObject;

  /// Payload (`event.data`).
  final Object? data;

  /// `event.origin`.
  final String origin;

  /// `event.lastEventId`.
  final String lastEventId;
}

/// An `error` / `messageerror` event from a worker.
class WorkerErrorEvent {
  /// Wraps a JS error event (or raw error value).
  WorkerErrorEvent(this.jsObject);

  /// Underlying JS event / value.
  final Object jsObject;

  /// Best-effort message string.
  String get message {
    try {
      final m = jsGetProperty<Object?>(jsObject, 'message');
      if (m is String) return m;
    } on Object {
      // fall through
    }
    return jsObject.toString();
  }
}
