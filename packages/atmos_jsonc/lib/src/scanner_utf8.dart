import 'dart:convert';
import 'dart:typed_data';

/// Low-level JSONC scanner over UTF-8 [Uint8List] bytes.
///
/// ## ENG
/// Avoids allocating a full UTF-16 [String] for the document. String tokens
/// are decoded only for keys/values (ASCII fast path when possible).
///
/// ## RU
/// Без полной UTF-16-[String] на весь документ. Строки декодируются только
/// для ключей/значений (ASCII fast-path по возможности).
class JsoncUtf8Scanner {
  /// Creates a scanner over [bytes].
  JsoncUtf8Scanner(this.bytes) : _length = bytes.length;

  /// Input UTF-8 bytes.
  final Uint8List bytes;

  final int _length;

  /// Current read offset in bytes.
  int index = 0;

  /// Whether [index] is at or past the end.
  bool get atEnd => index >= _length;

  /// Byte at [index].
  int get ch => bytes[index];

  /// Skips whitespace and `//` / `/* */` comments.
  void skipNoise() {
    var i = index;
    final b = bytes;
    final len = _length;
    while (i < len) {
      final c = b[i];
      if (c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D) {
        i++;
        continue;
      }
      if (c == 0x2F /* / */ && i + 1 < len) {
        final n = b[i + 1];
        if (n == 0x2F /* / */) {
          i += 2;
          while (i < len) {
            final x = b[i];
            if (x == 0x0A || x == 0x0D) break;
            i++;
          }
          continue;
        }
        if (n == 0x2A /* * */) {
          i += 2;
          while (i + 1 < len) {
            if (b[i] == 0x2A && b[i + 1] == 0x2F) {
              i += 2;
              break;
            }
            i++;
          }
          continue;
        }
      }
      break;
    }
    index = i;
  }

  /// Expects EOF after optional noise.
  void expectEof() {
    skipNoise();
    if (!atEnd) {
      throw FormatException('Unexpected trailing input at byte $index');
    }
  }

  /// Parses a JSON string token (leading `"` must be current).
  String readString() {
    var i = index + 1; // after '"'
    final b = bytes;
    final len = _length;
    final start = i;
    var ascii = true;
    while (i < len) {
      final c = b[i];
      if (c == 0x22 /* " */) {
        index = i + 1;
        return _decodeSlice(start, i, ascii);
      }
      if (c == 0x5C /* \ */) {
        index = i;
        return _readStringEscaped(start, ascii);
      }
      if (c < 0x20) {
        index = i;
        throw FormatException('Invalid control in string at byte $i');
      }
      if (c >= 0x80) ascii = false;
      i++;
    }
    index = i;
    throw FormatException('Unterminated string at byte $i');
  }

  String _decodeSlice(int start, int end, bool ascii) {
    if (start == end) return '';
    if (ascii) {
      return String.fromCharCodes(bytes, start, end);
    }
    return utf8.decode(Uint8List.sublistView(bytes, start, end));
  }

  String _readStringEscaped(int start, bool asciiBefore) {
    final buf = StringBuffer();
    if (start < index) {
      buf.write(_decodeSlice(start, index, asciiBefore));
    }
    final b = bytes;
    final len = _length;
    var i = index;
    while (i < len) {
      final c = b[i];
      if (c == 0x22 /* " */) {
        index = i + 1;
        return buf.toString();
      }
      if (c == 0x5C /* \ */) {
        i++;
        if (i >= len) {
          index = i;
          throw FormatException('Unterminated string escape at byte $i');
        }
        final e = b[i];
        i++;
        switch (e) {
          case 0x22:
          case 0x5C:
          case 0x2F:
            buf.writeCharCode(e);
          case 0x62:
            buf.writeCharCode(0x08);
          case 0x66:
            buf.writeCharCode(0x0C);
          case 0x6E:
            buf.writeCharCode(0x0A);
          case 0x72:
            buf.writeCharCode(0x0D);
          case 0x74:
            buf.writeCharCode(0x09);
          case 0x75:
            index = i;
            buf.writeCharCode(_readHex4());
            i = index;
          default:
            index = i - 1;
            throw FormatException('Invalid escape at byte ${i - 1}');
        }
        continue;
      }
      if (c < 0x20) {
        index = i;
        throw FormatException('Invalid control in string at byte $i');
      }
      if (c < 0x80) {
        buf.writeCharCode(c);
        i++;
        continue;
      }
      // UTF-8 multi-byte sequence
      final seqStart = i;
      i = _skipUtf8Sequence(i);
      buf.write(
        utf8.decode(Uint8List.sublistView(bytes, seqStart, i)),
      );
    }
    index = i;
    throw FormatException('Unterminated string at byte $i');
  }

