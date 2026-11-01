import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

import 'errors.dart';
import 'support.dart';
import 'values.dart';

/// Range of IndexedDB keys (`IDBKeyRange`).
class IdbKeyRange {
  /// Wraps a JS `IDBKeyRange`.
  IdbKeyRange(this.jsObject);

  /// Underlying JS range.
  final Object jsObject;

  /// Single-key range (`IDBKeyRange.only`).
  IdbKeyRange.only(Object key) : jsObject = _call('only', <Object?>[toJs(key)]);

  /// Inclusive or exclusive bounds (`IDBKeyRange.bound`).
  IdbKeyRange.bound(
    Object lower,
    Object upper, {
    bool lowerOpen = false,
    bool upperOpen = false,
  }) : jsObject = _call('bound', <Object?>[
          toJs(lower),
          toJs(upper),
          lowerOpen,
          upperOpen,
        ]);

  /// Keys `>=` [lower], or `>` when [open] (`IDBKeyRange.lowerBound`).
  IdbKeyRange.lowerBound(Object lower, {bool open = false})
      : jsObject = _call('lowerBound', <Object?>[toJs(lower), open]);

  /// Keys `<=` [upper], or `<` when [open] (`IDBKeyRange.upperBound`).
  IdbKeyRange.upperBound(Object upper, {bool open = false})
      : jsObject = _call('upperBound', <Object?>[toJs(upper), open]);

  /// Lower bound, or null when the range is unbounded below.
  Object? get lower => fromJs(jsGetProperty<Object?>(jsObject, 'lower'));

  /// Upper bound, or null when the range is unbounded above.
  Object? get upper => fromJs(jsGetProperty<Object?>(jsObject, 'upper'));

  /// Whether the lower bound is exclusive.
  bool get lowerOpen => jsGetProperty<bool>(jsObject, 'lowerOpen');

  /// Whether the upper bound is exclusive.
  bool get upperOpen => jsGetProperty<bool>(jsObject, 'upperOpen');

  /// Whether [key] lies in this range.
  bool includes(Object key) {
    return jsCallMethod<bool>(jsObject, 'includes', <Object?>[toJs(key)]);
  }

  static Object _call(String method, List<Object?> args) {
    if (!isIndexedDbSupported) {
      throw const IndexedDbUnsupportedException();
    }
    final ctor = jsGlobal('IDBKeyRange');
    if (ctor == null) throw const IndexedDbUnsupportedException();
    return jsCallMethod<Object>(ctor, method, args);
  }
}
