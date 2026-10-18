// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:atmos_jsonc/atmos_jsonc.dart';

/// RSS comparison for large documents (one scenario per process).
///
/// Run all scenarios (spawns child processes):
/// `dart run benchmark/memory.dart`
///
/// Run one scenario:
/// `dart run benchmark/memory.dart jsoncDecodeUtf8_plain`
///
/// Optional: `--define=ITEMS=120000`
void main(List<String> args) {
  const items = int.fromEnvironment('ITEMS', defaultValue: 80000);
  const names = <String>[
    'jsonDecode_plain',
    'jsoncDecode_plain',
    'strip_jsonDecode_plain',
    'jsoncDecode_jsonc',
    'strip_jsonDecode_jsonc',
    'utf8_jsoncDecode_plain',
    'jsoncDecodeUtf8_plain',
    'jsoncDecodeUtf8_jsonc',
  ];

  final scenarioArgs = args.where((a) => a != '--').toList();

  if (scenarioArgs.isEmpty) {
    print('atmos_jsonc memory benchmarks (isolated processes)');
    print('items: $items');
    print('---');
    for (final name in names) {
      final result = Process.runSync(
        Platform.resolvedExecutable,
        ['run', 'benchmark/memory.dart', name],
        workingDirectory: Directory.current.path,
      );
      stdout.write(result.stdout);
      stderr.write(result.stderr);
      if (result.exitCode != 0) {
        exit(result.exitCode);
      }
    }
    return;
  }

  final name = scenarioArgs.first;
  if (!names.contains(name)) {
    stderr.writeln('Unknown scenario: $name');
    stderr.writeln('Known: ${names.join(', ')}');
    exit(2);
  }

  final asJsonc = name.contains('jsonc') && !name.contains('plain');
  final source = _generate(items: items, jsonc: asJsonc);
  final bytes = Uint8List.fromList(utf8.encode(source));

  Object? decode() {
    switch (name) {
      case 'jsonDecode_plain':
      case 'jsonDecode_jsonc':
        return jsonDecode(source);
      case 'jsoncDecode_plain':
      case 'jsoncDecode_jsonc':
        return jsoncDecode(source);
      case 'strip_jsonDecode_plain':
      case 'strip_jsonDecode_jsonc':
        return jsonDecode(stripJsonc(source));
      case 'utf8_jsoncDecode_plain':
        return jsoncDecode(utf8.decode(bytes));
      case 'jsoncDecodeUtf8_plain':
      case 'jsoncDecodeUtf8_jsonc':
        return jsoncDecodeUtf8(bytes);
      default:
        throw StateError(name);
    }
  }

  // Warm-up
  decode();

  final rssBefore = ProcessInfo.currentRss;
  final sw = Stopwatch()..start();
  final value = decode();
  sw.stop();
  final rssAfter = ProcessInfo.currentRss;
  final delta = rssAfter - rssBefore;

  final sourceLabel = name.contains('Utf8') || name.startsWith('utf8_')
      ? 'bytes ${_mb(bytes.length)}'
      : 'chars ${_mb(source.length)}';

  print(
    '$name: ${sw.elapsedMilliseconds} ms, '
    '$sourceLabel, '
    'RSS delta ${_mb(delta)} '
    '(${_mb(rssBefore)} -> ${_mb(rssAfter)}), '
    '${_root(value)}',
  );
}

String _generate({required int items, required bool jsonc}) {
  final buf = StringBuffer('[\n');
  for (var i = 0; i < items; i++) {
    if (jsonc) buf.writeln('  // item $i');
    buf.write(
      '  {"id":$i,"name":"item-$i","ok":true,"vals":[1,2,3${jsonc ? ',' : ''}]'
      '${jsonc ? ',' : ''}}',
    );
    if (i + 1 < items) buf.write(',');
    buf.writeln();
  }
  buf.writeln(']');
  return buf.toString();
}

String _mb(int bytes) => '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MiB';

String _root(Object? value) {
  if (value is List) return 'List(len=${value.length})';
  if (value is Map) return 'Map(len=${value.length})';
  return value.runtimeType.toString();
}
