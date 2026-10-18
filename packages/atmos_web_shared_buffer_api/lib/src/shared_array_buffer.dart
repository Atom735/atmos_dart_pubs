import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

import 'support.dart';

/// Wrapper around a JS `SharedArrayBuffer`.
class SharedArrayBuffer {
  /// Allocates a new SharedArrayBuffer of [byteLength] bytes.
  factory SharedArrayBuffer(int byteLength) {
    if (!isSharedArrayBufferSupported) {
      throw UnsupportedError('SharedArrayBuffer is not available');
    }
    final ctor = jsGlobal('SharedArrayBuffer');
    if (ctor == null) {
      throw UnsupportedError('SharedArrayBuffer constructor is missing');
    }
    return SharedArrayBuffer.fromJs(jsConstruct(ctor, [byteLength]));
  }

  /// Wraps an existing JS SharedArrayBuffer object.
  SharedArrayBuffer.fromJs(this.jsObject);

  /// Underlying JS object.
  final Object jsObject;

  /// Size in bytes.
  int get byteLength {
    final raw = jsGetProperty<Object?>(jsObject, 'byteLength');
    return raw is num ? raw.toInt() : 0;
  }

  /// Returns a slice `[begin, end)`.
  SharedArrayBuffer slice([int begin = 0, int? end]) {
    final result = end == null
        ? jsCallMethod<Object>(jsObject, 'slice', [begin])
        : jsCallMethod<Object>(jsObject, 'slice', [begin, end]);
    return SharedArrayBuffer.fromJs(result);
  }
}
