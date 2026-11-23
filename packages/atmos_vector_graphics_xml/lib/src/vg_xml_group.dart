part of 'vector_graphics_xml.dart';

extension VgXmlElementXGroup on XmlElement {
  static const childNamesInVgGroup = <String>{
    'path',
    'clip-path',
    'group',
  };

  bool get asVgGroup {
    if (fullCheck(
      'group',
      const <String>{
        'android:scaleX',
        'android:scaleY',
        'android:translateX',
        'android:translateY',
      },
      childNamesInVgGroup,
    )) return false;

    final scaleX = getDouble('android:scaleX');
    final scaleY = getDouble('android:scaleY');
    final translateX = getDouble('android:translateX');
    final translateY = getDouble('android:translateY');

    decoder.drawCalls.add(
      VgDrawCallGroupBegin(
        scaleX: scaleX,
        scaleY: scaleY,
        translateX: translateX,
        translateY: translateY,
      ),
    );

    final result = asVgGroupChildrensXml;
    decoder.drawCalls.add(const VgDrawCallGroupEnd());
    return result;
  }

  bool get asVgGroupChildrensXml {
    for (final child in childElements) {
      switch (child.tName) {
        case 'path':
          if (!child.asVgPathXml) return false;
          break;
        case 'clip-path':
          if (!child.asVgPathClip) return false;
          break;
        case 'group':
          if (!child.asVgGroup) return false;
          break;
        default:
          addError('Unknown element: ${child.tName}');
      }
    }
    return true;
  }

  bool get asVgGroupChildrensSvg {
    for (final child in childElements) {
      switch (child.tName) {
        case 'path':
          if (!child.asVgPathSvg) return false;
          break;
        case 'rect':
          if (!child.asVgRectSvg) return false;
          break;
        case 'g':
          if (!child.asVgGroupSvg) return false;
          break;
        case 'defs':
          // уже собрано в clipPaths при первом проходе
          break;
        case 'ellipse':
          if (!child.asVgEllipseSvg) return false;
          break;
        case 'circle':
          if (!child.asVgCircleSvg) return false;
          break;
        default:
          addError('Unknown element: ${child.tName}');
      }
    }
    return true;
  }

  /// Парсит SVG transform в translate и scale для группы GVG.
  /// Поддерживаются: translate(tx, ty), scale(sx, sy), matrix(1 0 0 -1 e f) (отражение Y + сдвиг).
  static ({double? tx, double? ty, double? sx, double? sy}) parseSvgTransform(
    String? s,
  ) {
    if (s == null || s.trim().isEmpty) {
      return (tx: null, ty: null, sx: null, sy: null);
    }
    double? tx, ty, sx, sy;
    final translate = RegExp(
      r'translate\s*\(\s*([-\d.eE+]+)\s*(?:[\s,]\s*([-\d.eE+]+)\s*)?\)',
    );
    final scale = RegExp(
      r'scale\s*\(\s*([-\d.eE+]+)\s*(?:[\s,]\s*([-\d.eE+]+)\s*)?\)',
    );
    // matrix(a b c d e f): x'=a*x+c*y+e, y'=b*x+d*y+f. matrix(1 0 0 -1 e f) = отражение Y + translate(e,f)
    final matrixFlipY = RegExp(
      r'matrix\s*\(\s*1\s+0\s+0\s+-1\s+([-\d.eE+]+)\s+([-\d.eE+]+)\s*\)',
    );
    for (final m in translate.allMatches(s)) {
      tx = double.tryParse(m.group(1) ?? '');
      ty = m.group(2) != null ? double.tryParse(m.group(2)!) : tx;
    }
    for (final m in scale.allMatches(s)) {
      sx = double.tryParse(m.group(1) ?? '');
      sy = m.group(2) != null ? double.tryParse(m.group(2)!) : sx;
    }
    for (final m in matrixFlipY.allMatches(s)) {
      final e = double.tryParse(m.group(1) ?? '');
      final f = double.tryParse(m.group(2) ?? '');
      if (e != null && f != null) {
        tx = e;
        ty = -f; // для canvas: translate(e, -f) + scale(1, -1) даёт y' = -y + f
        sx = 1;
        sy = -1;
      }
    }
    return (tx: tx, ty: ty, sx: sx, sy: sy);
  }

