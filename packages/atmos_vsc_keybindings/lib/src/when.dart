/// Evaluates VS Code-style `when` clauses against a context map.
///
/// ## ENG
/// Supports `&&`, `||`, `!`, parentheses, identifiers, and
/// `key == 'value'` / `!=` / `=~` (substring). Unknown syntax fails closed
/// (`false`) unless `strict` is true (then throws).
///
/// ## RU
/// Поддержка `&&`, `||`, `!`, скобок, идентификаторов и сравнений.
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
      if (!parser.done && strict) {
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
    final key = _readIdentifier();
    if (key == null) {
      throw const FormatException('Expected context key');
    }
    skipWs();
    if (_match('==')) {
      skipWs();
      final expected = _readStringOrIdent();
      return _stringify(context[key]) == expected;
    }
    if (_match('!=')) {
      skipWs();
      final expected = _readStringOrIdent();
      return _stringify(context[key]) != expected;
    }
    if (_match('=~')) {
      skipWs();
      final pattern = _readStringOrIdent();
      return _stringify(context[key]).contains(pattern);
    }
    return _truthy(context[key]);
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

  static bool _truthy(Object? v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) return v.isNotEmpty && v != 'false' && v != '0';
    return true;
  }

  static String _stringify(Object? v) => v?.toString() ?? '';

  static bool _isWs(int c) => c == 0x20 || c == 0x09 || c == 0x0a || c == 0x0d;

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
