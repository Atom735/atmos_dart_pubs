// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:atmos_jsonc/atmos_jsonc.dart';
import 'package:benchmark_harness/benchmark_harness.dart';

/// Time benchmarks: `JsonDecoder` vs `JsoncDecoder` vs strip+jsonDecode.
///
/// Run from package root:
/// `dart run benchmark/run.dart`
void main() {
  final plain = _generate(items: 5000, jsonc: false);
  final withComments = _generate(items: 5000, jsonc: true);
  final plainUtf8 = utf8.encode(plain);
  final jsoncUtf8Bytes = utf8.encode(withComments);

  print('atmos_jsonc time benchmarks');
  print('plain JSON chars: ${plain.length}');
  print('JSONC chars: ${withComments.length}');
  print('plain UTF-8 bytes: ${plainUtf8.length}');
  print('---');

  final suites = <BenchmarkBase>[
    _JsonDecodeBenchmark('jsonDecode plain', plain),
    _JsoncDecodeBenchmark('jsoncDecode plain', plain),
    _StripThenJsonBenchmark('strip+jsonDecode plain', plain),
    _JsoncDecodeBenchmark('jsoncDecode JSONC', withComments),
    _StripThenJsonBenchmark('strip+jsonDecode JSONC', withComments),
    _ReviverBenchmark('jsoncDecode+identityReviver plain', plain),
    _BindBenchmark('jsoncBind Item list plain', plain),
    _Utf8ThenJsoncBenchmark('utf8.decode+jsoncDecode plain', plainUtf8),
    _JsoncUtf8Benchmark('jsoncDecodeUtf8 plain', plainUtf8),
    _JsoncUtf8Benchmark('jsoncDecodeUtf8 JSONC', jsoncUtf8Bytes),
  ];

  for (final b in suites) {
    b.report();
  }
}

String _generate({required int items, required bool jsonc}) {
  final buf = StringBuffer('[\n');
  for (var i = 0; i < items; i++) {
    if (jsonc) {
      buf.writeln('  // item $i');
    }
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

class _JsonDecodeBenchmark extends BenchmarkBase {
  _JsonDecodeBenchmark(super.name, this.source);
  final String source;
  final JsonDecoder _decoder = const JsonDecoder();

  @override
  void run() {
    final v = _decoder.convert(source);
    if (v is! List) throw StateError('bad');
  }
}

class _JsoncDecodeBenchmark extends BenchmarkBase {
  _JsoncDecodeBenchmark(super.name, this.source);
  final String source;
  final JsoncDecoder _decoder = const JsoncDecoder();

  @override
  void run() {
    final v = _decoder.convert(source);
    if (v is! List) throw StateError('bad');
  }
}

class _StripThenJsonBenchmark extends BenchmarkBase {
  _StripThenJsonBenchmark(super.name, this.source);
  final String source;
  final JsonDecoder _decoder = const JsonDecoder();

  @override
  void run() {
    final v = _decoder.convert(stripJsonc(source));
    if (v is! List) throw StateError('bad');
  }
}

class _ReviverBenchmark extends BenchmarkBase {
  _ReviverBenchmark(super.name, this.source);
  final String source;

  @override
  void run() {
    final v = jsoncDecode(source, reviver: (path, value) => value);
    if (v is! List) throw StateError('bad');
  }
}

class _Item {
  _Item(this.id, this.name);
  final int id;
  final String name;
}

class _ItemBinder implements JsoncBinder<_Item> {
  const _ItemBinder();

  @override
  _Item fromJsonc(JsoncReader reader) {
    reader.expectObject();
    var id = 0;
    var name = '';
    while (reader.nextField()) {
      switch (reader.key) {
        case 'id':
          id = reader.readInt();
        case 'name':
          name = reader.readString();
        default:
          reader.skip();
      }
      reader.endField();
    }
    return _Item(id, name);
  }
}

class _ItemListBinder implements JsoncBinder<List<_Item>> {
  const _ItemListBinder();

  @override
  List<_Item> fromJsonc(JsoncReader reader) {
    reader.expectArray();
    final out = <_Item>[];
    while (reader.nextElement()) {
      out.add(reader.readObject(const _ItemBinder()));
      reader.endElement();
    }
    return out;
  }
}

class _BindBenchmark extends BenchmarkBase {
  _BindBenchmark(super.name, this.source);
  final String source;

  @override
  void run() {
    final v = jsoncBind(source, const _ItemListBinder());
    if (v.isEmpty) throw StateError('bad');
  }
}

class _Utf8ThenJsoncBenchmark extends BenchmarkBase {
  _Utf8ThenJsoncBenchmark(super.name, this.bytes);
  final List<int> bytes;

  @override
  void run() {
    final v = jsoncDecode(utf8.decode(bytes));
    if (v is! List) throw StateError('bad');
  }
}

class _JsoncUtf8Benchmark extends BenchmarkBase {
  _JsoncUtf8Benchmark(super.name, this.bytes);
  final List<int> bytes;
  final JsoncUtf8Decoder _decoder = const JsoncUtf8Decoder();

  @override
  void run() {
    final v = _decoder.convert(bytes);
    if (v is! List) throw StateError('bad');
  }
}
