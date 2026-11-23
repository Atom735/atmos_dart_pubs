/// Converts an icon id (`git-pull-request`, `arrow_left`) to a lowerCamel
/// Dart identifier.
///
/// Преобразует id иконки (`git-pull-request`, `arrow_left`) в lowerCamel
/// Dart-идентификатор.
String iconIdToDartName(String id) {
  final parts = id
      .split(RegExp(r'[^A-Za-z0-9]+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    throw ArgumentError.value(id, 'id', 'Cannot derive a Dart name');
  }
  final buffer = StringBuffer(parts.first.toLowerCase());
  for (var i = 1; i < parts.length; i++) {
    final p = parts[i];
    buffer
      ..write(p[0].toUpperCase())
      ..write(p.substring(1).toLowerCase());
  }
  var name = buffer.toString();
  if (RegExp(r'^[0-9]').hasMatch(name)) {
    name = 'n$name';
  }
  return name;
}

/// Hex code point for docs, for example `U+E001`.
///
/// Hex кодпоинта для документации, например `U+E001`.
String formatCodePoint(int codePoint) {
  final hex = codePoint.toRadixString(16).toUpperCase().padLeft(4, '0');
  return 'U+$hex';
}
