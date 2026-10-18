import 'path.dart';
import 'scanner.dart';

/// Pull API for binding JSONC values into Dart types without building Maps.
///
/// ## ENG
/// Use with [JsoncBinder]: [expectObject] / [nextField] / typed readers.
/// [path] tracks the current value location.
///
/// ## RU
/// Вместе с [JsoncBinder]: [expectObject] / [nextField] / типизированные
/// читатели. [path] — текущее расположение значения.
class JsoncReader {
  /// Creates a reader over [source].
  JsoncReader(String source) : _scanner = JsoncScanner(source);

  final JsoncScanner _scanner;
  final JsoncPath _path = JsoncPath();
  final List<int> _arrayIndices = <int>[];

  String? _currentKey;

  /// Live path view for the value about to be read / being read.
  JsoncPath get path => _path;

  /// Current object field name after a successful [nextField].
  String get key {
    final k = _currentKey;
    if (k == null) {
      throw StateError('No current field key');
    }
    return k;
  }

  /// Parses the document root with [binder] and requires EOF.
  T decode<T>(JsoncBinder<T> binder) {
    final value = binder.fromJsonc(this);
    _scanner.expectEof();
    return value;
  }

  /// Expects `{` and enters the object.
  void expectObject() {
    _scanner.skipNoise();
    _expectChar(0x7B, '{');
  }

  /// Expects `[` and enters the array.
  void expectArray() {
    _scanner.skipNoise();
    _expectChar(0x5B, '[');
    _arrayIndices.add(0);
  }

  /// Advances to the next object field.
  ///
  /// Returns `false` when `}` is reached. On `true`, [key] is set and the
  /// reader is positioned at the field value; call [endField] after reading.
  bool nextField() {
    _scanner.skipNoise();
    if (_scanner.atEnd) {
      throw FormatException(
        'Unterminated object',
        _scanner.source,
        _scanner.index,
      );
    }
    if (_scanner.ch == 0x7D /* } */) {
      _scanner.index++;
      _currentKey = null;
      return false;
    }
    if (_scanner.ch == 0x2C /* , */) {
      _scanner.index++;
      _scanner.skipNoise();
      if (!_scanner.atEnd && _scanner.ch == 0x7D /* } */) {
        _scanner.index++;
        _currentKey = null;
        return false;
      }
    }
    if (_scanner.ch != 0x22 /* " */) {
      throw FormatException(
        'Expected object key string',
        _scanner.source,
        _scanner.index,
      );
    }
    final k = _scanner.readString();
    _currentKey = k;
    _path.push(k);
    _scanner.skipNoise();
    _expectChar(0x3A, ':');
    return true;
  }

  /// Pops the field key from [path] after reading the value.
  void endField() {
    if (_path.isEmpty || _path.last is! String) {
      throw StateError('endField without active field');
    }
    _path.pop();
    _currentKey = null;
  }

  /// Advances to the next array element.
  ///
  /// Returns `false` when `]` is reached. On `true`, [path] includes the
  /// element index; call [endElement] after reading the value.
  bool nextElement() {
    _scanner.skipNoise();
    if (_scanner.atEnd) {
      throw FormatException(
        'Unterminated array',
        _scanner.source,
        _scanner.index,
      );
    }
    if (_scanner.ch == 0x5D /* ] */) {
      _scanner.index++;
      if (_arrayIndices.isNotEmpty) {
        _arrayIndices.removeLast();
      }
      return false;
    }
    if (_scanner.ch == 0x2C /* , */) {
      _scanner.index++;
      _scanner.skipNoise();
      if (!_scanner.atEnd && _scanner.ch == 0x5D /* ] */) {
        _scanner.index++;
        if (_arrayIndices.isNotEmpty) {
          _arrayIndices.removeLast();
        }
        return false;
      }
    }
    if (_arrayIndices.isEmpty) {
      throw StateError('nextElement outside of array');
    }
    final i = _arrayIndices.last;
    _arrayIndices[_arrayIndices.length - 1] = i + 1;
    _path.push(i);
    return true;
  }

  /// Pops the element index from [path] after reading the value.
  void endElement() {
    if (_path.isEmpty || _path.last is! int) {
      throw StateError('endElement without active element');
    }
    _path.pop();
  }

  /// Reads a nested value using [binder].
  T readObject<T>(JsoncBinder<T> binder) => binder.fromJsonc(this);

