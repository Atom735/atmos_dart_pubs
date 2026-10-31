import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

import 'errors.dart';

/// JS `error.name`, or null when [error] is not a JS object.
String? jsErrorName(Object error) {
  try {
    return jsGetProperty<String?>(error, 'name');
  } on Object {
    return null;
  }
}

/// Maps a JS failure to a [LocalFontAccessException].
LocalFontAccessException wrapLocalFontError(Object error, String message) {
  if (jsErrorName(error) == 'NotAllowedError') {
    return LocalFontAccessNotAllowedException(cause: error);
  }
  return LocalFontAccessException(message, cause: error);
}
