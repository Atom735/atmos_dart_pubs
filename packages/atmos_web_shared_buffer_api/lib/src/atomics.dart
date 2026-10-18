import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

import 'support.dart';

Object get _atomics {
  if (!isAtomicsSupported) {
    throw UnsupportedError('Atomics is not available');
  }
  final a = jsGlobal('Atomics');
  if (a == null) {
    throw UnsupportedError('Atomics is missing');
  }
  return a;
}

num _num(Object? v) {
  if (v is num) return v;
  throw StateError('Expected num from Atomics, got $v');
}

/// Static helpers mirroring JS `Atomics.*` on a typed-array view.
///
/// `typedArray` must be an `Int32Array` / `BigInt64Array` / etc. backed by a
/// `SharedArrayBuffer` where required by the operation.
abstract final class Atomics {
  /// `Atomics.load(typedArray, index)`.
  static num load(Object typedArray, int index) =>
      _num(jsCallMethod<Object?>(_atomics, 'load', [typedArray, index]));

  /// `Atomics.store(typedArray, index, value)`.
  static num store(Object typedArray, int index, num value) => _num(
        jsCallMethod<Object?>(_atomics, 'store', [typedArray, index, value]),
      );

  /// `Atomics.add(typedArray, index, value)`.
  static num add(Object typedArray, int index, num value) =>
      _num(jsCallMethod<Object?>(_atomics, 'add', [typedArray, index, value]));

  /// `Atomics.sub(typedArray, index, value)`.
  static num sub(Object typedArray, int index, num value) =>
      _num(jsCallMethod<Object?>(_atomics, 'sub', [typedArray, index, value]));

  /// `Atomics.and(typedArray, index, value)`.
  static num and(Object typedArray, int index, num value) =>
      _num(jsCallMethod<Object?>(_atomics, 'and', [typedArray, index, value]));

  /// `Atomics.or(typedArray, index, value)`.
  static num or(Object typedArray, int index, num value) =>
      _num(jsCallMethod<Object?>(_atomics, 'or', [typedArray, index, value]));

  /// `Atomics.xor(typedArray, index, value)`.
  static num xor(Object typedArray, int index, num value) =>
      _num(jsCallMethod<Object?>(_atomics, 'xor', [typedArray, index, value]));

  /// `Atomics.exchange(typedArray, index, value)`.
  static num exchange(Object typedArray, int index, num value) => _num(
        jsCallMethod<Object?>(_atomics, 'exchange', [typedArray, index, value]),
      );

  /// `Atomics.compareExchange(typedArray, index, expected, replacement)`.
  static num compareExchange(
    Object typedArray,
    int index,
    num expectedValue,
    num replacementValue,
  ) =>
      _num(
        jsCallMethod<Object?>(
          _atomics,
          'compareExchange',
          [typedArray, index, expectedValue, replacementValue],
        ),
      );

  /// `Atomics.wait(typedArray, index, value, [timeout])`.
  ///
  /// Returns `'ok'`, `'not-equal'`, or `'timed-out'`.
  static String wait(
    Object typedArray,
    int index,
    num value, [
    num? timeout,
  ]) {
    final result = timeout == null
        ? jsCallMethod<Object?>(_atomics, 'wait', [typedArray, index, value])
        : jsCallMethod<Object?>(
            _atomics,
            'wait',
            [typedArray, index, value, timeout],
          );
    if (result is String) return result;
    return result?.toString() ?? 'ok';
  }

  /// `Atomics.notify(typedArray, index, [count])`.
  static int notify(Object typedArray, int index, [int? count]) {
    final result = count == null
        ? jsCallMethod<Object?>(_atomics, 'notify', [typedArray, index])
        : jsCallMethod<Object?>(_atomics, 'notify', [typedArray, index, count]);
    return _num(result).toInt();
  }

  /// `Atomics.isLockFree(size)`.
  static bool isLockFree(int size) =>
      jsCallMethod<Object?>(_atomics, 'isLockFree', [size]) == true;
}