  /// Reads a string scalar.
  String readString() {
    _scanner.skipNoise();
    if (_scanner.atEnd || _scanner.ch != 0x22) {
      throw FormatException('Expected string', _scanner.source, _scanner.index);
    }
    return _scanner.readString();
  }

  /// Reads a number scalar.
  num readNumber() {
    _scanner.skipNoise();
    if (_scanner.atEnd) {
      throw FormatException('Expected number', _scanner.source, _scanner.index);
    }
    final c = _scanner.ch;
    if (c != 0x2D && (c < 0x30 || c > 0x39)) {
      throw FormatException('Expected number', _scanner.source, _scanner.index);
    }
    return _scanner.readNumber();
  }

  /// Reads an integer scalar.
  int readInt() {
    final n = readNumber();
    if (n is int) return n;
    throw FormatException('Expected int', _scanner.source, _scanner.index);
  }

  /// Reads a boolean scalar.
  bool readBool() {
    _scanner.skipNoise();
    final v = _scanner.readLiteral();
    if (v is bool) return v;
    throw FormatException('Expected bool', _scanner.source, _scanner.index);
  }

  /// Reads a JSON `null`.
  void readNull() {
    _scanner.skipNoise();
    final v = _scanner.readLiteral();
    if (v != null) {
      throw FormatException('Expected null', _scanner.source, _scanner.index);
    }
  }

  /// Reads any JSON value as a dynamic tree (`Map` / `List` / scalars).
  Object? readAny() => _readAnyValue();

  /// Skips the next value (object / array / scalar).
  void skip() {
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
      _skipObject();
      return;
    }
    if (c == 0x5B /* [ */) {
      _skipArray();
      return;
    }
    if (c == 0x22) {
      _scanner.readString();
      return;
    }
    if (c == 0x74 || c == 0x66 || c == 0x6E) {
      _scanner.readLiteral();
      return;
    }
    if (c == 0x2D || (c >= 0x30 && c <= 0x39)) {
      _scanner.readNumber();
      return;
    }
    throw FormatException(
      'Unexpected character',
      _scanner.source,
      _scanner.index,
    );
  }

  void _expectChar(int code, String label) {
    if (_scanner.atEnd || _scanner.ch != code) {
      throw FormatException(
        'Expected "$label"',
        _scanner.source,
        _scanner.index,
      );
    }
    _scanner.index++;
  }

  Object? _readAnyValue() {
    _scanner.skipNoise();
    if (_scanner.atEnd) {
      throw FormatException(
        'Unexpected end of input',
        _scanner.source,
        _scanner.index,
      );
    }
    final c = _scanner.ch;
    if (c == 0x7B) return _readAnyObject();
    if (c == 0x5B) return _readAnyArray();
    if (c == 0x22) return _scanner.readString();
    if (c == 0x74 || c == 0x66 || c == 0x6E) return _scanner.readLiteral();
    if (c == 0x2D || (c >= 0x30 && c <= 0x39)) return _scanner.readNumber();
    throw FormatException(
      'Unexpected character',
      _scanner.source,
      _scanner.index,
    );
  }

  Map<String, Object?> _readAnyObject() {
    expectObject();
    final map = <String, Object?>{};
    while (nextField()) {
      map[key] = _readAnyValue();
      endField();
    }
    return map;
  }

  List<Object?> _readAnyArray() {
    expectArray();
    final list = <Object?>[];
    while (nextElement()) {
      list.add(_readAnyValue());
      endElement();
    }
    return list;
  }

  void _skipObject() {
    expectObject();
    while (nextField()) {
      skip();
      endField();
    }
  }

  void _skipArray() {
    expectArray();
    while (nextElement()) {
      skip();
      endElement();
    }
  }
}

/// Binds a JSONC value to a Dart type via [JsoncReader].
///
/// ## ENG
/// Implement [fromJsonc] with pull reads — no intermediate `Map` required.
///
/// ## RU
/// Реализуйте [fromJsonc] через pull-чтение — без промежуточного `Map`.
abstract class JsoncBinder<T> {
  /// Creates a binder.
  const JsoncBinder();

  /// Reads [T] from the current reader position.
  T fromJsonc(JsoncReader reader);
}

/// Decodes [source] into [T] using [binder] (pull API, no tree required).
T jsoncBind<T>(String source, JsoncBinder<T> binder) =>
    JsoncReader(source).decode(binder);
