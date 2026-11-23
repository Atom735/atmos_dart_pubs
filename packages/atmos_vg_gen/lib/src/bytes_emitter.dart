/// Formats [bytes] as a Dart `const` int list literal body.
///
/// Форматирует [bytes] как тело Dart `const`-списка int.
String formatByteList(List<int> bytes, {int perLine = 8}) {
  if (bytes.isEmpty) return '';
  final sb = StringBuffer();
  var offset = 0;
  for (var i = 0; i < bytes.length; i += perLine) {
    final end = i + perLine < bytes.length ? i + perLine : bytes.length;
    final chunk = bytes.sublist(i, end);
    offset += chunk.length;
    sb.write('    ');
    for (final b in chunk) {
      sb.write('0x${b.toRadixString(16).padLeft(2, '0')}, ');
    }
    sb.writeln('// $offset');
  }
  return sb.toString().trimRight();
}
