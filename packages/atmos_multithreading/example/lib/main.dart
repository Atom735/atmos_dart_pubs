import 'dart:async';

import 'package:atmos_multithreading_web/atmos_multithreading_web.dart';
import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';
import 'package:atmos_web_shared_buffer_api/atmos_web_shared_buffer_api.dart';
import 'package:atmos_web_worker/atmos_web_worker.dart';
import 'package:flutter/material.dart';

/// Flutter **web** demo: Dart Web Workers + SharedArrayBuffer/Atomics.
///
/// Worker: `worker/main.dart` → `dart run tool/build_worker.dart`
///
/// SharedArrayBuffer: [web/coi_sw.js] adds COOP/COEP for `flutter run -d chrome`
/// (page reloads once after SW install). Optional: `dart run tool/serve_coi.dart`.
void main() {
  runApp(const AtmosMultithreadingDemoApp());
}

class AtmosMultithreadingDemoApp extends StatelessWidget {
  const AtmosMultithreadingDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'atmos_multithreading',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      home: const _DemoPage(),
    );
  }
}

class _WorkerSnapshot {
  const _WorkerSnapshot({
    required this.index,
    required this.name,
    required this.counter,
    required this.ticks,
    this.sharedSlot,
  });

  final int index;
  final String name;
  final int counter;
  final int ticks;
  final int? sharedSlot;
}

class _DemoPage extends StatefulWidget {
  const _DemoPage();

