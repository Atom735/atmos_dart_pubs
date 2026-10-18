// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js_interop';
import 'dart:js_util' as js_util;

/// Расширение для работы с JS-объектами как с обычными Map.
extension JSObjectExtensions on JSObject {
  /// Позволяет писать: `jsObj['key'] = value`.
  void operator []=(String key, JSAny? value) {
    js_util.setProperty(this, key, value);
  }

  /// Позволяет писать: `JSAny? val = jsObj['key']`.
  ///
  /// Missing properties are `null` (typed as [JSAny?], not non-nullable Object).
  JSAny? operator [](String key) {
    return js_util.getProperty<JSAny?>(this, key);
  }
}

/// Расширение для удобной работы с JS-массивами.
extension JSArrayExtensions on JSArray {
  /// Длина массива (JS `array.length`).
  int get length {
    final raw = js_util.getProperty<Object?>(this, 'length');
    return raw is num ? raw.toInt() : 0;
  }

  /// Добавление элемента в конец массива (JS `array.push`).
  void push(JSAny? value) {
    js_util.callMethod(this, 'push', [value]);
  }

  /// Получение элемента по индексу (JS `array[index]`).
  JSAny? at(int index) {
    return js_util.getProperty<JSAny?>(this, index);
  }

  /// Запись элемента по индексу.
  void setAt(int index, JSAny? value) {
    js_util.setProperty(this, index, value);
  }
}

/// Результат `iterator.next()` / `reader.read()`.
@JS()
@anonymous
@staticInterop
class JSIteratorResult {}

/// Members of [JSIteratorResult].
extension JSIteratorResultExtension on JSIteratorResult {
  external bool get done;
  external JSAny? get value;
}

/// Асинхронный JS-итератор (`for await...of`).
@JS()
@staticInterop
class JSAsyncIterator {}

/// Members of [JSAsyncIterator].
extension JSAsyncIteratorExtension on JSAsyncIterator {
  external JSPromise next();
}

/// [ReadableStream](https://developer.mozilla.org/docs/Web/API/ReadableStream).
@JS()
@staticInterop
class JSReadableStream {}

/// Members of [JSReadableStream].
extension JSReadableStreamExtension on JSReadableStream {
  external JSReadableStreamReader getReader();
}

/// [ReadableStreamDefaultReader](https://developer.mozilla.org/docs/Web/API/ReadableStreamDefaultReader).
@JS()
@staticInterop
class JSReadableStreamReader {}

/// Members of [JSReadableStreamReader].
extension JSReadableStreamReaderExtension on JSReadableStreamReader {
  external JSPromise read();
  external void releaseLock();
}

/// Helpers for [JSPromise].
extension JSPromiseToFutureExtension on JSPromise {
  /// `toDart` + cast: `await promise.toDartAs<Foo?>()`.
  Future<T> toDartAs<T>() => toDart.then((value) => value as T);
}

/// Есть ли свойство у `globalThis` / `window`.
bool globalHasProperty(String name) =>
    js_util.hasProperty(js_util.globalThis, name);

/// Глобальный JS-контекст как [JSObject].
JSObject get jsGlobalThis => js_util.globalThis as JSObject;