  /// Парсит любой SVG transform в матрицу 2D [a,b,c,d,e,f]: x'=a*x+c*y+e, y'=b*x+d*y+f.
  /// Возвращает null если строка пустая или не распознана.
  static List<double>? parseSvgTransformToMatrix(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    double a = 1, b = 0, c = 0, d = 1, e = 0, f = 0;

    void multiply(List<double> other) {
      final a0 = a * other[0] + c * other[1];
      final b0 = b * other[0] + d * other[1];
      final c0 = a * other[2] + c * other[3];
      final d0 = b * other[2] + d * other[3];
      final e0 = a * other[4] + c * other[5] + e;
      final f0 = b * other[4] + d * other[5] + f;
      a = a0; b = b0; c = c0; d = d0; e = e0; f = f0;
    }

    final translate = RegExp(
      r'translate\s*\(\s*([-\d.eE+]+)\s*(?:[\s,]\s*([-\d.eE+]+)\s*)?\)',
    );
    final scale = RegExp(
      r'scale\s*\(\s*([-\d.eE+]+)\s*(?:[\s,]\s*([-\d.eE+]+)\s*)?\)',
    );
    final rotate = RegExp(
      r'rotate\s*\(\s*([-\d.eE+]+)\s*(?:[\s,]\s*([-\d.eE+]+)\s*[\s,]\s*([-\d.eE+]+)\s*)?\)',
    );
    final matrix = RegExp(
      r'matrix\s*\(\s*([-\d.eE+]+)\s+([-\d.eE+]+)\s+([-\d.eE+]+)\s+'
      r'([-\d.eE+]+)\s+([-\d.eE+]+)\s+([-\d.eE+]+)\s*\)',
    );

    for (final m in translate.allMatches(s)) {
      final tx = double.tryParse(m.group(1) ?? '') ?? 0;
      final ty = m.group(2) != null ? (double.tryParse(m.group(2)!) ?? 0) : tx;
      multiply([1, 0, 0, 1, tx, ty]);
    }
    for (final m in scale.allMatches(s)) {
      final sx = double.tryParse(m.group(1) ?? '') ?? 1;
      final sy = m.group(2) != null ? (double.tryParse(m.group(2)!) ?? sx) : sx;
      multiply([sx, 0, 0, sy, 0, 0]);
    }
    for (final m in rotate.allMatches(s)) {
      final angle = (double.tryParse(m.group(1) ?? '') ?? 0) * math.pi / 180;
      final cosA = math.cos(angle);
      final sinA = math.sin(angle);
      final cx = m.group(2) != null ? (double.tryParse(m.group(2)!) ?? 0) : 0;
      final cy = m.group(3) != null ? (double.tryParse(m.group(3)!) ?? 0) : 0;
      multiply([
        cosA, sinA, -sinA, cosA,
        cx - cosA * cx + sinA * cy,
        cy - sinA * cx - cosA * cy,
      ]);
    }
    for (final m in matrix.allMatches(s)) {
      final v = [
        double.tryParse(m.group(1) ?? ''),
        double.tryParse(m.group(2) ?? ''),
        double.tryParse(m.group(3) ?? ''),
        double.tryParse(m.group(4) ?? ''),
        double.tryParse(m.group(5) ?? ''),
        double.tryParse(m.group(6) ?? ''),
      ];
      if (v.every((x) => x != null)) multiply(v.map((x) => x!).toList());
    }

    return [a, b, c, d, e, f];
  }

  /// Применяет матрицу [a,b,c,d,e,f] к точке (x,y).
  static (double, double) applyMatrix(List<double> m, double x, double y) {
    return (
      m[0] * x + m[2] * y + m[4],
      m[1] * x + m[3] * y + m[5],
    );
  }

