import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

import 'errors.dart';
import 'font_data.dart';
import 'js_error.dart';
import 'support.dart';

/// Options for `queryLocalFonts`.
///
/// Параметры `queryLocalFonts`.
class QueryLocalFontsOptions {
  /// Creates query options.
  ///
  /// Создаёт параметры запроса.
  const QueryLocalFontsOptions({this.postscriptNames});

  /// When set, only these PostScript names are returned.
  ///
  /// Если задано, вернутся только эти PostScript-имена.
  final List<String>? postscriptNames;

  /// Converts to a JS options object.
  ///
  /// Преобразует в JS-объект параметров.
  Object toJs() {
    final out = jsNewObject();
    final names = postscriptNames;
    if (names != null) {
      jsSetProperty(out, 'postscriptNames', jsArray(names));
    }
    return out;
  }
}

/// Enumerates installed fonts. May prompt for permission.
///
/// On the web this needs a secure context and a user gesture.
/// Chromium implements the API (Chrome, Edge).
///
/// Перечисляет установленные шрифты и может запросить разрешение.
/// В браузере нужны secure context и user gesture. API есть в Chromium.
Future<List<LocalFontData>> queryLocalFonts([
  QueryLocalFontsOptions? options,
]) async {
  if (!isLocalFontAccessApiSupported) {
    throw const LocalFontAccessException(
      'Local Font Access API is not available in this runtime',
    );
  }
  try {
    final args =
        options == null ? const <Object?>[] : <Object?>[options.toJs()];
    final result = jsCallMethod<Object>(
      jsGlobalThis,
      'queryLocalFonts',
      args,
    );
    final value = await jsMaybePromiseToFuture<Object>(result);
    return _fontDataList(value);
  } on LocalFontAccessException {
    rethrow;
  } on Object catch (error) {
    throw wrapLocalFontError(error, 'queryLocalFonts failed');
  }
}

List<LocalFontData> _fontDataList(Object value) {
  final length = jsGetProperty<Object?>(value, 'length');
  final len = length is num ? length.toInt() : 0;
  return <LocalFontData>[
    for (var i = 0; i < len; i++)
      LocalFontData(jsGetProperty<Object>(value, i)),
  ];
}
