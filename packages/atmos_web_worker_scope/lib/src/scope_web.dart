import 'dart:async';
import 'dart:js_interop';

import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

import 'host.dart';
import 'message.dart';

final Object _self = globalContext;

/// True inside a dedicated worker.
///
/// A page has no `importScripts`. A service worker has `skipWaiting`.
/// A shared worker has `onconnect`. None of those is
/// `DedicatedWorkerGlobalScope`, which dart2js mis-casts to `Window`.
bool get isDedicatedWorkerScope {
  if (!jsInteropSupported) return false;
  if (!jsHasProperty(_self, 'importScripts')) return false;
  if (jsHasProperty(_self, 'document')) return false;
  if (jsHasProperty(_self, 'skipWaiting')) return false;
  if (jsHasProperty(_self, 'onconnect')) return false;
  return true;
}

WorkerHost? _host;

/// Attaches once, or returns null when this script is not the worker.
WorkerHost? tryAttach() {
  if (!isDedicatedWorkerScope) return null;
  return _host ??= _JsWorkerHost(_self);
}

class _JsWorkerHost implements WorkerHost {
  _JsWorkerHost(this.jsObject) {
    _onMessage = jsAllowInterop((Object event) {
      if (_messages.isClosed) return;
      _messages.add(
        WorkerScopeMessage(
          event,
          jsGetProperty<Object?>(event, 'data'),
        ),
      );
    });
    jsCallMethod<void>(
      jsObject,
      'addEventListener',
      <Object?>['message', _onMessage],
    );
  }

  @override
  final Object jsObject;

  final _messages = StreamController<WorkerScopeMessage>.broadcast();
  Object? _onMessage;

  @override
  Stream<WorkerScopeMessage> get messages => _messages.stream;

  @override
  String get name {
    final raw = jsGetProperty<Object?>(jsObject, 'name');
    return raw is String ? raw : '';
  }

  @override
  void postMessage(Object? message, [List<Object>? transfer]) {
    if (transfer == null || transfer.isEmpty) {
      jsCallMethod<void>(jsObject, 'postMessage', <Object?>[message]);
      return;
    }
    jsCallMethod<void>(
      jsObject,
      'postMessage',
      <Object?>[message, jsArray(transfer)],
    );
  }

  @override
  void importScripts(Iterable<String> urls) {
    final list = urls.toList();
    if (list.isEmpty) return;
    jsCallMethod<void>(jsObject, 'importScripts', list);
  }

  @override
  void close() {
    final handler = _onMessage;
    _onMessage = null;
    if (handler != null) {
      jsCallMethod<void>(
        jsObject,
        'removeEventListener',
        <Object?>['message', handler],
      );
    }
    if (!_messages.isClosed) {
      _messages.close();
    }
    jsCallMethod<void>(jsObject, 'close');
  }
}