  /// Преобразует команды path матрицей; выдаёт команды в абсолютных координатах.
  static List<VgPathCommand> transformPathCommands(
    List<VgPathCommand> commands,
    List<double> matrix,
  ) {
    var x = 0.0;
    var y = 0.0;
    final out = <VgPathCommand>[];

    for (final cmd in commands) {
      final v = cmd.v;
      switch (cmd.c) {
        case VgPathC.z:
          out.add(const VgPathCommand(VgPathC.z, false, []));
          break;
        case VgPathC.m:
        case VgPathC.l:
          final px = cmd.r ? x + v[0] : v[0];
          final py = cmd.r ? y + v[1] : v[1];
          final t = applyMatrix(matrix, px, py);
          x = t.$1; y = t.$2;
          out.add(VgPathCommand(cmd.c, false, [x, y]));
          break;
        case VgPathC.h:
          final px = cmd.r ? x + v[0] : v[0];
          final t = applyMatrix(matrix, px, y);
          x = t.$1; y = t.$2;
          out.add(VgPathCommand(VgPathC.l, false, [x, y]));
          break;
        case VgPathC.v:
          final py = cmd.r ? y + v[0] : v[0];
          final t = applyMatrix(matrix, x, py);
          x = t.$1; y = t.$2;
          out.add(VgPathCommand(VgPathC.l, false, [x, y]));
          break;
        case VgPathC.c:
          final x1 = cmd.r ? x + v[0] : v[0];
          final y1 = cmd.r ? y + v[1] : v[1];
          final x2 = cmd.r ? x + v[2] : v[2];
          final y2 = cmd.r ? y + v[3] : v[3];
          final x3 = cmd.r ? x + v[4] : v[4];
          final y3 = cmd.r ? y + v[5] : v[5];
          final t1 = applyMatrix(matrix, x1, y1);
          final t2 = applyMatrix(matrix, x2, y2);
          final t3 = applyMatrix(matrix, x3, y3);
          x = t3.$1; y = t3.$2;
          out.add(VgPathCommand(VgPathC.c, false, [t1.$1, t1.$2, t2.$1, t2.$2, x, y]));
          break;
        case VgPathC.s:
          final x2 = cmd.r ? x + v[0] : v[0];
          final y2 = cmd.r ? y + v[1] : v[1];
          final x3 = cmd.r ? x + v[2] : v[2];
          final y3 = cmd.r ? y + v[3] : v[3];
          final t2 = applyMatrix(matrix, x2, y2);
          final t3 = applyMatrix(matrix, x3, y3);
          x = t3.$1; y = t3.$2;
          out.add(VgPathCommand(VgPathC.s, false, [t2.$1, t2.$2, x, y]));
          break;
        case VgPathC.q:
          final x1 = cmd.r ? x + v[0] : v[0];
          final y1 = cmd.r ? y + v[1] : v[1];
          final x3 = cmd.r ? x + v[2] : v[2];
          final y3 = cmd.r ? y + v[3] : v[3];
          final t1 = applyMatrix(matrix, x1, y1);
          final t3 = applyMatrix(matrix, x3, y3);
          x = t3.$1; y = t3.$2;
          out.add(VgPathCommand(VgPathC.q, false, [t1.$1, t1.$2, x, y]));
          break;
        case VgPathC.t:
          final x3 = cmd.r ? x + v[0] : v[0];
          final y3 = cmd.r ? y + v[1] : v[1];
          final t3 = applyMatrix(matrix, x3, y3);
          x = t3.$1; y = t3.$2;
          out.add(VgPathCommand(VgPathC.t, false, [x, y]));
          break;
        case VgPathC.a:
          final x3 = cmd.r ? x + v[5] : v[5];
          final y3 = cmd.r ? y + v[6] : v[6];
          final t3 = applyMatrix(matrix, x3, y3);
          x = t3.$1; y = t3.$2;
          out.add(VgPathCommand(VgPathC.a, false, [
            v[0], v[1], v[2], v[3], v[4], t3.$1, t3.$2,
          ]));
          break;
        case VgPathC.b:
          final x0 = cmd.r ? x + v[0] : v[0];
          final y0 = cmd.r ? y + v[1] : v[1];
          final w = v[2];
          final h = v[3];
          final p0 = applyMatrix(matrix, x0, y0);
          final p1 = applyMatrix(matrix, x0 + w, y0);
          final p2 = applyMatrix(matrix, x0 + w, y0 + h);
          final p3 = applyMatrix(matrix, x0, y0 + h);
          x = p3.$1; y = p3.$2;
          out.add(VgPathCommand(VgPathC.m, false, [p0.$1, p0.$2]));
          out.add(VgPathCommand(VgPathC.l, false, [p1.$1, p1.$2]));
          out.add(VgPathCommand(VgPathC.l, false, [p2.$1, p2.$2]));
          out.add(VgPathCommand(VgPathC.l, false, [p3.$1, p3.$2]));
          out.add(const VgPathCommand(VgPathC.z, false, []));
          break;
        case VgPathC.r:
          final x0 = cmd.r ? x + v[0] : v[0];
          final y0 = cmd.r ? y + v[1] : v[1];
          final w = v[2];
          final h = v[3];
          final rx = v[4];
          final ry = v[5];
          final rectPath = _roundedRectToPathCommands(x0, y0, w, h, rx, ry);
          final transformed = transformPathCommands(rectPath, matrix);
          out.addAll(transformed);
          final t = applyMatrix(matrix, x0 + rx, y0);
          x = t.$1; y = t.$2;
          break;
        case VgPathC.o:
          final cx = cmd.r ? x + v[0] : v[0];
          final cy = cmd.r ? y + v[1] : v[1];
          final rx = v[2];
          final ry = v[3];
          final ellipsePath = _ellipseToPathCommands(cx, cy, rx, ry);
          final transformedEllipse = transformPathCommands(ellipsePath, matrix);
          out.addAll(transformedEllipse);
          final t = applyMatrix(matrix, cx + rx, cy);
          x = t.$1; y = t.$2;
          break;
      }
    }
    return out;
  }

