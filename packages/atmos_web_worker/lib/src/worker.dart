import 'dart:async';

import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

import 'message_event.dart';
import 'support.dart';
import 'worker_options.dart';

/// Dedicated Web Worker wrapper.
class WebWorker {
  /// Creates a worker from [scriptUrl] (classic or module per [options]).
  factory WebWorker(String scriptUrl, [WebWorkerOptions? options]) {
    if (!isWebWorkerSupported) {
      throw UnsupportedError('Worker is not available in this runtime');
    }
    final ctor = jsGlobal('Worker');
    if (ctor == null) {
      throw UnsupportedError('Worker constructor is missing');
    }
    final js = options == null
        ? jsConstruct(ctor, [scriptUrl])
        : jsConstruct(ctor, [scriptUrl, options.toJs()]);
    return WebWorker._(js);
  }

  WebWorker._(this.jsObject) {
    _attachListeners();
  }

  /// Underlying JS `Worker`.
  final Object jsObject;

  final _messages = StreamController<WorkerMessageEvent>.broadcast();
  final _errors = StreamController<WorkerErrorEvent>.broadcast();
  Object? _onMessage;
  Object? _onError;
  Object? _onMessageError;

  /// Incoming `message` events.
  Stream<WorkerMessageEvent> get messages => _messages.stream;

  /// Incoming `error` / `messageerror` events.
  Stream<WorkerErrorEvent> get errors => _errors.stream;

  void _attachListeners() {
    // Store Dart callbacks via allowInterop for JS event handlers.
    _onMessage = jsAllowInterop((Object event) {
      if (!_messages.isClosed) {
        _messages.add(WorkerMessageEvent(event));
      }
    });
    _onError = jsAllowInterop((Object event) {
      if (!_errors.isClosed) {
        _errors.add(WorkerErrorEvent(event));
      }
    });
    _onMessageError = jsAllowInterop((Object event) {
      if (!_errors.isClosed) {
        _errors.add(WorkerErrorEvent(event));
      }
    });

    jsCallMethod<void>(jsObject, 'addEventListener', ['message', _onMessage]);
    jsCallMethod<void>(jsObject, 'addEventListener', ['error', _onError]);
    jsCallMethod<void>(
      jsObject,
      'addEventListener',
      ['messageerror', _onMessageError],
    );
  }

  /// Posts [message]; optional [transfer] list of transferable objects.
  void postMessage(Object? message, [List<Object>? transfer]) {
    if (transfer == null || transfer.isEmpty) {
      jsCallMethod<void>(jsObject, 'postMessage', [message]);
    } else {
      jsCallMethod<void>(
        jsObject,
        'postMessage',
        [message, jsArray(transfer)],
      );
    }
  }

  /// Terminates the worker immediately.
  void terminate() {
    jsCallMethod<void>(jsObject, 'terminate');
  }

  /// Removes listeners and closes Dart streams.
  Future<void> close() async {
    if (_onMessage != null) {
      jsCallMethod<void>(
        jsObject,
        'removeEventListener',
        ['message', _onMessage],
      );
    }
    if (_onError != null) {
      jsCallMethod<void>(
        jsObject,
        'removeEventListener',
        ['error', _onError],
      );
    }
    if (_onMessageError != null) {
      jsCallMethod<void>(
        jsObject,
        'removeEventListener',
        ['messageerror', _onMessageError],
      );
    }
    await _messages.close();
    await _errors.close();
  }
}
