import 'dart:math' as math;

import 'package:atmos_ttf/atmos_ttf.dart';

/// Parses an SVG path `d` string into TrueType contours.
///
/// Supports `M/m L/l H/h V/v C/c Q/q Z/z`. Cubics are approximated with
/// one quadratic segment (control ≈ midpoint of cubic controls).
/// Coordinates are mapped into font space: Y is flipped with
/// [viewBoxHeight] (SVG Y-down → font Y-up).
///
/// Разбирает SVG path `d` в контуры TrueType.
///
/// Поддерживаются `M/m L/l H/h V/v C/c Q/q Z/z`. Кубики аппроксимируются
/// одним квадратичным сегментом. Координаты в пространство шрифта: Y
/// переворачивается через [viewBoxHeight] (SVG Y вниз → шрифт Y вверх).
List<TtfContour> svgPathToContours(
  String d, {
  double viewBoxHeight = 1000,
  double scale = 1,
}) {
  final tokens = _tokenize(d);
  final contours = <TtfContour>[];
  var i = 0;
  String? cmd;
  var cx = 0.0;
  var cy = 0.0;
  var startX = 0.0;
  var startY = 0.0;
  var current = <TtfPoint>[];

  void flush() {
    if (current.isNotEmpty) {
      contours.add(TtfContour(List<TtfPoint>.from(current)));
      current = [];
    }
  }

  TtfPoint mapPoint(double x, double y, {bool onCurve = true}) {
    final fx = (x * scale).round();
    final fy = ((viewBoxHeight - y) * scale).round();
    return TtfPoint(fx, fy, onCurve: onCurve);
  }

  double nextNum() {
    if (i >= tokens.length) {
      throw const FormatException('Unexpected end of SVG path');
    }
    return double.parse(tokens[i++]);
  }

  bool nextIsNumber() {
    if (i >= tokens.length) return false;
    return double.tryParse(tokens[i]) != null;
  }

  while (i < tokens.length) {
    final t = tokens[i];
    if (RegExp(r'^[MmLlHhVvCcQqZz]$').hasMatch(t)) {
      cmd = t;
      i++;
    } else if (cmd == null) {
      throw FormatException('SVG path must start with a command, got $t');
    }

    final c = cmd;
    final relative = c == c.toLowerCase();
    final op = c.toUpperCase();

    switch (op) {
      case 'M':
        flush();
        final x = nextNum();
        final y = nextNum();
        cx = relative ? cx + x : x;
        cy = relative ? cy + y : y;
        startX = cx;
        startY = cy;
        current.add(mapPoint(cx, cy));
        cmd = relative ? 'l' : 'L';
        while (nextIsNumber()) {
          final lx = nextNum();
          final ly = nextNum();
          cx = relative ? cx + lx : lx;
          cy = relative ? cy + ly : ly;
          current.add(mapPoint(cx, cy));
        }
      case 'L':
        do {
          final x = nextNum();
          final y = nextNum();
          cx = relative ? cx + x : x;
          cy = relative ? cy + y : y;
          current.add(mapPoint(cx, cy));
        } while (nextIsNumber());
      case 'H':
        do {
          final x = nextNum();
          cx = relative ? cx + x : x;
          current.add(mapPoint(cx, cy));
        } while (nextIsNumber());
      case 'V':
        do {
          final y = nextNum();
          cy = relative ? cy + y : y;
          current.add(mapPoint(cx, cy));
        } while (nextIsNumber());
      case 'Q':
        do {
          final x1 = nextNum();
          final y1 = nextNum();
          final x = nextNum();
          final y = nextNum();
          final qx = relative ? cx + x1 : x1;
          final qy = relative ? cy + y1 : y1;
          cx = relative ? cx + x : x;
          cy = relative ? cy + y : y;
          current
            ..add(mapPoint(qx, qy, onCurve: false))
            ..add(mapPoint(cx, cy));
        } while (nextIsNumber());
      case 'C':
        do {
          final x1 = nextNum();
          final y1 = nextNum();
          final x2 = nextNum();
          final y2 = nextNum();
          final x = nextNum();
          final y = nextNum();
          final p1x = relative ? cx + x1 : x1;
          final p1y = relative ? cy + y1 : y1;
          final p2x = relative ? cx + x2 : x2;
          final p2y = relative ? cy + y2 : y2;
          cx = relative ? cx + x : x;
          cy = relative ? cy + y : y;
          final qx = (p1x + p2x) / 2;
          final qy = (p1y + p2y) / 2;
          current
            ..add(mapPoint(qx, qy, onCurve: false))
            ..add(mapPoint(cx, cy));
        } while (nextIsNumber());
      case 'Z':
        if (current.isNotEmpty) {
          if ((cx - startX).abs() > 1e-6 || (cy - startY).abs() > 1e-6) {
            current.add(mapPoint(startX, startY));
          }
          flush();
        }
        cx = startX;
        cy = startY;
      default:
        throw FormatException('Unsupported SVG path command $c');
    }
  }
  flush();
  return contours;
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

/// Axis-aligned bounds of [contours].
///
/// Осевыровненные границы [contours].
({int xMin, int yMin, int xMax, int yMax}) contourBounds(
  List<TtfContour> contours,
) {
  var xMin = 0x7FFFFFFF;
  var yMin = 0x7FFFFFFF;
  var xMax = -0x80000000;
  var yMax = -0x80000000;
  for (final c in contours) {
    for (final p in c.points) {
      xMin = math.min(xMin, p.x);
      yMin = math.min(yMin, p.y);
      xMax = math.max(xMax, p.x);
      yMax = math.max(yMax, p.y);
    }
  }
  return (xMin: xMin, yMin: yMin, xMax: xMax, yMax: yMax);
}
