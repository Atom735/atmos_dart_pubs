// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:benchmark_harness/benchmark_harness.dart';

/// Run from package root:
/// `dart run benchmark/run.dart`
void main() {
  final suites = <BenchmarkBase>[
    WriteInt32ScalarBenchmark(),
    ReadInt32ScalarBenchmark(),
    WriteFloat64ScalarBenchmark(),
    ReadFloat64ScalarBenchmark(),
    WriteSizePackedBenchmark(),
    ReadSizePackedBenchmark(),
    WriteListInt32CallbackBenchmark(),
    WriteListInt32AVBenchmark(),
    ReadListInt32CallbackBenchmark(),
    ReadListInt32AVBenchmark(),
    Float16RoundTripBenchmark(),
    BFloat16RoundTripBenchmark(),
    WriterToBytesBenchmark(),
    WriterTakeBytesBenchmark(),
  ];

  print('atmos_binary_buffer benchmarks');
  print('Dart ${const String.fromEnvironment('DART_VERSION', defaultValue: '')}');
  print('---');
  for (final b in suites) {
    b.report();
  }
}

const _iters = 50000;
const _listLen = 4096;

Uint8List _prepareInt32Payload() {
  final w = BinaryWriter();
  for (var i = 0; i < _iters; i++) {
    w.writeInt32(i);
  }
  return w.takeBytes();
}

Uint8List _prepareFloat64Payload() {
  final w = BinaryWriter();
  for (var i = 0; i < _iters; i++) {
    w.writeFloat64(i.toDouble());
  }
  return w.takeBytes();
}

Uint8List _prepareSizePayload() {
  final w = BinaryWriter();
  for (var i = 0; i < _iters; i++) {
    w.writeSize(i & 0x3FFF);
  }
  return w.takeBytes();
}

Uint8List _prepareListInt32CallbackPayload() {
  final w = BinaryWriter();
  w.writeListInt32(List<int>.generate(_listLen, (i) => i), size: _listLen);
  return w.takeBytes();
}

Uint8List _prepareListInt32AVPayload() {
  final w = BinaryWriter();
  w.writeListInt32AV(List<int>.generate(_listLen, (i) => i), size: _listLen);
  return w.takeBytes();
}

class WriteInt32ScalarBenchmark extends BenchmarkBase {
  WriteInt32ScalarBenchmark() : super('write Int32 x$_iters (prealloc)');

  @override
  void run() {
    final w = BinaryWriter.withCapacity(_iters * 4);
    for (var i = 0; i < _iters; i++) {
      w.writeInt32(i);
    }
  }
}

class ReadInt32ScalarBenchmark extends BenchmarkBase {
  ReadInt32ScalarBenchmark() : super('read Int32 x$_iters');

  late Uint8List _bytes;

  @override
  void setup() => _bytes = _prepareInt32Payload();

  @override
  void run() {
    final r = BinaryReader(_bytes);
    for (var i = 0; i < _iters; i++) {
      r.readInt32();
    }
  }
}

class WriteFloat64ScalarBenchmark extends BenchmarkBase {
  WriteFloat64ScalarBenchmark() : super('write Float64 x$_iters (prealloc)');

  @override
  void run() {
    final w = BinaryWriter.withCapacity(_iters * 8);
    for (var i = 0; i < _iters; i++) {
      w.writeFloat64(i.toDouble());
    }
  }
}

class ReadFloat64ScalarBenchmark extends BenchmarkBase {
  ReadFloat64ScalarBenchmark() : super('read Float64 x$_iters');

  late Uint8List _bytes;

  @override
  void setup() => _bytes = _prepareFloat64Payload();

  @override
  void run() {
    final r = BinaryReader(_bytes);
    for (var i = 0; i < _iters; i++) {
      r.readFloat64();
    }
  }
}

class WriteSizePackedBenchmark extends BenchmarkBase {
  WriteSizePackedBenchmark() : super('writeSize packed x$_iters (prealloc)');

  @override
  void run() {
    final w = BinaryWriter.withCapacity(_iters * 2);
    for (var i = 0; i < _iters; i++) {
      w.writeSize(i & 0x3FFF);
    }
  }
}

class ReadSizePackedBenchmark extends BenchmarkBase {
  ReadSizePackedBenchmark() : super('readSize packed x$_iters');

  late Uint8List _bytes;

  @override
  void setup() => _bytes = _prepareSizePayload();

  @override
  void run() {
    final r = BinaryReader(_bytes);
    for (var i = 0; i < _iters; i++) {
      r.readSize();
    }
  }
}

class WriteListInt32CallbackBenchmark extends BenchmarkBase {
  WriteListInt32CallbackBenchmark() : super('writeListInt32 callback x$_listLen');

  late List<int> _data;

  @override
  void setup() => _data = List<int>.generate(_listLen, (i) => i);

  @override
  void run() {
    final w = BinaryWriter();
    w.writeListInt32(_data, size: _listLen);
  }
}

class WriteListInt32AVBenchmark extends BenchmarkBase {
  WriteListInt32AVBenchmark() : super('writeListInt32AV x$_listLen');

  late List<int> _data;

  @override
  void setup() => _data = List<int>.generate(_listLen, (i) => i);

  @override
  void run() {
    final w = BinaryWriter();
    w.writeListInt32AV(_data, size: _listLen);
  }
}

class ReadListInt32CallbackBenchmark extends BenchmarkBase {
  ReadListInt32CallbackBenchmark() : super('readListInt32 callback x$_listLen');

  late Uint8List _bytes;

  @override
  void setup() => _bytes = _prepareListInt32CallbackPayload();

  @override
  void run() {
    BinaryReader(_bytes).readListInt32(size: _listLen);
  }
}

class ReadListInt32AVBenchmark extends BenchmarkBase {
  ReadListInt32AVBenchmark() : super('readListInt32AV x$_listLen');

  late Uint8List _bytes;

  @override
  void setup() => _bytes = _prepareListInt32AVPayload();

  @override
  void run() {
    BinaryReader(_bytes).readListInt32AV(size: _listLen);
  }
}

class Float16RoundTripBenchmark extends BenchmarkBase {
  Float16RoundTripBenchmark() : super('float16 encode+decode x$_iters');

  @override
  void run() {
    for (var i = 0; i < _iters; i++) {
      final bits = doubleToFloat16(i * 0.01);
      float16ToDouble(bits);
    }
  }
}

class BFloat16RoundTripBenchmark extends BenchmarkBase {
  BFloat16RoundTripBenchmark() : super('bfloat16 encode+decode x$_iters');

  @override
  void run() {
    for (var i = 0; i < _iters; i++) {
      final bits = doubleToBFloat16(i * 0.01);
      bFloat16ToDouble(bits);
    }
  }
}

class WriterToBytesBenchmark extends BenchmarkBase {
  WriterToBytesBenchmark() : super('toBytes after ${_iters ~/ 10} int32');

  @override
  void run() {
    final w = BinaryWriter();
    final n = _iters ~/ 10;
    for (var i = 0; i < n; i++) {
      w.writeInt32(i);
    }
    w.toBytes();
  }
}

class WriterTakeBytesBenchmark extends BenchmarkBase {
  WriterTakeBytesBenchmark() : super('takeBytes after ${_iters ~/ 10} int32');

  @override
  void run() {
    final w = BinaryWriter();
    final n = _iters ~/ 10;
    for (var i = 0; i < n; i++) {
      w.writeInt32(i);
    }
    w.takeBytes();
  }
}
