import 'dart:typed_data';

/// OpenType table checksum over [data] (zero-padded to a multiple of 4).
///
/// Checksum таблицы OpenType по [data] (дополнение нулями до кратности 4).
int ttfTableChecksum(Uint8List data) {
  final paddedLength = (data.length + 3) & ~3;
  final padded = data.length == paddedLength
      ? data
      : (Uint8List(paddedLength)..setRange(0, data.length, data));
  final view = ByteData.sublistView(padded);
  var sum = 0;
  for (var i = 0; i < paddedLength; i += 4) {
    sum = (sum + view.getUint32(i, Endian.big)) & 0xFFFFFFFF;
  }
  return sum;
}

/// Entire-font checksum used to derive `head.checksumAdjustment`.
///
/// Checksum всего шрифта для вычисления `head.checksumAdjustment`.
int ttfFontChecksum(Uint8List fontBytes) {
  return ttfTableChecksum(fontBytes);
}

/// Magic subtracted from the whole-font checksum for `head`.
///
/// Константа, из которой вычитают checksum шрифта для `head`.
const int kHeadChecksumMagic = 0xB1B0AFBA;
