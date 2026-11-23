import '../errors.dart';
import '../transform.dart';
import 'command.dart';

/// Parsed SVG path `d` attribute as a list of [SvgPathCommand]s.
///
/// Разобранный атрибут SVG path `d` как список [SvgPathCommand].
class SvgPath {
  /// Creates a path from [commands].
  ///
  /// Создаёт path из [commands].
  SvgPath(List<SvgPathCommand> commands)
      : commands = List<SvgPathCommand>.unmodifiable(commands);

  /// Parses a path `d` string.
  ///
  /// Разбирает строку path `d`.
  factory SvgPath.parse(String d) => SvgPath(_parse(d));

  /// Path commands in order.
  ///
  /// Команды path по порядку.
  final List<SvgPathCommand> commands;

  /// Whether the path has no commands.
  ///
  /// Пуст ли path.
  bool get isEmpty => commands.isEmpty;

  /// Serializes back to a `d` string.
  ///
  /// Сериализует обратно в строку `d`.
  @override
  String toString() {
    if (commands.isEmpty) return '';
    final buf = StringBuffer();
    for (var i = 0; i < commands.length; i++) {
      if (i > 0) buf.write(' ');
      buf.write(commands[i]);
    }
    return buf.toString();
  }

  /// Returns a path with every point translated by ([dx], [dy]).
  /// Relative commands keep relative deltas unchanged.
  ///
  /// Path со сдвигом каждой точки на ([dx], [dy]).
  /// Относительные команды не меняют свои дельты.
  SvgPath translate(double dx, double dy) {
    if (dx == 0 && dy == 0) return this;
    return transform(SvgMatrix.translate(dx, dy));
  }

  /// Scales about the origin.
  ///
  /// Масштабирует относительно начала координат.
  SvgPath scale(double sx, [double? sy]) {
    final syy = sy ?? sx;
    if (sx == 1 && syy == 1) return this;
    return transform(SvgMatrix.scale(sx, syy));
  }

  /// Applies an affine [matrix] to absolute coordinates; relative
  /// command deltas are transformed as vectors (no translation).
  ///
  /// Применяет аффинную [matrix] к абсолютным координатам; относительные
  /// дельты преобразуются как векторы (без трансляции).
  SvgPath transform(SvgMatrix matrix) {
    final out = <SvgPathCommand>[];
    for (final cmd in commands) {
      out.add(_transformCommand(cmd, matrix));
    }
    return SvgPath(out);
  }

  /// Converts all commands to absolute form.
  ///
  /// Переводит все команды в абсолютную форму.
  SvgPath toAbsolute() {
    var x = 0.0;
    var y = 0.0;
    var startX = 0.0;
    var startY = 0.0;
    final out = <SvgPathCommand>[];
    for (final cmd in commands) {
      final abs = _toAbsolute(cmd, x, y, startX, startY);
      out.add(abs.command);
      x = abs.x;
      y = abs.y;
      startX = abs.startX;
      startY = abs.startY;
    }
    return SvgPath(out);
  }

  @override
  bool operator ==(Object other) =>
      other is SvgPath && _cmdsEq(other.commands, commands);

  @override
  int get hashCode => Object.hashAll(commands);
}

