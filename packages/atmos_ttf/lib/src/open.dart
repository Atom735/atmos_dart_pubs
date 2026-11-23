import 'dart:typed_data';

import 'errors.dart';
import 'font.dart';

/// TrueType `sfnt` version `0x00010000`.
///
/// Версия TrueType `sfnt` `0x00010000`.
const int kSfntTrueType = 0x00010000;

/// OpenType with CFF outlines (`OTTO`).
///
/// OpenType с контурами CFF (`OTTO`).
const int kSfntOtto = 0x4F54544F;

/// `true` legacy TrueType magic.
///
/// Устаревшая магия TrueType `true`.
const int kSfntTrue = 0x74727565;

/// Returns whether [bytes] look like an `sfnt` font.
///
/// Возвращает, похожи ли [bytes] на шрифт `sfnt`.
bool isTtf(Uint8List bytes) {
  if (bytes.length < 12) return false;
  final version = ByteData.sublistView(bytes).getUint32(0, Endian.big);
  return version == kSfntTrueType ||
      version == kSfntOtto ||
      version == kSfntTrue;
}

/// Parses [bytes] as a TrueType / OpenType font.
///
/// The font keeps its own copy of the input.
///
/// Разбирает [bytes] как шрифт TrueType / OpenType.
/// Шрифт хранит собственную копию входа.
TtfFont openTtf(Uint8List bytes) {
  if (!isTtf(bytes)) {
    throw TtfFormatException('Not an sfnt TrueType / OpenType font.');
  }
  return TtfFont.parse(bytes);
}
