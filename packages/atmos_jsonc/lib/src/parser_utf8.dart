import 'dart:typed_data';

import 'path.dart';
import 'scanner_utf8.dart';

/// Single-pass JSONC parser over UTF-8 bytes.
///
/// ## ENG
/// Same semantics as `JsoncParser`, but scans [Uint8List] without building a
/// full document [String].
///
/// ## RU
/// Та же семантика, что у `JsoncParser`, но по [Uint8List] без полной
/// [String] на документ.
class JsoncUtf8Parser {
  /// Creates a parser over UTF-8 [bytes].
  JsoncUtf8Parser(Uint8List bytes, {this.reviver})
      : _scanner = JsoncUtf8Scanner(bytes);

  /// Optional path-aware reviver.
  final JsoncReviver? reviver;

  final JsoncUtf8Scanner _scanner;
  final JsoncPath _path = JsoncPath();

  /// Parses one JSON value and requires EOF afterwards.
  Object? parse() {
    _scanner.index = 0;
    _path.length = 0;
    final value = _parseValue();
    _scanner.expectEof();
    return value;
  }

  Object? _finish(Object? value) {
    final r = reviver;
    return r == null ? value : r(_path, value);
  }

  Object? _parseValue() {
    _scanner.skipNoise();
    if (_scanner.atEnd) {
      throw FormatException(
        'Unexpected end of input at byte ${_scanner.index}',
      );
    }
    final c = _scanner.ch;
    if (c == 0x7B /* { */) return _finish(_parseObject());
    if (c == 0x5B /* [ */) return _finish(_parseArray());
    if (c == 0x22 /* " */) return _finish(_scanner.readString());
    if (c == 0x74 /* t */ || c == 0x66 /* f */ || c == 0x6E /* n */) {
      return _finish(_scanner.readLiteral());
    }
    if (c == 0x2D /* - */ || (c >= 0x30 && c <= 0x39)) {
      return _finish(_scanner.readNumber());
    }
    throw FormatException(
      'Unexpected character at byte ${_scanner.index}',
    );
  }

  Map<String, Object?> _parseObject() {
    _scanner.index++; // '{'
    final map = <String, Object?>{};
    _scanner.skipNoise();
    if (!_scanner.atEnd && _scanner.ch == 0x7D /* } */) {
      _scanner.index++;
      return map;
    }
    while (true) {
      _scanner.skipNoise();
      if (_scanner.atEnd || _scanner.ch != 0x22 /* " */) {
        throw FormatException(
          'Expected object key string at byte ${_scanner.index}',
        );
      }
      final key = _scanner.readString();
      _scanner.skipNoise();
      if (_scanner.atEnd || _scanner.ch != 0x3A /* : */) {
        throw FormatException(
          'Expected ":" after object key at byte ${_scanner.index}',
        );
      }
      _scanner.index++;
      if (reviver != null) {
        _path.push(key);
        map[key] = _parseValue();
        _path.pop();
      } else {
        map[key] = _parseValue();
      }
      _scanner.skipNoise();
      if (_scanner.atEnd) {
        throw FormatException(
          'Unterminated object at byte ${_scanner.index}',
        );
      }
      if (_scanner.ch == 0x2C /* , */) {
        _scanner.index++;
        _scanner.skipNoise();
        if (!_scanner.atEnd && _scanner.ch == 0x7D /* } */) {
          _scanner.index++;
          return map;
        }
        continue;
      }
      if (_scanner.ch == 0x7D /* } */) {
        _scanner.index++;
        return map;
      }
      throw FormatException(
        'Expected "," or "}" in object at byte ${_scanner.index}',
      );
    }
  }

  List<Object?> _parseArray() {
    _scanner.index++; // '['
    final list = <Object?>[];
    _scanner.skipNoise();
    if (!_scanner.atEnd && _scanner.ch == 0x5D /* ] */) {
      _scanner.index++;
      return list;
    }
    var i = 0;
    while (true) {
      if (reviver != null) {
        _path.push(i);
        list.add(_parseValue());
        _path.pop();
      } else {
        list.add(_parseValue());
      }
      i++;
      _scanner.skipNoise();
      if (_scanner.atEnd) {
        throw FormatException(
          'Unterminated array at byte ${_scanner.index}',
        );
      }
      if (_scanner.ch == 0x2C /* , */) {
        _scanner.index++;
        _scanner.skipNoise();
        if (!_scanner.atEnd && _scanner.ch == 0x5D /* ] */) {
          _scanner.index++;
          return list;
        }
        continue;
      }
      if (_scanner.ch == 0x5D /* ] */) {
        _scanner.index++;
        return list;
      }
      throw FormatException(
        'Expected "," or "]" in array at byte ${_scanner.index}',
      );
    }
  }
}
