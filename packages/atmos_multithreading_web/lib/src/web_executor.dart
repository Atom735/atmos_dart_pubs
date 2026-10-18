import 'dart:async';

import 'package:atmos_multithreading/atmos_multithreading.dart';
import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';
import 'package:atmos_web_shared_buffer_api/atmos_web_shared_buffer_api.dart';
import 'package:atmos_web_worker/atmos_web_worker.dart';

/// [ParallelExecutor] backed by a pool of dedicated [WebWorker]s.
///
/// Each `run` sends a [ParallelMessage] request and waits for a response with
/// the same `id`. Workers must implement that protocol in their script.
class WebWorkerParallelExecutor implements ParallelExecutor {
  /// Creates a pool loading [scriptUrl].
  ///
  /// [size] may be `0` — call [addWorker] later (useful for demos).
  factory WebWorkerParallelExecutor({
    required String scriptUrl,
    int size = 1,
    WebWorkerOptions? options,
  }) {
    if (size < 0) {
      throw ArgumentError.value(size, 'size', 'must be >= 0');
    }
    if (!isWebWorkerSupported) {
      throw UnsupportedError('Web Workers are not available');
    }
    final exec = WebWorkerParallelExecutor._(scriptUrl, options);
    for (var i = 0; i < size; i++) {
      exec.addWorker();
    }
    return exec;
  }

  WebWorkerParallelExecutor._(this._scriptUrl, this._options);

  final String _scriptUrl;
  final WebWorkerOptions? _options;
  final List<_PooledWorker> _workers = [];
  var _rr = 0;
  var _closed = false;
  var _nextId = 0;
  var _nextWorkerName = 1;

  /// Number of live workers.
  int get workerCount => _workers.length;

  @override
  bool get isClosed => _closed;

  String _id() => 'w-${_nextId++}';

  /// Spawns one more worker from the same script URL.
  int addWorker() {
    if (_closed) {
      throw ParallelException('Executor is closed');
    }
    final name = 'atmos-worker-${_nextWorkerName++}';
    final opts = WebWorkerOptions(
      type: _options?.type ?? 'classic',
      credentials: _options?.credentials ?? 'same-origin',
      name: _options?.name ?? name,
    );
    _workers.add(_PooledWorker(WebWorker(_scriptUrl, opts)));
    return _workers.length - 1;
  }

  _PooledWorker _requireWorker(int index) {
    if (_workers.isEmpty) {
      throw ParallelException('No workers — call addWorker() first');
    }
    if (index < 0 || index >= _workers.length) {
      throw ParallelException('Worker index $index out of range');
    }
    return _workers[index];
  }

  _PooledWorker _nextWorker() {
    if (_workers.isEmpty) {
      throw ParallelException('No workers — call addWorker() first');
    }
    final w = _workers[_rr % _workers.length];
    _rr++;
    return w;
  }

  Future<Object?> _runOnWorker(
    _PooledWorker worker,
    String job,
    Object? input,
  ) {
    final id = _id();
    final request = ParallelMessage.request(id: id, job: job, input: input);
    final completer = Completer<Object?>();
    worker.pending[id] = completer;
    try {
      worker.worker.postMessage(jsify(request));
    } on Object catch (e) {
      worker.pending.remove(id);
      throw ParallelException('Failed to post job "$job"', cause: e);
    }
    return completer.future;
  }

  @override
  Future<Object?> run(String job, Object? input) async {
    if (_closed) {
      throw ParallelException('Executor is closed');
    }
    return _runOnWorker(_nextWorker(), job, input);
  }

  /// Runs [job] on a specific worker by [index].
  Future<Object?> runOn(int index, String job, Object? input) async {
    if (_closed) {
      throw ParallelException('Executor is closed');
    }
    return _runOnWorker(_requireWorker(index), job, input);
  }

  /// Runs the same [job] on every worker in parallel.
  Future<List<Object?>> mapAll(String job, Object? input) async {
    if (_closed) {
      throw ParallelException('Executor is closed');
    }
    if (_workers.isEmpty) {
      throw ParallelException('No workers — call addWorker() first');
    }
    return Future.wait([
      for (final w in _workers) _runOnWorker(w, job, input),
    ]);
  }

