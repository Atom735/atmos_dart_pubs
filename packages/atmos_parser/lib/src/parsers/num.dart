part of '../__all.dart';

class AtmosParserNumEmptyAsNull extends AtmosParserNum {
  const AtmosParserNumEmptyAsNull([super.radix]);

  @override
  num? parse(Object? input) {
    if (input is num?) {
      return input;
    } else if (input is String) {
      if (input.isEmpty) {
        return null;
      }
    }
    return super.parse(input);
  }
}

/// Parser ожидаемых [num] (Численных) данных.
///
/// {@category Core}
/// {@category Parser}
class AtmosParserNum extends AtmosParser<num> {
  const AtmosParserNum([this.radix]) : super(name: 'num');

  final int? radix;

  @override
  num? parse(Object? input) {
    if (input is num?) {
      return input;
    } else if (input is String) {
      if (input.isEmpty) {
        errorUnparsed();
        return null;
      } else
      // Если ожидали целое число а получили строку.
      if (input.startsWith('+')) {
        // Плюсы в начале строки - отбрасываем.
        return parse(input.substring(1));
      } else if (input.startsWith('-')) {
        // Минус в начале строки - отбрасываем и возвращаем
        // противоположный результат.
        final a = parse(input.substring(1));
        if (a != null) return -a;
        return a;
      } else if (input.startsWith('0x') &&
          input.substring(2).toUpperCase().isRadixNum(16)) {
        // Обычное шестнадцатеричное число записанное в си нотации.
        return int.parse(input.substring(2), radix: 16);
      } else if (input.startsWith('#') &&
          input.substring(1).toUpperCase().isRadixNum(16)) {
        // CSS значение цвета.
        final i = int.parse(input.substring(1), radix: 16);
        int hex1(int i, int where, int shift) {
          return (((i >> (where * 4)) & 0xf) * 0x11) << (shift * 8);
        }

        switch (input.length) {
          // #RGB -> 0x00RRGGBB
          case 4:
            return hex1(i, 2, 2) | hex1(i, 1, 1) | hex1(i, 0, 0);
          // #RGBA -> 0xAARRGGBB
          case 5:
            return hex1(i, 3, 2) |
                hex1(i, 2, 1) |
                hex1(i, 1, 0) |
                hex1(i, 0, 4);
          // #RRGGBB -> 0x00RRGGBB
          case 7:
            return i;
          // #RRGGBBAA -> 0xAARRGGBB
          case 8:
            return ((i >> 8) & 0x00FFFFFF) | ((i & 0xFF) << 24);
          default:
        }
      } else if (radix != null && input.toUpperCase().isRadixNum(radix!)) {
        return int.parse(input, radix: radix);
      } else {
        final out = num.tryParse(input);
        if (out == null) {
          errorUnparsed();
        }
        return out;
      }
    }
    errorUnparsed();
    return null;
  }

  @override
  Object? serialize(num? input) {
    return input;
  }
}

extension AtmosParserStringExtension on String {
  /// Является ли символ цифрой.
  static bool checkDigitUnit(int code) {
    final bits = code ^ 0x30;
    return bits >= 0 && bits < 10;
  }

  /// Является ли строка цифровой.
  bool get isDigits => codeUnits.every(checkDigitUnit);

  /// Является ли строка числом в заданной системе счисления.
  bool isRadixNum(int radix) {
    final rr = radix - 10;
    for (final code in codeUnits) {
      if (checkDigitUnit(code)) return true;
      final bits = code ^ 0x40;
      return bits > 0 && bits <= rr;
    }
    return true;
  }
}