  @override
  State<_DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<_DemoPage> {
  static const _workerScript = 'counter_worker.js';

  /// SAB layout: [0]=global atomic, [2+i]=per-worker atomic.
  static const _sabLength = 16;
  static const _globalSlot = 0;

  WebWorkerParallelExecutor? _pool;
  SharedInt32Array? _shared;
  final _log = <String>[];
  final _snapshots = <_WorkerSnapshot>[];
  var _busy = false;
  var _autoPoll = false;
  Timer? _pollTimer;
  String? _lastHeavy;
  var _sabGlobal = 0;
  final _sabSlots = <int>[];

  bool get _workersOk => isWebWorkerSupported;
  bool get _sabOk => isSharedMemorySupported && isCrossOriginIsolated;

  @override
  void dispose() {
    _pollTimer?.cancel();
    unawaited(_pool?.close());
    super.dispose();
  }

  void _append(String line) {
    setState(() {
      _log.insert(0, '${TimeOfDay.now().format(context)}  $line');
      if (_log.length > 100) _log.removeLast();
    });
  }

  Future<void> _run(String label, Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      _append('→ $label');
      await action();
    } on Object catch (e) {
      _append('error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  WebWorkerParallelExecutor _ensurePool() {
    return _pool ??= WebWorkerParallelExecutor(
      scriptUrl: _workerScript,
      size: 0,
    );
  }

  void _readSharedIntoState() {
    final view = _shared;
    if (view == null) {
      _sabGlobal = 0;
      _sabSlots.clear();
      return;
    }
    if (_globalSlot >= 0 && _globalSlot < view.length) {
      _sabGlobal = view.load(_globalSlot);
    }
    _sabSlots
      ..clear()
      ..addAll([
        for (var i = 0; i < (_pool?.workerCount ?? 0); i++)
          if (2 + i < view.length) view.load(2 + i) else 0,
      ]);
  }

  Future<void> _spawnWorker() async {
    await _run('spawn worker', () async {
      if (!_workersOk) {
        throw UnsupportedError('Web Workers unavailable');
      }
      final pool = _ensurePool();
      final index = pool.addWorker();
      // Re-share SAB so the new worker attaches.
      final shared = _shared;
      if (shared != null) {
        pool.shareCounterBuffer(shared.buffer, globalSlot: _globalSlot);
      }
      _append('spawned worker #$index (total ${pool.workerCount})');
      await _refreshCounters();
    });
  }

  Future<void> _shareBuffer() async {
    await _run('share SharedArrayBuffer', () async {
      if (!isSharedMemorySupported) {
        throw UnsupportedError(
          'SharedArrayBuffer/Atomics missing '
          '(crossOriginIsolated=$isCrossOriginIsolated)',
        );
      }
      if (!isCrossOriginIsolated) {
        throw UnsupportedError(
          'Not cross-origin isolated yet. '
          'Wait for coi_sw.js reload (or hard-refresh once). '
          'Fallback: flutter build web && dart run tool/serve_coi.dart',
        );
      }
      final pool = _ensurePool();
      if (pool.workerCount == 0) {
        pool.addWorker();
      }
      final view = SharedInt32Array(_sabLength);
      for (var i = 0; i < _sabLength; i++) {
        view.store(i, 0);
      }
      pool.shareCounterBuffer(view.buffer, globalSlot: _globalSlot);
      setState(() {
        _shared = view;
        _readSharedIntoState();
      });
      _append(
        'shared Int32[$_sabLength] with ${pool.workerCount} worker(s) '
        '(slot0=global, slot2+=per-worker)',
      );
    });
  }

  Future<void> _resetShared() async {
    await _run('reset SAB counters', () async {
      final view = _shared;
      if (view == null) {
        throw StateError('Share a buffer first');
      }
      for (var i = 0; i < view.length; i++) {
        view.store(i, 0);
      }
      setState(_readSharedIntoState);
      _append('SAB zeroed via Atomics.store');
    });
  }

  Future<void> _refreshCounters() async {
    final pool = _pool;
    if (pool == null || pool.workerCount == 0) {
      setState(() {
        _snapshots.clear();
        _readSharedIntoState();
      });
      return;
    }
    final results = await pool.mapAll('getCounter', null);
    final next = <_WorkerSnapshot>[];
    for (var i = 0; i < results.length; i++) {
      next.add(_parseSnapshot(i, results[i]));
    }
    setState(() {
      _snapshots
        ..clear()
        ..addAll(next);
      _readSharedIntoState();
    });
  }

  _WorkerSnapshot _parseSnapshot(int index, Object? raw) {
    if (raw is Map) {
      return _WorkerSnapshot(
        index: index,
        name: '${raw['name'] ?? 'worker-$index'}',
        counter: _asInt(raw['counter']),
        ticks: _asInt(raw['ticks']),
        sharedSlot: raw['sharedSlot'] == null
            ? null
            : _asInt(raw['sharedSlot']),
      );
    }
    if (raw == null) {
      return _WorkerSnapshot(
        index: index,
        name: 'worker-$index',
        counter: 0,
        ticks: 0,
      );
    }
    final slot = jsGetProperty<Object?>(raw, 'sharedSlot');
    return _WorkerSnapshot(
      index: index,
      name: '${jsGetProperty<Object?>(raw, 'name') ?? 'worker-$index'}',
      counter: _asInt(jsGetProperty<Object?>(raw, 'counter')),
      ticks: _asInt(jsGetProperty<Object?>(raw, 'ticks')),
      sharedSlot: slot == null ? null : _asInt(slot),
    );
  }

  int _asInt(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? 0;
  }

  Future<void> _pollOnce() async {
    await _run('get counters', () async {
      await _refreshCounters();
      _append('counters updated (${_snapshots.length} workers)');
    });
  }

  void _toggleAutoPoll(bool value) {
    setState(() => _autoPoll = value);
    _pollTimer?.cancel();
    _pollTimer = null;
    if (value) {
      _pollTimer = Timer.periodic(
        const Duration(milliseconds: 250),
        (_) {
          unawaited(
            _refreshCounters().catchError((Object e) {
              _append('poll error: $e');
            }),
          );
        },
      );
      _append('auto-poll on');
    } else {
      _append('auto-poll off');
    }
  }

  Future<void> _heavyOne() async {
    await _run('heavySum (1 worker, RR)', () async {
      final pool = _ensurePool();
      if (pool.workerCount == 0) pool.addWorker();
      final sw = Stopwatch()..start();
      final result = await pool.run('heavySum', {'n': 25000000});
      sw.stop();
      setState(() => _lastHeavy = _fmtHeavy(result, sw.elapsedMilliseconds));
      _append('heavy done in ${sw.elapsedMilliseconds} ms (main wait)');
    });
  }

  Future<void> _heavyAll() async {
    await _run('heavySum (all workers parallel)', () async {
      final pool = _ensurePool();
      if (pool.workerCount == 0) {
        pool.addWorker();
        pool.addWorker();
      }
      final sw = Stopwatch()..start();
      final results = await pool.mapAll('heavySum', {'n': 25000000});
      sw.stop();
      final lines = [
        for (var i = 0; i < results.length; i++)
          '#$i ${_fmtHeavy(results[i], null)}',
      ];
      setState(() {
        _lastHeavy =
            'parallel wall ${sw.elapsedMilliseconds} ms\n${lines.join('\n')}';
      });
      _append(
        'parallel heavy on ${results.length} workers, '
        'wall ${sw.elapsedMilliseconds} ms',
      );
      await _refreshCounters();
    });
  }

  String _fmtHeavy(Object? raw, int? wallMs) {
    Object? name;
    Object? ms;
    Object? sum;
    if (raw is Map) {
      name = raw['name'];
      ms = raw['ms'];
      sum = raw['sum'];
    } else if (raw != null) {
      name = jsGetProperty<Object?>(raw, 'name');
      ms = jsGetProperty<Object?>(raw, 'ms');
      sum = jsGetProperty<Object?>(raw, 'sum');
    } else {
      return 'null';
    }
    final wall = wallMs == null ? '' : ', wall ${wallMs}ms';
    return '$name: sum=$sum worker ${ms}ms$wall';
  }

  Future<void> _stopAll() async {
    await _run('stop all workers', () async {
      _pollTimer?.cancel();
      _pollTimer = null;
      _autoPoll = false;
      await _pool?.close();
      _pool = null;
      setState(() {
        _snapshots.clear();
        _lastHeavy = null;
        _shared = null;
        _sabGlobal = 0;
        _sabSlots.clear();
      });
      _append('pool closed');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = _pool?.workerCount ?? 0;
    final sabLabel = !isSharedMemorySupported
        ? 'SAB: missing'
        : !isCrossOriginIsolated
            ? 'SAB: need COI'
            : (_shared == null ? 'SAB: ready' : 'SAB: shared');

    return Scaffold(
      appBar: AppBar(
        title: const Text('atmos_multithreading · web'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_workersOk ? 'Workers: $count' : 'Workers: n/a'} · '
                '$sabLabel',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: _sabOk
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
              ),
            ),
          ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: _busy,
        child: Row(
          children: [
            SizedBox(
              width: 360,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Workers', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _workersOk ? _spawnWorker : null,
                    icon: const Icon(Icons.add),
                    label: const Text('Spawn worker'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: count > 0 ? _pollOnce : null,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Get counters'),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Auto-poll'),
                    value: _autoPoll,
                    onChanged: count > 0 ? _toggleAutoPoll : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'SharedArrayBuffer',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isCrossOriginIsolated
                        ? 'crossOriginIsolated: true'
                        : 'crossOriginIsolated: false — wait for coi_sw reload',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: _workersOk ? _shareBuffer : null,
                    icon: const Icon(Icons.share),
                    label: const Text('Create & share SAB'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _shared != null ? _resetShared : null,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset SAB counters'),
                  ),
                  if (_shared != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Main thread Atomics.load:\n'
                      '  global[0] = $_sabGlobal\n'
                      '  slots    = $_sabSlots',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text('Compute', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: _workersOk ? _heavyOne : null,
                    icon: const Icon(Icons.memory),
                    label: const Text('Heavy job (1 worker)'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: _workersOk ? _heavyAll : null,
                    icon: const Icon(Icons.hub),
                    label: const Text('Heavy job (all parallel)'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: count > 0 || _shared != null ? _stopAll : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop all'),
                  ),
                  if (_lastHeavy != null) ...[
                    const SizedBox(height: 16),
                    Text('Last compute', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    SelectableText(
                      _lastHeavy!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Counters (main thread view)',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      flex: 3,
                      child: _snapshots.isEmpty
                          ? Center(
                              child: Text(
                                'Spawn a worker, then optionally share SAB.\n'
                                'Workers bump msg-counters and atomic slots.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium,
                              ),
                            )
                          : ListView.separated(
                              itemCount: _snapshots.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, i) {
                                final s = _snapshots[i];
                                final sabSlot = i < _sabSlots.length
                                    ? _sabSlots[i]
                                    : s.sharedSlot;
                                final sabPart = sabSlot != null
                                    ? '  sab=$sabSlot'
                                    : '';
                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: Text('${s.index}'),
                                    ),
                                    title: Text(s.name),
                                    subtitle: Text(
                                      'msg=${s.counter}  '
                                      'ticks=${s.ticks}$sabPart',
                                    ),
                                    trailing: Text(
                                      '${s.counter}',
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 12),
                    Text('Log', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Expanded(
                      flex: 2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _log.length,
                          itemBuilder: (context, i) => Text(
                            _log[i],
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
