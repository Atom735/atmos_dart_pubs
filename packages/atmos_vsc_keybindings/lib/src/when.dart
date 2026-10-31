/// Evaluates VS Code-style `when` clauses against a context map.
///
/// ## ENG
/// Supports `&&`, `||`, `!`, parentheses, identifiers, boolean literals,
/// `==` / `!=`, numeric `>` / `>=` / `<` / `<=`, and `=~` with `/regex/`
/// (or substring for quoted patterns). Unknown / trailing syntax fails closed
/// (`false`) unless `strict` is true (then throws).
///
/// ## RU
/// `&&` / `||` / `!` / скобки, литералы, сравнения и `=~ /regex/`.
/// Неизвестный синтаксис → `false`, либо throw при `strict`.
abstract final class VscWhenEvaluator {
  /// Whether [clause] is satisfied by [context].
  ///
  /// Empty / null clause is always true.
  static bool evaluate(
    String? clause,
    Map<String, Object?> context, {
    bool strict = false,
  }) {
    if (clause == null || clause.trim().isEmpty) return true;
    try {
      final parser = _WhenParser(clause, context);
      final value = parser.parseExpression();
      parser.skipWs();
      if (!parser.done) {
        throw FormatException('Trailing input in when: "$clause"');
      }
      return value;
    } on FormatException {
      if (strict) rethrow;
      return false;
    }
  }
}

class _WhenParser {
  _WhenParser(this.source, this.context);

  final String source;
  final Map<String, Object?> context;
  int _i = 0;

  bool get done => _i >= source.length;

  void skipWs() {
    while (!done && _isWs(source.codeUnitAt(_i))) {
      _i++;
    }
  }

  bool parseExpression() => parseOr();

  bool parseOr() {
    var left = parseAnd();
    while (true) {
      skipWs();
      if (_match('||')) {
        final right = parseAnd();
        left = left || right;
      } else {
        return left;
      }
    }
  }

  bool parseAnd() {
    var left = parseUnary();
    while (true) {
      skipWs();
      if (_match('&&')) {
        final right = parseUnary();
        left = left && right;
      } else {
        return left;
      }
    }
  }

  bool parseUnary() {
    skipWs();
    if (_match('!')) {
      return !parseUnary();
    }
    if (_match('(')) {
      final inner = parseExpression();
      skipWs();
      if (!_match(')')) {
        throw const FormatException('Expected )');
      }
      return inner;
    }
    return parsePrimary();
  }

  bool parsePrimary() {
    skipWs();
    if (_matchKeyword('true')) return true;
    if (_matchKeyword('false')) return false;

    final key = _readIdentifier();
    if (key == null) {
      throw const FormatException('Expected context key');
    }
    skipWs();

    if (_match('==')) {
      skipWs();
      return _stringify(context[key]) == _readStringOrIdent();
    }
    if (_match('!=')) {
      skipWs();
      return _stringify(context[key]) != _readStringOrIdent();
    }
    if (_match('=~')) {
      skipWs();
      return _matchPattern(context[key]);
    }
    if (_match('>=')) {
      return _compareNum(context[key], _readNumberOperand(), (a, b) => a >= b);
    }
    if (_match('<=')) {
      return _compareNum(context[key], _readNumberOperand(), (a, b) => a <= b);
    }
    if (_match('>')) {
      return _compareNum(context[key], _readNumberOperand(), (a, b) => a > b);
    }
    if (_match('<')) {
      return _compareNum(context[key], _readNumberOperand(), (a, b) => a < b);
    }

    return _truthy(context[key]);
  }

  bool _matchPattern(Object? value) {
    final text = _stringify(value);
    skipWs();
    if (!done && source[_i] == '/') {
      final re = _readRegex();
      return re.hasMatch(text);
    }
    final pattern = _readStringOrIdent();
    return text.contains(pattern);
  }