  /// Posts [message] with [transfer] list to every worker.
  void broadcastTransfer(Object message, List<Object> transfer) {
    for (final w in _workers) {
      w.worker.postMessage(jsify(message) ?? message, transfer);
    }
  }

  /// Shares a [SharedArrayBuffer] with every worker (structured-clone share).
  ///
  /// Do **not** put the SAB in the transfer list — it is shared by reference.
  /// Do **not** `jsify` the SAB itself (that breaks the shared buffer).
  void broadcastSharedBuffer(SharedArrayBuffer sab) {
    for (final w in _workers) {
      w.worker.postMessage(_sharedMessage(sab));
    }
  }

  /// Shares [sab] and assigns each worker a private Int32 slot (`2+index`).
  ///
  /// Convention used by the example:
  /// - slot `0` — global atomic counter (all workers `Atomics.add`)
  /// - slot `2+i` — per-worker atomic counter
  void shareCounterBuffer(
    SharedArrayBuffer sab, {
    int globalSlot = 0,
  }) {
    for (var i = 0; i < _workers.length; i++) {
      _workers[i].worker.postMessage(
        _sharedMessage(sab, globalSlot: globalSlot, slot: 2 + i),
      );
    }
  }

  /// Builds a plain JS object with a raw SAB property (no [jsify]).
  static Object _sharedMessage(
    SharedArrayBuffer sab, {
    int? globalSlot,
    int? slot,
  }) {
    final msg = jsNewObject();
    jsSetProperty(msg, 'type', 'shared');
    jsSetProperty(msg, 'sab', sab.jsObject);
    if (globalSlot != null) {
      jsSetProperty(msg, 'globalSlot', globalSlot);
    }
    if (slot != null) {
      jsSetProperty(msg, 'slot', slot);
    }
    return msg;
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    for (final w in _workers) {
      for (final c in w.pending.values) {
        if (!c.isCompleted) {
          c.completeError(ParallelException('Executor closed'));
        }
      }
      w.pending.clear();
      await w.dispose();
    }
    _workers.clear();
  }
}

class _PooledWorker {
  _PooledWorker(this.worker) {
    _sub = worker.messages.listen(_onMessage);
    _errSub = worker.errors.listen(_onError);
  }

  final WebWorker worker;
  final Map<String, Completer<Object?>> pending = {};
  late final StreamSubscription<WorkerMessageEvent> _sub;
  late final StreamSubscription<WorkerErrorEvent> _errSub;

  void _onMessage(WorkerMessageEvent event) {
    final map = _asResponseMap(event.data);
    if (map == null) return;
    if (map[ParallelMessage.type] != ParallelMessage.typeResponse) return;
    final id = map[ParallelMessage.id]?.toString();
    if (id == null) return;
    final completer = pending.remove(id);
    if (completer == null || completer.isCompleted) return;
    final error = map[ParallelMessage.error];
    if (error != null) {
      completer.completeError(ParallelException(error.toString()));
    } else {
      completer.complete(map[ParallelMessage.result]);
    }
  }

  void _onError(WorkerErrorEvent event) {
    final err = ParallelException(event.message);
    for (final c in pending.values) {
      if (!c.isCompleted) c.completeError(err);
    }
    pending.clear();
  }

  Map<Object?, Object?>? _asResponseMap(Object? data) {
    if (data is Map) {
      return data.cast<Object?, Object?>();
    }
    if (data == null || !jsInteropSupported) return null;
    try {
      final type = jsGetProperty<Object?>(data, ParallelMessage.type);
      if (type == null) return null;
      return {
        ParallelMessage.type: type,
        ParallelMessage.id: jsGetProperty<Object?>(data, ParallelMessage.id),
        ParallelMessage.result:
            jsGetProperty<Object?>(data, ParallelMessage.result),
        ParallelMessage.error:
            jsGetProperty<Object?>(data, ParallelMessage.error),
      };
    } on Object {
      return null;
    }
  }

  Future<void> dispose() async {
    await _sub.cancel();
    await _errSub.cancel();
    worker.terminate();
    await worker.close();
  }
}
