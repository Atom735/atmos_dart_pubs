import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

/// Whether `window.queryLocalFonts` appears to be available.
///
/// Доступен ли `window.queryLocalFonts` в этом окружении.
bool get isLocalFontAccessApiSupported {
  if (!jsInteropSupported) return false;
  return globalHasProperty('queryLocalFonts');
}
