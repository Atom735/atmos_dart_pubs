import 'dart:typed_data';

import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

import 'errors.dart';
import 'js_error.dart';

/// One local font face (`FontData`).
///
/// Одно начертание локального шрифта (`FontData`).
class LocalFontData {
  /// Wraps a JS `FontData` object.
  ///
  /// Оборачивает JS-объект `FontData`.
  LocalFontData(this.jsObject)
      : postscriptName = _fontString(jsObject, 'postscriptName'),
        fullName = _fontString(jsObject, 'fullName'),
        family = _fontString(jsObject, 'family'),
        style = _fontString(jsObject, 'style');

  /// Underlying JS `FontData`.
  ///
  /// Исходный JS-объект `FontData`.
  final Object jsObject;

  /// PostScript name (`FontData.postscriptName`).
  ///
  /// PostScript-имя.
  final String postscriptName;

  /// Full name (`FontData.fullName`), for example `Arial Bold`.
  ///
  /// Полное имя, например `Arial Bold`.
  final String fullName;

  /// CSS family (`FontData.family`).
  ///
  /// Семейство CSS.
  final String family;

  /// Face style (`FontData.style`), for example `Regular`.
  ///
  /// Стиль начертания, например `Regular` или `Bold Italic`.
  final String style;

  /// Reads the font file (`FontData.blob()`).
  ///
  /// The returned list owns a fresh `ArrayBuffer`. A `Uint8Array` view of
  /// the blob cannot be passed to `ByteData.sublistView` or `FontLoader`.
  ///
  /// Читает файл шрифта.
  /// Список владеет новым `ArrayBuffer`: view на blob нельзя отдать
  /// в `ByteData.sublistView` и `FontLoader`.
  Future<Uint8List> readBytes() async {
    try {
      final blob = await jsMaybePromiseToFuture<Object>(
        jsCallMethod<Object>(jsObject, 'blob'),
      );
      final buffer = await jsMaybePromiseToFuture<Object>(
        jsCallMethod<Object>(blob, 'arrayBuffer'),
      );
      final ctor = jsGlobal('Uint8Array');
      if (ctor == null) {
        throw const LocalFontAccessException('Uint8Array is not available');
      }
      final view = jsConstruct(ctor, <Object?>[buffer]);
      return Uint8List.fromList(jsBytesFromUint8Array(view));
    } on LocalFontAccessException {
      rethrow;
    } on Object catch (error) {
      throw wrapLocalFontError(
        error,
        'Failed to read font "$postscriptName"',
      );
    }
  }
}

String _fontString(Object object, String name) {
  final value = jsGetProperty<Object?>(object, name);
  if (value is String) return value;
  return '';
}
