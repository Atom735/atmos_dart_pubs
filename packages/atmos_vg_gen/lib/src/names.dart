/// Converts a raw asset / file stem into a valid lowerCamel Dart identifier.
///
/// Превращает имя файла / ассета в валидный lowerCamel Dart-идентификатор.
String toDartIdentifier(String raw) {
  final cleaned = raw
      .replaceAll(RegExp(r'[^A-Za-z0-9_]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  if (cleaned.isEmpty) {
    throw ArgumentError('Cannot derive Dart identifier from "$raw"');
  }
  final parts = cleaned.split('_').where((p) => p.isNotEmpty).toList();
  final buf = StringBuffer(parts.first.toLowerCase());
  for (var i = 1; i < parts.length; i++) {
    final p = parts[i];
    buf.write(p[0].toUpperCase());
    if (p.length > 1) buf.write(p.substring(1).toLowerCase());
  }
  var id = buf.toString();
  if (RegExp(r'^[0-9]').hasMatch(id)) {
    id = 'n$id';
  }
  return id;
}

/// Prefixes [id] so it is safe as a private Dart type name (`_$id`).
///
/// Добавляет префикс, чтобы [id] был безопасным private-именем типа.
String toPrivateClassName(String id) => '_$id';