  /// SVG-группа <g>, возможно с clip-path="url(#id)" и transform.
  /// Для clip-path всегда добавляем save/restore (GroupBegin/End), иначе следующий clip
  /// пересекается с текущим и обрезка/слои ломаются.
  bool get asVgGroupSvg {
    if (checkName('g')) return false;

    final t = parseSvgTransform(attr('transform'));
    final hasTransform = t.tx != null || t.ty != null || t.sx != null || t.sy != null;
    final clipPathRef = attr('clip-path');
    final hasClipPath = clipPathRef != null &&
        RegExp(r'url\(#').hasMatch(clipPathRef);

    final needSaveRestore = hasTransform || hasClipPath;
    if (needSaveRestore) {
      decoder.drawCalls.add(
        VgDrawCallGroupBegin(
          scaleX: t.sx,
          scaleY: t.sy,
          translateX: t.tx,
          translateY: t.ty,
        ),
      );
    }

    if (clipPathRef != null) {
      final match = RegExp(r'url\(#([^)]+)\)').firstMatch(clipPathRef);
      if (match != null) {
        final clipPathEl = svgClipPaths?[match.group(1)];
        if (clipPathEl != null) {
          final groupMatrix = hasTransform
              ? parseSvgTransformToMatrix(attr('transform'))
              : null;
          if (!_applyClipPathSvg(clipPathEl, groupMatrix)) {
            if (needSaveRestore) {
              decoder.drawCalls.add(const VgDrawCallGroupEnd());
            }
            return false;
          }
        }
      }
    }

    final result = asVgGroupChildrensSvg;
    if (needSaveRestore) decoder.drawCalls.add(const VgDrawCallGroupEnd());
    return result;
  }

  bool _applyClipPathSvg(XmlElement clipPathEl, List<double>? transformMatrix) {
    for (final child in clipPathEl.childElements) {
      var commands = _clipPathChildToCommands(child);
      if (commands == null) continue;
      if (transformMatrix != null && transformMatrix.isNotEmpty) {
        commands = transformPathCommands(commands, transformMatrix);
      }
      final pathId = decoder.addPath(
        VgPath(VgPathFillType.evenOdd, commands),
      );
      decoder.drawCalls.add(VgDrawCallClipPath(pathId: pathId));
      return true;
    }
    return true;
  }

