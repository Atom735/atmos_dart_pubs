import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

/// Options for constructing a `WebWorker` (`WorkerOptions`).
class WebWorkerOptions {
  /// Creates worker options.
  const WebWorkerOptions({
    this.type = 'classic',
    this.credentials = 'same-origin',
    this.name,
  });

  /// `'classic'` or `'module'`.
  final String type;

  /// `'omit'`, `'same-origin'`, or `'include'`.
  final String credentials;

  /// Optional debug name for DevTools.
  final String? name;

  /// Converts to a plain JS object.
  Object toJs() {
    final out = jsNewObject();
    jsSetProperty(out, 'type', type);
    jsSetProperty(out, 'credentials', credentials);
    if (name != null) jsSetProperty(out, 'name', name);
    return out;
  }
}
