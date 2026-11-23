import 'dart:typed_data';

/// One entry in the `sfnt` table directory (tag + payload bytes).
///
/// Одна запись каталога таблиц `sfnt` (тег + байты полезной нагрузки).
class TtfTableRecord {
  /// Creates a table record.
  ///
  /// Создаёт запись таблицы.
  TtfTableRecord({
    required this.tag,
    required this.bytes,
  }) : assert(tag.length == 4, 'Table tag must be 4 characters');

  /// Four-character table tag, for example `head` or `glyf`.
  ///
  /// Четырёхсимвольный тег таблицы, например `head` или `glyf`.
  final String tag;

  /// Table payload without trailing padding zeros.
  ///
  /// Полезная нагрузка таблицы без хвостовых нулей выравнивания.
  final Uint8List bytes;

  /// Padded length on a 4-byte boundary.
  ///
  /// Длина с выравниванием по границе 4 байт.
  int get paddedLength => (bytes.length + 3) & ~3;
}