  RegExp _readRegex() {
    if (done || source[_i] != '/') {
      throw const FormatException('Expected /regex/');
    }
    _i++;
    final buf = StringBuffer();
    while (!done) {
      final c = source[_i];
      if (c == '/') break;
      if (c == r'\' && _i + 1 < source.length) {
        buf.write(source[_i + 1]);
        _i += 2;
        continue;
      }
      buf.write(c);
      _i++;
    }
    if (done || source[_i] != '/') {
      throw const FormatException('Unclosed /regex/');
    }
    _i++;
    var caseSensitive = true;
    var multiLine = false;
    var dotAll = false;
    while (!done) {
      final f = source[_i];
      if (f == 'i') {
        caseSensitive = false;
      } else if (f == 'm') {
        multiLine = true;
      } else if (f == 's') {
        dotAll = true;
      } else if (f == 'g' || f == 'u') {
        // JS flags with no Dart equivalent — ignore.
      } else {
        break;
      }
      _i++;
    }
    return RegExp(
      buf.toString(),
      caseSensitive: caseSensitive,
      multiLine: multiLine,
      dotAll: dotAll,
    );
  }

  num _readNumberOperand() {
    skipWs();
    final start = _i;
    if (!done && (source[_i] == '+' || source[_i] == '-')) {
      _i++;
    }
    while (!done && _isDigit(source.codeUnitAt(_i))) {
      _i++;
    }
    if (!done && source[_i] == '.') {
      _i++;
      while (!done && _isDigit(source.codeUnitAt(_i))) {
        _i++;
      }
    }
    if (_i == start ||
        (_i == start + 1 &&
            (source[start] == '+' || source[start] == '-'))) {
      throw const FormatException('Expected number');
    }
    return num.parse(source.substring(start, _i));
  }

  bool _compareNum(
    Object? left,
    num right,
    bool Function(num a, num b) op,
  ) {
    final a = _asNum(left);
    if (a == null) return false;
    return op(a, right);
  }

  static num? _asNum(Object? v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }

  String? _readIdentifier() {
    skipWs();
    if (done) return null;
    final start = _i;
    final c0 = source.codeUnitAt(_i);
    if (!_isIdentStart(c0)) return null;
    _i++;
    while (!done && _isIdentPart(source.codeUnitAt(_i))) {
      _i++;
    }
    return source.substring(start, _i);
  }

  String _readStringOrIdent() {
    skipWs();
    if (!done && (source[_i] == "'" || source[_i] == '"')) {
      final quote = source[_i];
      _i++;
      final start = _i;
      while (!done && source[_i] != quote) {
        _i++;
      }
      final value = source.substring(start, _i);
      if (!done) _i++;
      return value;
    }
    if (_matchKeyword('true')) return 'true';
    if (_matchKeyword('false')) return 'false';
    final id = _readIdentifier();
    if (id == null) {
      throw const FormatException('Expected string or identifier');
    }
    return id;
  }

  bool _match(String op) {
    skipWs();
    if (source.startsWith(op, _i)) {
      _i += op.length;
      return true;
    }
    return false;
  }

  bool _matchKeyword(String word) {
    skipWs();
    if (!source.startsWith(word, _i)) return false;
    final end = _i + word.length;
    if (end < source.length && _isIdentPart(source.codeUnitAt(end))) {
      return false;
    }
    _i = end;
    return true;
  }

  static bool _truthy(Object? v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) return v.isNotEmpty && v != 'false' && v != '0';
    return true;
  }

  static String _stringify(Object? v) => v?.toString() ?? '';

  static bool _isWs(int c) => c == 0x20 || c == 0x09 || c == 0x0a || c == 0x0d;

  static bool _isDigit(int c) => c >= 0x30 && c <= 0x39;

  static bool _isIdentStart(int c) =>
      (c >= 0x41 && c <= 0x5a) ||
      (c >= 0x61 && c <= 0x7a) ||
      c == 0x5f ||
      c == 0x24;

  static bool _isIdentPart(int c) =>
      _isIdentStart(c) ||
      (c >= 0x30 && c <= 0x39) ||
      c == 0x2e ||
      c == 0x2d;
}
