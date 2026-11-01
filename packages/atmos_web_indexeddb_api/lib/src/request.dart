import 'dart:async';

import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

import 'errors.dart';

/// Maps a JS failure to [IndexedDbException].
IndexedDbException wrapIndexedDbError(Object? error, String message) {
  if (error == null) return IndexedDbException(message);
  String? name;
  String? detail;
  try {
    name = jsGetProperty<String?>(error, 'name');
  } on Object {
    name = null;
  }
  try {
    detail = jsGetProperty<String?>(error, 'message');
  } on Object {
    detail = null;
  }
  final text = (detail == null || detail.isEmpty) ? message : detail;
  return IndexedDbException(text, name: name, cause: error);
}

/// Subscribes to a DOM event. Listeners stack (`addEventListener`).
void listenJs(
  Object target,
  String type,
  void Function(Object event) handler,
) {
  jsCallMethod<Object?>(
    target,
    'addEventListener',
    <Object?>[type, jsAllowInterop(handler)],
  );
}

/// Completes when [request] fires `success` or `error`.
///
/// The error event is canceled so a failed request does not abort the
/// transaction. Call `IdbTransaction.abort` to abort explicitly.
///
/// Uses a synchronous completer so the `await` continuation runs inside the
/// success task and can start the next request before the transaction commits.
Future<T> completeRequest<T>(
  Object request,
  T Function(Object? result) map,
) {
  final completer = Completer<T>.sync();
  jsSetProperty(
    request,
    'onsuccess',
    jsAllowInterop((Object event) {
      if (completer.isCompleted) return;
      try {
        completer.complete(map(jsGetProperty<Object?>(request, 'result')));
      } on Object catch (error, stack) {
        completer.completeError(error, stack);
      }
    }),
  );
  jsSetProperty(
    request,
    'onerror',
    jsAllowInterop((Object event) {
      if (completer.isCompleted) return;
      try {
        jsCallMethod<Object?>(event, 'preventDefault');
      } on Object {
        // The event cannot be canceled.
      }
      final error = jsGetProperty<Object?>(request, 'error');
      completer.completeError(
        wrapIndexedDbError(error, 'IndexedDB request failed'),
      );
    }),
  );
  return completer.future;
}
