import 'host.dart';
import 'message.dart';
import 'scope_stub.dart' if (dart.library.js_interop) 'scope_web.dart' as impl;

/// Whether this script is the dedicated worker global, not the page.
bool get isDedicatedWorkerScope => impl.isDedicatedWorkerScope;

/// Global scope of the dedicated worker that is running this script.
///
/// Null on the VM, in a page, and in a service or shared worker.
/// The script can be opened as a page without throwing: dart2js rejects
/// `DedicatedWorkerGlobalScope` there because it sees a `Window`.
class WorkerScope {
  WorkerScope._(this._host);

  static WorkerScope? _current;

  /// The running worker, or null when this is not one.
  static WorkerScope? get current {
    final existing = _current;
    if (existing != null) return existing;
    final host = impl.tryAttach();
    if (host == null) return null;
    return _current = WorkerScope._(host);
  }

  final WorkerHost _host;

  /// JS `self`.
  Object get jsObject => _host.jsObject;

  /// Incoming `message` events.
  Stream<WorkerScopeMessage> get messages => _host.messages;

  /// `self.name`, or empty when the page did not set one.
  String get name => _host.name;

  /// `self.postMessage`.
  ///
  /// [message] is sent as-is. Pass a JS value, or a Dart value already
  /// converted with `jsify`, so handles and shared buffers are not copied.
  /// [transfer] is the transfer list.
  void postMessage(Object? message, [List<Object>? transfer]) {
    _host.postMessage(message, transfer);
  }

  /// `self.importScripts` for each URL.
  void importScripts(Iterable<String> urls) {
    _host.importScripts(urls);
  }

  /// `self.close`. Further messages are dropped.
  void close() {
    _host.close();
  }
}
