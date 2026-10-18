import 'path.dart';
import 'scanner.dart';

/// SAX-style callbacks while walking a JSONC document.
///
/// ## ENG
/// `path` is a live view — copy with `JsoncPath.toList` if you need to keep it.
/// Scalar methods receive the value; containers use begin/end only (no Map).
///
/// ## RU
/// `path` — живое представление; копируйте через `JsoncPath.toList`.
/// Скаляры приходят значениями; контейнеры — только begin/end (без Map).
abstract class JsoncVisitor {
  /// Called before the first property of an object (`path` = object location).
  void beginObject(JsoncPath path) {}

  /// Called after the last property of an object.
  void endObject(JsoncPath path) {}

  /// Called before the first element of an array.
  void beginArray(JsoncPath path) {}

  /// Called after the last element of an array.
  void endArray(JsoncPath path) {}

  /// Called after reading a property key; [path] already includes [key].
  void propertyKey(JsoncPath path, String key) {}

  /// String scalar at [path].
  void stringValue(JsoncPath path, String value) {}

  /// Number scalar at [path].
  void numberValue(JsoncPath path, num value) {}

  /// Boolean scalar at [path].
  void boolValue(JsoncPath path, bool value) {}

  /// `null` scalar at [path].
  void nullValue(JsoncPath path) {}
}

/// Walks [source] and invokes [visitor] with a maintained path stack.
void jsoncVisit(String source, JsoncVisitor visitor) {
  JsoncEventParser(source, visitor).parse();
}

/// Event parser driving a [JsoncVisitor].
class JsoncEventParser {
  /// Creates an event parser.
  JsoncEventParser(String source, this.visitor)
      : _scanner = JsoncScanner(source);

  /// Visitor receiving events.
  final JsoncVisitor visitor;

  final JsoncScanner _scanner;
  final JsoncPath _path = JsoncPath();

  /// Parses one document value then expects EOF.
  void parse() {
    _path.length = 0;
    _parseValue();
    _scanner.expectEof();
  }

  void _parseValue() {
    _scanner.skipNoise();
    if (_scanner.atEnd) {
      throw FormatException(
        'Unexpected end of input',
        _scanner.source,
        _scanner.index,
      );
    }
    final c = _scanner.ch;
    if (c == 0x7B /* { */) {
      _parseObject();
      return;
    }
    if (c == 0x5B /* [ */) {
      _parseArray();
      return;
    }
    if (c == 0x22 /* " */) {
      visitor.stringValue(_path, _scanner.readString());
      return;
    }
    if (c == 0x74 /* t */ || c == 0x66 /* f */) {
      final lit = _scanner.readLiteral();
      if (lit is! bool) {
        throw FormatException(
          'Expected bool',
          _scanner.source,
          _scanner.index,
        );
      }
      visitor.boolValue(_path, lit);
      return;
    }
    if (c == 0x6E /* n */) {
      _scanner.readLiteral();
      visitor.nullValue(_path);
      return;
    }
    if (c == 0x2D /* - */ || (c >= 0x30 && c <= 0x39)) {
      visitor.numberValue(_path, _scanner.readNumber());
      return;
    }
    throw FormatException(
      'Unexpected character',
      _scanner.source,
      _scanner.index,
    );
  }

  void _parseObject() {
    _scanner.index++; // '{'
    visitor.beginObject(_path);
    _scanner.skipNoise();
    if (!_scanner.atEnd && _scanner.ch == 0x7D /* } */) {
      _scanner.index++;
      visitor.endObject(_path);
      return;
    }
    while (true) {
      _scanner.skipNoise();
      if (_scanner.atEnd || _scanner.ch != 0x22 /* " */) {
        throw FormatException(
          'Expected object key string',
          _scanner.source,
          _scanner.index,
        );
      }
      final key = _scanner.readString();
      _path.push(key);
      visitor.propertyKey(_path, key);
      _scanner.skipNoise();
      if (_scanner.atEnd || _scanner.ch != 0x3A /* : */) {
        throw FormatException(
          'Expected ":" after object key',
          _scanner.source,
          _scanner.index,
        );
      }
      _scanner.index++;
      _parseValue();
      _path.pop();
      _scanner.skipNoise();
      if (_scanner.atEnd) {
        throw FormatException(
          'Unterminated object',
          _scanner.source,
          _scanner.index,
        );
      }
      if (_scanner.ch == 0x2C /* , */) {
        _scanner.index++;
        _scanner.skipNoise();
        if (!_scanner.atEnd && _scanner.ch == 0x7D /* } */) {
          _scanner.index++;
          visitor.endObject(_path);
          return;
        }
        continue;
      }
      if (_scanner.ch == 0x7D /* } */) {
        _scanner.index++;
        visitor.endObject(_path);
        return;
      }
      throw FormatException(
        'Expected "," or "}" in object',
        _scanner.source,
        _scanner.index,
      );
    }
  }

  void _parseArray() {
    _scanner.index++; // '['
    visitor.beginArray(_path);
    _scanner.skipNoise();
    if (!_scanner.atEnd && _scanner.ch == 0x5D /* ] */) {
      _scanner.index++;
      visitor.endArray(_path);
      return;
    }
    var i = 0;
    while (true) {
      _path.push(i);
      _parseValue();
      _path.pop();
      i++;
      _scanner.skipNoise();
      if (_scanner.atEnd) {
        throw FormatException(
          'Unterminated array',
          _scanner.source,
          _scanner.index,
        );
      }
      if (_scanner.ch == 0x2C /* , */) {
        _scanner.index++;
        _scanner.skipNoise();
        if (!_scanner.atEnd && _scanner.ch == 0x5D /* ] */) {
          _scanner.index++;
          visitor.endArray(_path);
          return;
        }
        continue;
      }
      if (_scanner.ch == 0x5D /* ] */) {
        _scanner.index++;
        visitor.endArray(_path);
        return;
      }
      throw FormatException(
        'Expected "," or "]" in array',
        _scanner.source,
        _scanner.index,
      );
    }
  }
}
