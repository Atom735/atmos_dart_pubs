import 'dart:typed_data';

import 'js_utils_stub.dart'
    if (dart.library.js_interop) 'js_utils_web.dart' as impl;

export 'js_extensions_stub.dart'
    if (dart.library.js_interop) 'js_extensions.dart';

/// Converts a JS `Promise` to a Dart [Future].
Future<T> jsPromiseToFuture<T>(Object promise) =>
    impl.jsPromiseToFuture<T>(promise);

/// Returns `true` if [value] is a JS `Promise` (has a `then` function).
bool jsIsPromise(Object? value) => impl.jsIsPromise(value);

/// Awaits [value] if it is a Promise; otherwise returns it as [T].
Future<T> jsMaybePromiseToFuture<T>(Object? value) =>
    impl.jsMaybePromiseToFuture<T>(value);

/// Reads a property [name] (string or index) from [object].
T jsGetProperty<T>(Object object, Object name) =>
    impl.jsGetProperty<T>(object, name);

/// Writes [value] to property [name] on [object].
void jsSetProperty(Object object, Object name, Object? value) =>
    impl.jsSetProperty(object, name, value);

/// Whether [object] has a property [name].
bool jsHasProperty(Object object, Object name) =>
    impl.jsHasProperty(object, name);

/// Calls method [method] on [object] with [args].
T jsCallMethod<T>(Object object, String method, [List<Object?>? args]) =>
    impl.jsCallMethod<T>(object, method, args);

/// Looks up a global JS value by dotted [path].
///
/// Example path: `showOpenFilePicker` (relative to `globalThis`).
Object? jsGlobal(String path) => impl.jsGlobal(path);

/// Creates a new empty JS object (`{}`).
Object jsNewObject() => impl.jsNewObject();

/// Constructs a JS object with [constructor] and [args] (`new C(...args)`).
Object jsConstruct(Object constructor, [List<Object?>? args]) =>
    impl.jsConstruct(constructor, args);

/// Deep-converts a Dart value to JS (`List`→Array, `Map`→object, …).
Object? jsify(Object? value) => impl.jsify(value);

/// Creates a JS `Array` from [items] (does not re-wrap existing JS values).
Object jsArray(Iterable<Object?> items) => impl.jsArray(items);

/// Copies [bytes] into a JS `Uint8Array` (by reference on JS backends).
Object jsUint8ArrayFromBytes(Uint8List bytes) =>
    impl.jsUint8ArrayFromBytes(bytes);

/// Copies a JS `Uint8Array` / `ArrayBuffer` view into a Dart [Uint8List].
Uint8List jsBytesFromUint8Array(Object jsUint8Array) =>
    impl.jsBytesFromUint8Array(jsUint8Array);

/// Whether the current platform exposes browser JS interop.
bool get jsInteropSupported => impl.jsInteropSupported;

/// Collects all values from a JS async iterator (`next()` loop).
Future<List<Object>> jsCollectAsyncIterator(Object iterator) =>
    impl.jsCollectAsyncIterator(iterator);

/// Wraps a Dart function so it can be passed to JS as a callback.
F jsAllowInterop<F extends Function>(F f) => impl.jsAllowInterop(f);
