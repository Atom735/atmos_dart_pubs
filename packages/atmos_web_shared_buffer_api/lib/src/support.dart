import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

/// Whether `SharedArrayBuffer` is present on `globalThis`.
///
/// Availability alone is not enough: the page must also be cross-origin
/// isolated (COOP + COEP, and usually CORP on subresources). See package README.
bool get isSharedArrayBufferSupported {
  if (!jsInteropSupported) return false;
  return globalHasProperty('SharedArrayBuffer');
}

/// Whether `Atomics` is present on `globalThis`.
bool get isAtomicsSupported {
  if (!jsInteropSupported) return false;
  return globalHasProperty('Atomics');
}

/// Whether both SAB and Atomics look available on `globalThis`.
///
/// Prefer combining with [isCrossOriginIsolated] before allocating a buffer.
bool get isSharedMemorySupported =>
    isSharedArrayBufferSupported && isAtomicsSupported;

/// Browser `crossOriginIsolated` (required for SAB in modern Chrome).
///
/// Becomes `true` when the document is served with COOP/COEP (and related CORP).
/// For local `flutter run` without server headers, a **dev-only** Service Worker
/// can inject those headers — see the package README (“JS header hack”).
bool get isCrossOriginIsolated {
  if (!jsInteropSupported) return false;
  return jsGlobal('crossOriginIsolated') == true;
}
