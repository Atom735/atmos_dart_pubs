import 'dart:typed_data';

Never _unsupported() =>
    throw UnsupportedError('atmos_web_js_utils requires a browser JS runtime');

Future<T> jsPromiseToFuture<T>(Object promise) => _unsupported();

bool jsIsPromise(Object? value) => _unsupported();

Future<T> jsMaybePromiseToFuture<T>(Object? value) => _unsupported();

T jsGetProperty<T>(Object object, Object name) => _unsupported();

void jsSetProperty(Object object, Object name, Object? value) => _unsupported();

bool jsHasProperty(Object object, Object name) => _unsupported();

T jsCallMethod<T>(Object object, String method, [List<Object?>? args]) =>
    _unsupported();

Object? jsGlobal(String path) => _unsupported();

Object jsNewObject() => _unsupported();

Object jsConstruct(Object constructor, [List<Object?>? args]) =>
    _unsupported();

Object? jsify(Object? value) => _unsupported();

Object jsArray(Iterable<Object?> items) => _unsupported();

Object jsUint8ArrayFromBytes(Uint8List bytes) => _unsupported();

Uint8List jsBytesFromUint8Array(Object jsUint8Array) => _unsupported();

bool get jsInteropSupported => false;

Future<List<Object>> jsCollectAsyncIterator(Object iterator) => _unsupported();

F jsAllowInterop<F extends Function>(F f) => _unsupported();
