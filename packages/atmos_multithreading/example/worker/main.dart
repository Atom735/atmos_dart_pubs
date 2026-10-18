// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:html';
import 'dart:js_util' as js_util;

import 'package:atmos_multithreading/atmos_multithreading.dart';
import 'package:atmos_web_shared_buffer_api/atmos_web_shared_buffer_api.dart';

/// Dart entry for the demo Web Worker.
///
/// Build (from `example/`):
/// ```bash
/// dart run tool/build_worker.dart
/// ```
///
/// Protocol:
/// - `ParallelMessage` request/response jobs (see below)
/// - `{ type: 'shared', sab, globalSlot, slot }` — attach SharedArrayBuffer
///
/// Jobs:
/// - `getCounter` → `{ name, counter, ticks, sharedGlobal, sharedSlot }`
/// - `heavySum` → `{ name, n, sum, ms }`
/// - `ping` → `'pong'`
void main() {
  final self = DedicatedWorkerGlobalScope.instance;
  final workerName = _workerName(self);

  var counter = 0;
  var ticks = 0;

  SharedInt32Array? shared;
  var globalSlot = 0;
  var slot = -1;

  Timer.periodic(const Duration(milliseconds: 50), (_) {
    counter++;
    ticks++;
    final view = shared;
    if (view == null) return;
    // Cross-worker atomic increments — visible from the main thread.
    if (globalSlot >= 0 && globalSlot < view.length) {
      view.add(globalSlot, 1);
    }
    if (slot >= 0 && slot < view.length) {
      view.add(slot, 1);
    }
  });

  self.onMessage.listen((MessageEvent event) {
    final data = event.data;
    if (data == null) return;

    final type = _prop(data, ParallelMessage.type) ?? _prop(data, 'type');

    // Shared buffer attachment (not a ParallelMessage request).
    if (type == 'shared') {
      try {
        _attachShared(data, (view, g, s) {
          shared = view;
          globalSlot = g;
          slot = s;
          print(
            'worker $workerName attached SAB '
            '(globalSlot=$g slot=$s len=${view.length} '
            'bytes=${view.buffer.byteLength})',
          );
        });
      } on Object catch (e) {
        print('worker $workerName SAB attach failed: $e');
      }
      return;
    }

    if (type != ParallelMessage.typeRequest) return;

    final id = '${_prop(data, ParallelMessage.id)}';
    final job = '${_prop(data, ParallelMessage.job)}';
    final input = _prop(data, ParallelMessage.input);

    try {
      switch (job) {
        case 'getCounter':
          final view = shared;
          _respondOk(self, id, {
            'name': workerName,
            'counter': counter,
            'ticks': ticks,
            'sharedGlobal': view != null &&
                    globalSlot >= 0 &&
                    globalSlot < view.length
                ? view.load(globalSlot)
                : null,
            'sharedSlot':
                view != null && slot >= 0 && slot < view.length
                    ? view.load(slot)
                    : null,
          });
        case 'heavySum':
          final n = _readN(input) ?? 20000000;
          final sw = Stopwatch()..start();
          final sum = _heavySum(n);
          sw.stop();
          _respondOk(self, id, {
            'name': workerName,
            'n': n,
            'sum': sum,
            'ms': sw.elapsedMilliseconds,
          });
        case 'ping':
          _respondOk(self, id, 'pong');
        default:
          _respondError(self, id, 'Unknown job: $job');
      }
    } on Object catch (e) {
      _respondError(self, id, e);
    }
  });

  print('atmos counter worker ready ($workerName)');
}

void _attachShared(
  Object data,
  void Function(SharedInt32Array view, int globalSlot, int slot) onAttach,
) {
  final sabJs = _prop(data, 'sab');
  if (sabJs == null) {
    throw StateError('shared message missing sab');
  }
  final sab = SharedArrayBuffer.fromJs(sabJs);
  if (sab.byteLength < 4) {
    throw StateError('SharedArrayBuffer too small: ${sab.byteLength} bytes');
  }
  final view = SharedInt32Array.fromBuffer(sab);
  final g = _asInt(_prop(data, 'globalSlot')) ?? 0;
  final s = _asInt(_prop(data, 'slot')) ?? -1;
  if (g < 0 || g >= view.length) {
    throw RangeError('globalSlot $g out of range 0..${view.length - 1}');
  }
  if (s >= view.length) {
    throw RangeError('slot $s out of range 0..${view.length - 1}');
  }
  onAttach(view, g, s);
}

String _workerName(DedicatedWorkerGlobalScope self) {
  try {
    final name = js_util.getProperty<Object?>(self, 'name');
    if (name is String && name.isNotEmpty) return name;
  } on Object {
    // fall through
  }
  return 'worker';
}

Object? _prop(Object object, Object key) {
  if (object is Map) {
    return object[key];
  }
  try {
    return js_util.getProperty<Object?>(object, key);
  } on Object {
    return null;
  }
}

int? _asInt(Object? raw) {
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  return int.tryParse('$raw');
}

int? _readN(Object? input) {
  if (input == null) return null;
  return _asInt(_prop(input, 'n'));
}

int _heavySum(int n) {
  var s = 0;
  for (var i = 0; i < n; i++) {
    s += i;
  }
  return s;
}

void _respondOk(DedicatedWorkerGlobalScope self, String id, Object? result) {
  self.postMessage(
    ParallelMessage.responseOk(id: id, result: result),
  );
}

void _respondError(DedicatedWorkerGlobalScope self, String id, Object error) {
  self.postMessage(
    ParallelMessage.responseError(id: id, error: '$error'),
  );
}
