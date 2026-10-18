import 'dart:js_interop';
import 'dart:js_util' as js_util;
import 'dart:typed_data';

import 'js_extensions.dart';

Future<T> jsPromiseToFuture<T>(Object promise) {
  final p = promise as JSPromise;
  return p.toDartAs<T>();
}

bool jsIsPromise(Object? value) {
  if (value == null) return false;
  try {
    if (value is JSPromise) return true;
    final obj = value as JSObject;
    return obj['then'] != null;
  } on Object {
    return false;
  }
}

Future<T> jsMaybePromiseToFuture<T>(Object? value) async {
  if (value == null) {
    return null as T;
  }
  if (jsIsPromise(value)) {
    return jsPromiseToFuture<T>(value);
  }
  return value as T;
}

T jsGetProperty<T>(Object object, Object name) {
  if (name is String) {
    final v = (object as JSObject)[name];
    return v as T;
  }
  return js_util.getProperty<T>(object, name);
}

void jsSetProperty(Object object, Object name, Object? value) {
  if (name is String) {
    (object as JSObject)[name] = value as JSAny?;
    return;
  }
  js_util.setProperty(object, name, value);
}

bool jsHasProperty(Object object, Object name) {
  if (name is String) {
    return js_util.hasProperty(object, name);
  }
  return js_util.hasProperty(object, name);
}

T jsCallMethod<T>(Object object, String method, [List<Object?>? args]) {
  final result = js_util.callMethod(
    object,
    method,
    args ?? const <Object?>[],
  );
  return result as T;
}

Object? jsGlobal(String path) {
  JSAny? current = jsGlobalThis;
  for (final part in path.split('.')) {
    if (current == null) return null;
    if (current is! JSObject) return null;
    current = current[part];
  }
  return current;
}

Object jsNewObject() => js_util.newObject<JSObject>();

Object jsConstruct(Object constructor, [List<Object?>? args]) {
  return js_util.callConstructor(
    constructor,
    args ?? const <Object?>[],
  ) as Object;
}

Object? jsify(Object? value) {
  if (value == null) return null;
  return value.jsify();
}

Object jsArray(Iterable<Object?> items) {
  // Prefer List.toJS — `JSArray()` factory crashes dart2js 3.2 static-interop eraser.
  final list = <JSAny?>[
    for (final item in items) item as JSAny?,
  ];
  return list.toJS;
}

Object jsUint8ArrayFromBytes(Uint8List bytes) => bytes.toJS;

Uint8List jsBytesFromUint8Array(Object jsUint8Array) {
  if (jsUint8Array is JSUint8Array) {
    return jsUint8Array.toDart;
  }
  // ArrayBuffer → Uint8Array view
  final ctor = jsGlobal('Uint8Array');
  if (ctor != null) {
    final view = js_util.callConstructor(ctor, [jsUint8Array]);
    return (view as JSUint8Array).toDart;
  }
  throw ArgumentError('Expected JSUint8Array or ArrayBuffer');
}

bool get jsInteropSupported => true;

F jsAllowInterop<F extends Function>(F f) => js_util.allowInterop(f);

/// Collects all values from a JS async iterator (`Object` façade for VM stubs).
Future<List<Object>> jsCollectAsyncIterator(Object iterator) async {
  final iter = iterator as JSAsyncIterator;
  final out = <Object>[];
  while (true) {
    final next = await iter.next().toDartAs<JSIteratorResult>();
    if (next.done) break;
    final value = next.value;
    if (value != null) out.add(value);
  }
  return out;
}
