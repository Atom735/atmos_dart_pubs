import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

/// Whether the `Worker` constructor is available.
bool get isWebWorkerSupported {
  if (!jsInteropSupported) return false;
  return globalHasProperty('Worker');
}