  int _skipUtf8Sequence(int i) {
    final b = bytes;
    final len = _length;
    final c = b[i];
    final need = c < 0xE0
        ? 2
        : c < 0xF0
            ? 3
            : 4;
    if (i + need > len) {
      throw FormatException('Invalid UTF-8 in string at byte $i');
    }
    return i + need;
  }

  int _readHex4() {
    final i = index;
    if (i + 4 > _length) {
      throw FormatException('Invalid \\u escape at byte $i');
    }
    final b = bytes;
    var value = 0;
    for (var k = 0; k < 4; k++) {
      final n = _hexNibble(b[i + k]);
      if (n < 0) {
        throw FormatException('Invalid \\u escape at byte ${i + k}');
      }
      value = (value << 4) | n;
    }
    index = i + 4;
    return value;
  }

  static int _hexNibble(int c) {
    if (c >= 0x30 && c <= 0x39) return c - 0x30;
    if (c >= 0x61 && c <= 0x66) return c - 0x61 + 10;
    if (c >= 0x41 && c <= 0x46) return c - 0x41 + 10;
    return -1;
  }

  /// Parses `true` / `false` / `null`.
  Object? readLiteral() {
    final b = bytes;
    final i = index;
    final c = b[i];
    if (c == 0x74 /* t */) {
      if (i + 3 < _length &&
          b[i + 1] == 0x72 &&
          b[i + 2] == 0x75 &&
          b[i + 3] == 0x65) {
        index = i + 4;
        return true;
      }
      throw FormatException('Expected true at byte $i');
    }
    if (c == 0x66 /* f */) {
      if (i + 4 < _length &&
          b[i + 1] == 0x61 &&
          b[i + 2] == 0x6C &&
          b[i + 3] == 0x73 &&
          b[i + 4] == 0x65) {
        index = i + 5;
        return false;
      }
      throw FormatException('Expected false at byte $i');
    }
    if (c == 0x6E /* n */) {
      if (i + 3 < _length &&
          b[i + 1] == 0x75 &&
          b[i + 2] == 0x6C &&
          b[i + 3] == 0x6C) {
        index = i + 4;
        return null;
      }
      throw FormatException('Expected null at byte $i');
    }
    throw FormatException('Expected literal at byte $i');
  }

  /// Parses a JSON number.
  num readNumber() {
    final b = bytes;
    final len = _length;
    var i = index;
    final start = i;
    var sign = 1;
    if (b[i] == 0x2D /* - */) {
      sign = -1;
      i++;
      if (i >= len) {
        throw FormatException('Invalid number at byte $start');
      }
    }

    final first = b[i];
    if (first == 0x30 /* 0 */) {
      i++;
    } else if (first >= 0x31 && first <= 0x39) {
      i++;
      while (i < len) {
        final d = b[i];
        if (d < 0x30 || d > 0x39) break;
        i++;
      }
    } else {
      throw FormatException('Invalid number at byte $start');
    }

    var isDouble = false;
    if (i < len && b[i] == 0x2E /* . */) {
      isDouble = true;
      i++;
      if (i >= len || b[i] < 0x30 || b[i] > 0x39) {
        index = i;
        throw FormatException('Invalid number fraction at byte $i');
      }
      while (i < len) {
        final d = b[i];
        if (d < 0x30 || d > 0x39) break;
        i++;
      }
    }
    if (i < len) {
      final e = b[i];
      if (e == 0x65 /* e */ || e == 0x45 /* E */) {
        isDouble = true;
        i++;
        if (i < len) {
          final sgn = b[i];
          if (sgn == 0x2B || sgn == 0x2D) i++;
        }
        if (i >= len || b[i] < 0x30 || b[i] > 0x39) {
          index = i;
          throw FormatException('Invalid number exponent at byte $i');
        }
        while (i < len) {
          final d = b[i];
          if (d < 0x30 || d > 0x39) break;
          i++;
        }
      }
    }

    if (isDouble) {
      final text = String.fromCharCodes(bytes, start, i);
      index = i;
      return double.parse(text);
    }

    var value = 0;
    var p = start;
    if (sign < 0) p++;
    while (p < i) {
      value = value * 10 + (b[p] - 0x30);
      p++;
    }
    index = i;
    return sign < 0 ? -value : value;
  }
}
