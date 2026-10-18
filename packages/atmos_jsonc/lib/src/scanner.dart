/// Low-level JSONC scanner over a [String].
///
/// ## ENG
/// Shared by the tree parser, visitor, and pull `JsoncReader`.
///
/// ## RU
/// Общий сканер для tree-парсера, visitor и pull-`JsoncReader`.
class JsoncScanner {
  /// Creates a scanner over [source].
  JsoncScanner(this.source) : _length = source.length;

  /// Input text.
  final String source;

  final int _length;

  /// Current read offset.
  int index = 0;

  /// Whether [index] is at or past the end.
  bool get atEnd => index >= _length;

  /// Code unit at [index] (caller must ensure not [atEnd]).
  int get ch => source.codeUnitAt(index);

  /// Skips whitespace and `//` / `/* */` comments.
  void skipNoise() {
    var i = index;
    final s = source;
    final len = _length;
    while (i < len) {
      final c = s.codeUnitAt(i);
      if (c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D) {
        i++;
        continue;
      }
      if (c == 0x2F /* / */ && i + 1 < len) {
        final n = s.codeUnitAt(i + 1);
        if (n == 0x2F /* / */) {
          i += 2;
          while (i < len) {
            final x = s.codeUnitAt(i);
            if (x == 0x0A || x == 0x0D) break;
            i++;
          }
          continue;
        }
        if (n == 0x2A /* * */) {
          i += 2;
          while (i + 1 < len) {
            if (s.codeUnitAt(i) == 0x2A && s.codeUnitAt(i + 1) == 0x2F) {
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
      throw FormatException('Unexpected trailing input', source, index);
    }
  }

  /// Parses a JSON string token (leading `"` must be current).
  String readString() {
    var i = index + 1; // after '"'
    final s = source;
    final len = _length;
    final start = i;
    while (i < len) {
      final c = s.codeUnitAt(i);
      if (c == 0x22 /* " */) {
        final value = s.substring(start, i);
        index = i + 1;
        return value;
      }
      if (c == 0x5C /* \ */) {
        index = i;
        return _readStringEscaped(start);
      }
      if (c < 0x20) {
        index = i;
        throw FormatException('Invalid control in string', source, i);
      }
      i++;
    }
    index = i;
    throw FormatException('Unterminated string', source, i);
  }

  String _readStringEscaped(int start) {
    final s = source;
    final len = _length;
    final buf = StringBuffer(s.substring(start, index));
    var i = index;
    while (i < len) {
      final c = s.codeUnitAt(i);
      if (c == 0x22 /* " */) {
        index = i + 1;
        return buf.toString();
      }
      if (c == 0x5C /* \ */) {
        i++;
        if (i >= len) {
          index = i;
          throw FormatException('Unterminated string escape', source, i);
        }
        final e = s.codeUnitAt(i);
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
            throw FormatException('Invalid escape', source, i - 1);
        }
        continue;
      }
      if (c < 0x20) {
        index = i;
        throw FormatException('Invalid control in string', source, i);
      }
      buf.writeCharCode(c);
      i++;
    }
    index = i;
    throw FormatException('Unterminated string', source, i);
  }

  int _readHex4() {
    final i = index;
    if (i + 4 > _length) {
      throw FormatException(r'Invalid \u escape', source, i);
    }
    final s = source;
    var value = 0;
    for (var k = 0; k < 4; k++) {
      final c = s.codeUnitAt(i + k);
      final n = _hexNibble(c);
      if (n < 0) {
        throw FormatException(r'Invalid \u escape', source, i + k);
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

  /// Parses `true` / `false` / `null` starting at [index].
  Object? readLiteral() {
    final s = source;
    final i = index;
    final c = s.codeUnitAt(i);
    if (c == 0x74 /* t */) {
      if (i + 3 < _length &&
          s.codeUnitAt(i + 1) == 0x72 &&
          s.codeUnitAt(i + 2) == 0x75 &&
          s.codeUnitAt(i + 3) == 0x65) {
        index = i + 4;
        return true;
      }
      throw FormatException('Expected true', source, i);
    }
    if (c == 0x66 /* f */) {
      if (i + 4 < _length &&
          s.codeUnitAt(i + 1) == 0x61 &&
          s.codeUnitAt(i + 2) == 0x6C &&
          s.codeUnitAt(i + 3) == 0x73 &&
          s.codeUnitAt(i + 4) == 0x65) {
        index = i + 5;
        return false;
      }
      throw FormatException('Expected false', source, i);
    }
    if (c == 0x6E /* n */) {
      if (i + 3 < _length &&
          s.codeUnitAt(i + 1) == 0x75 &&
          s.codeUnitAt(i + 2) == 0x6C &&
          s.codeUnitAt(i + 3) == 0x6C) {
        index = i + 4;
        return null;
      }
      throw FormatException('Expected null', source, i);
    }
    throw FormatException('Expected literal', source, i);
  }

  /// Parses a JSON number (fast path for plain integers without substring).
  num readNumber() {
    final s = source;
    final len = _length;
    var i = index;
    final start = i;
    var sign = 1;
    if (s.codeUnitAt(i) == 0x2D /* - */) {
      sign = -1;
      i++;
      if (i >= len) {
        throw FormatException('Invalid number', source, start);
      }
    }

    final first = s.codeUnitAt(i);
    if (first == 0x30 /* 0 */) {
      i++;
    } else if (first >= 0x31 && first <= 0x39) {
      i++;
      while (i < len) {
        final d = s.codeUnitAt(i);
        if (d < 0x30 || d > 0x39) break;
        i++;
      }
    } else {
      throw FormatException('Invalid number', source, start);
    }

    var isDouble = false;
    if (i < len && s.codeUnitAt(i) == 0x2E /* . */) {
      isDouble = true;
      i++;
      if (i >= len || s.codeUnitAt(i) < 0x30 || s.codeUnitAt(i) > 0x39) {
        index = i;
        throw FormatException('Invalid number fraction', source, i);
      }
      while (i < len) {
        final d = s.codeUnitAt(i);
        if (d < 0x30 || d > 0x39) break;
        i++;
      }
    }
    if (i < len) {
      final e = s.codeUnitAt(i);
      if (e == 0x65 /* e */ || e == 0x45 /* E */) {
        isDouble = true;
        i++;
        if (i < len) {
          final sgn = s.codeUnitAt(i);
          if (sgn == 0x2B || sgn == 0x2D) i++;
        }
        if (i >= len || s.codeUnitAt(i) < 0x30 || s.codeUnitAt(i) > 0x39) {
          index = i;
          throw FormatException('Invalid number exponent', source, i);
        }
        while (i < len) {
          final d = s.codeUnitAt(i);
          if (d < 0x30 || d > 0x39) break;
          i++;
        }
      }
    }

    if (isDouble) {
      final text = s.substring(start, i);
      index = i;
      return double.parse(text);
    }

    // Manual int parse — avoid substring allocation on the common path.
    // Dart integers are arbitrary-precision on the VM.
    var value = 0;
    var p = start;
    if (sign < 0) p++;
    while (p < i) {
      value = value * 10 + (s.codeUnitAt(p) - 0x30);
      p++;
    }
    index = i;
    return sign < 0 ? -value : value;
  }
}
