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
      : postscriptName = jsGetProperty<String>(jsObject, 'postscriptName'),
        fullName = jsGetProperty<String>(jsObject, 'fullName'),
        family = jsGetProperty<String>(jsObject, 'family'),
        style = jsGetProperty<String>(jsObject, 'style');

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
  /// Читает файл шрифта.
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
      return jsBytesFromUint8Array(view);
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
