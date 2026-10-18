import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

import 'atomics.dart';
import 'shared_array_buffer.dart';
import 'support.dart';

/// `Int32Array` view over a [SharedArrayBuffer], with Atomics helpers.
class SharedInt32Array {
  /// Allocates a new SAB and an `Int32Array` of [length] elements.
  factory SharedInt32Array(int length) {
    if (length < 1) {
      throw ArgumentError.value(length, 'length', 'must be >= 1');
    }
    final sab = SharedArrayBuffer(length * 4);
    return SharedInt32Array.fromBuffer(sab, length: length);
  }

  /// Creates an `Int32Array` view on an existing [buffer].
  factory SharedInt32Array.fromBuffer(
    SharedArrayBuffer buffer, {
    int? length,
    int byteOffset = 0,
  }) {
    if (!isSharedArrayBufferSupported) {
      throw UnsupportedError('SharedArrayBuffer is not available');
    }
    final ctor = jsGlobal('Int32Array');
    if (ctor == null) {
      throw UnsupportedError('Int32Array is missing');
    }
    final Object js;
    final int len;
    if (length == null && byteOffset == 0) {
      // Prefer `new Int32Array(sab)` — full buffer view.
      js = jsConstruct(ctor, [buffer.jsObject]);
      final raw = jsGetProperty<Object?>(js, 'length');
      len = raw is num ? raw.toInt() : 0;
    } else if (length == null) {
      js = jsConstruct(ctor, [buffer.jsObject, byteOffset]);
      final raw = jsGetProperty<Object?>(js, 'length');
      len = raw is num ? raw.toInt() : 0;
    } else {
      js = jsConstruct(ctor, [buffer.jsObject, byteOffset, length]);
      len = length;
    }
    if (len < 1) {
      throw StateError(
        'Int32Array length is $len (sab bytes=${buffer.byteLength})',
      );
    }
    return SharedInt32Array._(buffer, js, len);
  }

  SharedInt32Array._(this.buffer, this.jsArray, this.length);

  /// Backing shared buffer.
  final SharedArrayBuffer buffer;

  /// Underlying JS `Int32Array`.
  final Object jsArray;

  /// Number of int32 elements.
  final int length;

  /// Non-atomic read (`typedArray[index]`).
  int operator [](int index) {
    final raw = jsGetProperty<Object?>(jsArray, index);
    return raw is num ? raw.toInt() : 0;
  }

  /// Non-atomic write.
  void operator []=(int index, int value) {
    jsSetProperty(jsArray, index, value);
  }

  /// `Atomics.load`.
  int load(int index) => Atomics.load(jsArray, index).toInt();

  /// `Atomics.store`.
  int store(int index, int value) =>
      Atomics.store(jsArray, index, value).toInt();

  /// `Atomics.add` — returns the previous value.
  int add(int index, int value) => Atomics.add(jsArray, index, value).toInt();

  /// `Atomics.sub` — returns the previous value.
  int sub(int index, int value) => Atomics.sub(jsArray, index, value).toInt();
}
