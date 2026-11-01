import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

/// Whether `globalThis.indexedDB` is present.
bool get isIndexedDbSupported {
  if (!jsInteropSupported) return false;
  return jsGlobal('indexedDB') != null;
}
