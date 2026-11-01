import 'dart:js_interop';
import 'dart:js_util' as js_util;
import 'dart:typed_data';

import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

import 'errors.dart';

/// Converts a Dart value into something IndexedDB can structured-clone.
Object? toJs(Object? value) {
  if (value == null || value is num || value is String || value is bool) {
    return value;
  }
  if (value is DateTime) return _date(value);
  if (value is Uint8List) return jsUint8ArrayFromBytes(value);
  if (value is TypedData) return value;
  if (value is Map) {
    return jsify(<Object?, Object?>{
      for (final entry in value.entries) entry.key: toJs(entry.value),
    });
  }
  if (value is Iterable) {
    return jsify(<Object?>[for (final item in value) toJs(item)]);
  }
  return value;
}

/// Converts a structured-clone result back into Dart.
Object? fromJs(Object? value) {
  final bytes = _bytes(value);
  if (bytes != null) return bytes;
  if (value == null || value is num || value is String || value is bool) {
    return value;
  }
  if (value is DateTime || value is Uint8List) return value;
  try {
    return _revive(js_util.dartify(value));
  } on Object {
    return value;
  }
}

Object _date(DateTime value) {
  final ctor = jsGlobal('Date');
  if (ctor == null) {
    throw const IndexedDbException('Date is not available');
  }
  return jsConstruct(ctor, <Object?>[value.millisecondsSinceEpoch]);
}

Uint8List? _bytes(Object? value) {
  if (value is Uint8List) return value;
  if (value is JSUint8Array) return value.toDart;
  if (value is JSArrayBuffer) return jsBytesFromUint8Array(value);
  return null;
}

Object? _revive(Object? value) {
  final bytes = _bytes(value);
  if (bytes != null) return bytes;
  if (value is Map) {
    return <Object?, Object?>{
      for (final entry in value.entries) entry.key: _revive(entry.value),
    };
  }
  if (value is List && value is! Uint8List) {
    return <Object?>[for (final item in value) _revive(item)];
  }
  return value;
}
