import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

import 'errors.dart';

/// Reads a JS `DOMStringList` (or array-like) into a Dart list.
List<String> readDomStringList(Object list) {
  final rawLength = jsGetProperty<Object?>(list, 'length');
  final length = rawLength is num ? rawLength.toInt() : 0;
  return <String>[
    for (var i = 0; i < length; i++) jsGetProperty<String>(list, i),
  ];
}

/// Reads a numeric JS property.
int readInt(Object object, String name) {
  final value = readIntOrNull(object, name);
  if (value == null) {
    throw IndexedDbException('Missing numeric property $name');
  }
  return value;
}

/// Reads a numeric JS property, or null when it is missing / null.
int? readIntOrNull(Object object, String name) {
  final value = jsGetProperty<Object?>(object, name);
  if (value == null) return null;
  if (value is num) return value.toInt();
  throw IndexedDbException('Property $name is not a number');
}
