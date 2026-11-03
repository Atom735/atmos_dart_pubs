import 'dart:typed_data';

import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

import 'shared_array_buffer.dart';
import 'support.dart';

/// `Uint8Array` view over a [SharedArrayBuffer].
class SharedUint8Array {
  /// Allocates a new SAB of [length] bytes and a `Uint8Array` over it.
  factory SharedUint8Array(int length) {
    if (length < 1) {
      throw ArgumentError.value(length, 'length', 'must be >= 1');
    }
    return SharedUint8Array.fromBuffer(SharedArrayBuffer(length));
  }

  /// Creates a `Uint8Array` view on an existing [buffer].
  factory SharedUint8Array.fromBuffer(
    SharedArrayBuffer buffer, {
    int? length,
    int byteOffset = 0,
  }) {
    if (!isSharedArrayBufferSupported) {
      throw UnsupportedError('SharedArrayBuffer is not available');
    }
    final ctor = jsGlobal('Uint8Array');
    if (ctor == null) {
      throw UnsupportedError('Uint8Array is missing');
    }
    final Object js;
    if (length == null && byteOffset == 0) {
      js = jsConstruct(ctor, <Object?>[buffer.jsObject]);
    } else if (length == null) {
      js = jsConstruct(ctor, <Object?>[buffer.jsObject, byteOffset]);
    } else {
      js = jsConstruct(ctor, <Object?>[buffer.jsObject, byteOffset, length]);
    }
    final raw = jsGetProperty<Object?>(js, 'length');
    final len = length ?? (raw is num ? raw.toInt() : 0);
    if (len < 1) {
      throw StateError('Uint8Array length is $len');
    }
    return SharedUint8Array._(buffer, js, len);
  }

  SharedUint8Array._(this.buffer, this.jsArray, this.length);

  /// Backing shared buffer.
  final SharedArrayBuffer buffer;

  /// Underlying JS `Uint8Array`.
  final Object jsArray;

  /// Number of bytes in the view.
  final int length;

  /// Non-atomic read.
  int operator [](int index) {
    final raw = jsGetProperty<Object?>(jsArray, index);
    return raw is num ? raw.toInt() : 0;
  }

  /// Non-atomic write. [value] is masked to a byte.
  void operator []=(int index, int value) {
    jsSetProperty(jsArray, index, value & 0xFF);
  }

  /// Copies [bytes] into the view at [start].
  void setRange(int start, Uint8List bytes) {
    if (bytes.isEmpty) return;
    final src = jsUint8ArrayFromBytes(bytes);
    final view = _subview(start, bytes.length);
    jsCallMethod<Object?>(view, 'set', <Object?>[src]);
  }

  /// Copies [length] bytes starting at [start] into a Dart list.
  Uint8List copyRange(int start, int length) {
    if (length <= 0) return Uint8List(0);
    return jsBytesFromUint8Array(_subview(start, length));
  }

  Object _subview(int start, int length) {
    final ctor = jsGlobal('Uint8Array');
    if (ctor == null) {
      throw UnsupportedError('Uint8Array is missing');
    }
    return jsConstruct(ctor, <Object?>[buffer.jsObject, start, length]);
  }
}