  List<VgPathCommand>? _clipPathChildToCommands(XmlElement el) {
    switch (el.tName) {
      case 'rect':
        final w = el.getDouble('width');
        final h = el.getDouble('height');
        if (w == null || h == null) return null;
        var x = el.getDouble('x') ?? 0;
        var y = el.getDouble('y') ?? 0;
        final transform = el.attr('transform');
        if (transform != null) {
          final m = RegExp(r'translate\s*\(\s*([-\d.]+)\s+([-\d.]+)\s*\)')
              .firstMatch(transform);
          if (m != null) {
            x += double.tryParse(m.group(1) ?? '0') ?? 0;
            y += double.tryParse(m.group(2) ?? '0') ?? 0;
          }
        }
        var rx = el.getDouble('rx') ?? 0;
        var ry = el.getDouble('ry') ?? rx;
        rx = rx > 0 ? math.min(rx, w / 2) : 0;
        ry = ry > 0 ? math.min(ry, h / 2) : 0;
        return _rectToPathCommandsStatic(x, y, w, h, rx, ry);
      case 'path':
        return el.getPathCommands('d');
      default:
        return null;
    }
  }

  static List<VgPathCommand> _rectToPathCommandsStatic(
    double x, double y, double w, double h, double rx, double ry,
  ) {
    if (rx <= 0 && ry <= 0) {
      return [VgPathCommand(VgPathC.b, false, [x, y, w, h])];
    }
    return [VgPathCommand(VgPathC.r, false, [x, y, w, h, rx, ry])];
  }

  /// Эллипс как path (4 кубических Безье) для применения матрицы.
  static const _ellipseK = 0.552284749831; // 4/3*(sqrt(2)-1) для 90° дуги
  static List<VgPathCommand> _ellipseToPathCommands(
    double cx, double cy, double rx, double ry,
  ) {
    final kx = rx * _ellipseK;
    final ky = ry * _ellipseK;
    return [
      VgPathCommand(VgPathC.m, false, [cx + rx, cy]),
      VgPathCommand(VgPathC.c, false, [
        cx + rx, cy + ky, cx + kx, cy + ry, cx, cy + ry,
      ]),
      VgPathCommand(VgPathC.c, false, [
        cx - kx, cy + ry, cx - rx, cy + ky, cx - rx, cy,
      ]),
      VgPathCommand(VgPathC.c, false, [
        cx - rx, cy - ky, cx - kx, cy - ry, cx, cy - ry,
      ]),
      VgPathCommand(VgPathC.c, false, [
        cx + kx, cy - ry, cx + rx, cy - ky, cx + rx, cy,
      ]),
      const VgPathCommand(VgPathC.z, false, []),
    ];
  }

  /// Скруглённый rect как path: M, L, Q×4, Z (для применения матрицы).
  static List<VgPathCommand> _roundedRectToPathCommands(
    double x, double y, double w, double h, double rx, double ry,
  ) {
    return [
      VgPathCommand(VgPathC.m, false, [x + rx, y]),
      VgPathCommand(VgPathC.l, false, [x + w - rx, y]),
      VgPathCommand(VgPathC.q, false, [x + w, y, x + w, y + ry]),
      VgPathCommand(VgPathC.l, false, [x + w, y + h - ry]),
      VgPathCommand(VgPathC.q, false, [x + w, y + h, x + w - rx, y + h]),
      VgPathCommand(VgPathC.l, false, [x + rx, y + h]),
      VgPathCommand(VgPathC.q, false, [x, y + h, x, y + h - ry]),
      VgPathCommand(VgPathC.l, false, [x, y + ry]),
      VgPathCommand(VgPathC.q, false, [x, y, x + rx, y]),
      const VgPathCommand(VgPathC.z, false, []),
    ];
  }
}