bool _cmdsEq(List<SvgPathCommand> a, List<SvgPathCommand> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class _AbsState {
  _AbsState(this.command, this.x, this.y, this.startX, this.startY);
  final SvgPathCommand command;
  final double x;
  final double y;
  final double startX;
  final double startY;
}

_AbsState _toAbsolute(
  SvgPathCommand cmd,
  double x,
  double y,
  double startX,
  double startY,
) {
  final t = cmd.type;
  final a = cmd.args;
  if (cmd.isAbsolute && t != 'Z') {
    final next = _updateCursor(t, a, x, y, startX, startY, absolute: true);
    return _AbsState(cmd, next.x, next.y, next.startX, next.startY);
  }
  switch (t) {
    case 'Z':
      return _AbsState(
        SvgPathCommand('Z', const []),
        startX,
        startY,
        startX,
        startY,
      );
    case 'M':
      final nx = x + a[0];
      final ny = y + a[1];
      final args = <double>[nx, ny];
      var cx = nx;
      var cy = ny;
      for (var i = 2; i + 1 < a.length; i += 2) {
        cx += a[i];
        cy += a[i + 1];
        args
          ..add(cx)
          ..add(cy);
      }
      return _AbsState(SvgPathCommand('M', args), cx, cy, nx, ny);
    case 'L':
    case 'T':
      final args = <double>[];
      var cx = x;
      var cy = y;
      for (var i = 0; i + 1 < a.length; i += 2) {
        cx += a[i];
        cy += a[i + 1];
        args
          ..add(cx)
          ..add(cy);
      }
      return _AbsState(SvgPathCommand(t, args), cx, cy, startX, startY);
    case 'H':
      final args = <double>[];
      var cx = x;
      for (final v in a) {
        cx += v;
        args.add(cx);
      }
      return _AbsState(SvgPathCommand('H', args), cx, y, startX, startY);
    case 'V':
      final args = <double>[];
      var cy = y;
      for (final v in a) {
        cy += v;
        args.add(cy);
      }
      return _AbsState(SvgPathCommand('V', args), x, cy, startX, startY);
    case 'C':
      final args = <double>[];
      var cx = x;
      var cy = y;
      for (var i = 0; i + 5 < a.length; i += 6) {
        args
          ..add(cx + a[i])
          ..add(cy + a[i + 1])
          ..add(cx + a[i + 2])
          ..add(cy + a[i + 3])
          ..add(cx + a[i + 4])
          ..add(cy + a[i + 5]);
        cx += a[i + 4];
        cy += a[i + 5];
      }
      return _AbsState(SvgPathCommand('C', args), cx, cy, startX, startY);
    case 'S':
    case 'Q':
      final args = <double>[];
      var cx = x;
      var cy = y;
      for (var i = 0; i + 3 < a.length; i += 4) {
        args
          ..add(cx + a[i])
          ..add(cy + a[i + 1])
          ..add(cx + a[i + 2])
          ..add(cy + a[i + 3]);
        cx += a[i + 2];
        cy += a[i + 3];
      }
      return _AbsState(SvgPathCommand(t, args), cx, cy, startX, startY);
    case 'A':
      final args = <double>[];
      var cx = x;
      var cy = y;
      for (var i = 0; i + 6 < a.length; i += 7) {
        args
          ..add(a[i])
          ..add(a[i + 1])
          ..add(a[i + 2])
          ..add(a[i + 3])
          ..add(a[i + 4])
          ..add(cx + a[i + 5])
          ..add(cy + a[i + 6]);
        cx += a[i + 5];
        cy += a[i + 6];
      }
      return _AbsState(SvgPathCommand('A', args), cx, cy, startX, startY);
    default:
      throw SvgFormatException('Unsupported path command "$t"');
  }
}

class _Cursor {
  _Cursor(this.x, this.y, this.startX, this.startY);
  final double x;
  final double y;
  final double startX;
  final double startY;
}

_Cursor _updateCursor(
  String t,
  List<double> a,
  double x,
  double y,
  double startX,
  double startY, {
  required bool absolute,
}) {
  switch (t) {
    case 'M':
      if (a.length < 2) return _Cursor(x, y, startX, startY);
      final nx = absolute ? a[0] : x + a[0];
      final ny = absolute ? a[1] : y + a[1];
      var cx = nx;
      var cy = ny;
      for (var i = 2; i + 1 < a.length; i += 2) {
        cx = absolute ? a[i] : cx + a[i];
        cy = absolute ? a[i + 1] : cy + a[i + 1];
      }
      return _Cursor(cx, cy, nx, ny);
    case 'L':
    case 'T':
      var cx = x;
      var cy = y;
      for (var i = 0; i + 1 < a.length; i += 2) {
        cx = absolute ? a[i] : cx + a[i];
        cy = absolute ? a[i + 1] : cy + a[i + 1];
      }
      return _Cursor(cx, cy, startX, startY);
    case 'H':
      var cx = x;
      for (final v in a) {
        cx = absolute ? v : cx + v;
      }
      return _Cursor(cx, y, startX, startY);
    case 'V':
      var cy = y;
      for (final v in a) {
        cy = absolute ? v : cy + v;
      }
      return _Cursor(x, cy, startX, startY);
    case 'C':
      var cx = x;
      var cy = y;
      for (var i = 0; i + 5 < a.length; i += 6) {
        cx = absolute ? a[i + 4] : cx + a[i + 4];
        cy = absolute ? a[i + 5] : cy + a[i + 5];
      }
      return _Cursor(cx, cy, startX, startY);
    case 'S':
    case 'Q':
      var cx = x;
      var cy = y;
      for (var i = 0; i + 3 < a.length; i += 4) {
        cx = absolute ? a[i + 2] : cx + a[i + 2];
        cy = absolute ? a[i + 3] : cy + a[i + 3];
      }
      return _Cursor(cx, cy, startX, startY);
    case 'A':
      var cx = x;
      var cy = y;
      for (var i = 0; i + 6 < a.length; i += 7) {
        cx = absolute ? a[i + 5] : cx + a[i + 5];
        cy = absolute ? a[i + 6] : cy + a[i + 6];
      }
      return _Cursor(cx, cy, startX, startY);
    case 'Z':
      return _Cursor(startX, startY, startX, startY);
    default:
      return _Cursor(x, y, startX, startY);
  }
}

SvgPathCommand _transformCommand(SvgPathCommand cmd, SvgMatrix m) {
  if (cmd.type == 'Z') return cmd;

  if (!cmd.isAbsolute) {
    // Transform deltas as vectors (ignore translation).
    final linear = SvgMatrix(m.a, m.b, m.c, m.d, 0, 0);
    return _mapArgs(cmd, linear, relative: true);
  }
  return _mapArgs(cmd, m, relative: false);
}

SvgPathCommand _mapArgs(
  SvgPathCommand cmd,
  SvgMatrix m, {
  required bool relative,
}) {
  final t = cmd.type;
  final a = List<double>.from(cmd.args);
  void mapPair(int i) {
    if (relative) {
      final v = m.transformVector(a[i], a[i + 1]);
      a[i] = v.x;
      a[i + 1] = v.y;
    } else {
      final p = m.transformPoint(a[i], a[i + 1]);
      a[i] = p.x;
      a[i + 1] = p.y;
    }
  }

  switch (t) {
    case 'M':
    case 'L':
    case 'T':
      for (var i = 0; i + 1 < a.length; i += 2) {
        mapPair(i);
      }
    case 'H':
      // X-only; approximate with linear x scale / shear ignored for H
      for (var i = 0; i < a.length; i++) {
        if (relative) {
          a[i] = m.transformVector(a[i], 0).x;
        } else {
          a[i] = m.transformPoint(a[i], 0).x;
        }
      }
    case 'V':
      for (var i = 0; i < a.length; i++) {
        if (relative) {
          a[i] = m.transformVector(0, a[i]).y;
        } else {
          a[i] = m.transformPoint(0, a[i]).y;
        }
      }
    case 'C':
      for (var i = 0; i + 5 < a.length; i += 6) {
        mapPair(i);
        mapPair(i + 2);
        mapPair(i + 4);
      }
    case 'S':
    case 'Q':
      for (var i = 0; i + 3 < a.length; i += 4) {
        mapPair(i);
        mapPair(i + 2);
      }
    case 'A':
      for (var i = 0; i + 6 < a.length; i += 7) {
        // radii as vectors, endpoint as point/vector
        final r = m.transformVector(a[i], a[i + 1]);
        a[i] = r.x.abs();
        a[i + 1] = r.y.abs();
        if (relative) {
          final e = m.transformVector(a[i + 5], a[i + 6]);
          a[i + 5] = e.x;
          a[i + 6] = e.y;
        } else {
          final e = m.transformPoint(a[i + 5], a[i + 6]);
          a[i + 5] = e.x;
          a[i + 6] = e.y;
        }
      }
  }
  return SvgPathCommand(cmd.letter, a);
}

List<SvgPathCommand> _parse(String d) {
  final tokens = _tokenize(d);
  final commands = <SvgPathCommand>[];
  var i = 0;
  String? letter;

  int arity(String L) {
    switch (L.toUpperCase()) {
      case 'Z':
        return 0;
      case 'H':
      case 'V':
        return 1;
      case 'M':
      case 'L':
      case 'T':
        return 2;
      case 'S':
      case 'Q':
        return 4;
      case 'C':
        return 6;
      case 'A':
        return 7;
      default:
        throw SvgFormatException('Unknown path command "$L"');
    }
  }

  while (i < tokens.length) {
    final t = tokens[i];
    if (RegExp(r'^[MmLlHhVvCcSsQqTtAaZz]$').hasMatch(t)) {
      letter = t;
      i++;
    } else if (letter == null) {
      throw SvgFormatException('Path must start with a command, got $t');
    }
    final L = letter;
    final n = arity(L);
    if (n == 0) {
      commands.add(SvgPathCommand(L, const []));
      letter = null;
      continue;
    }
    final args = <double>[];
    while (i < tokens.length && double.tryParse(tokens[i]) != null) {
      args.add(double.parse(tokens[i++]));
    }
    if (args.isEmpty || args.length % n != 0) {
      throw SvgFormatException(
        'Command $L expects multiples of $n numbers, got ${args.length}',
      );
    }
    // Implicit repetition: M → subsequent pairs are L
    if (L.toUpperCase() == 'M' && args.length > 2) {
      commands.add(SvgPathCommand(L, args.sublist(0, 2)));
      final rest = args.sublist(2);
      final impl = L == 'M' ? 'L' : 'l';
      for (var j = 0; j < rest.length; j += 2) {
        commands.add(SvgPathCommand(impl, rest.sublist(j, j + 2)));
      }
    } else {
      for (var j = 0; j < args.length; j += n) {
        commands.add(SvgPathCommand(L, args.sublist(j, j + n)));
      }
    }
    // After first M, implicit continues as L — letter stays for next numbers
    if (L.toUpperCase() == 'M') {
      letter = L == 'M' ? 'L' : 'l';
    }
  }
  return commands;
}

List<String> _tokenize(String d) {
  final out = <String>[];
  final re = RegExp(
    r'([MmLlHhVvCcSsQqTtAaZz])|([+-]?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?)',
  );
  for (final m in re.allMatches(d)) {
    out.add(m.group(0)!);
  }
  return out;
}
