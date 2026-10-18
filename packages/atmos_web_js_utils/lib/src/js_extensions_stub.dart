/// Stub: JS interop extensions are unavailable on non-web targets.

/// Whether `globalThis` has [name]. Always `false` on non-web.
bool globalHasProperty(String name) => false;

/// Global JS object. Throws on non-web.
Object get jsGlobalThis =>
    throw UnsupportedError('atmos_web_js_utils requires a browser JS runtime');
