part of 'vector_graphics_xml.dart';

extension VgXmlElementXSvgShapeBase on XmlElement {
  bool addPathFromCommandsSvg(List<VgPathCommand> commands) {
    final fillType = getFillType('fill-rule') ?? VgPathFillType.nonZero;
    final pathId = decoder.addPath(VgPath(fillType, commands));

    final fillAlpha = getDouble('fill-opacity');
    var fillGradient = getGradientFromUrl('fill', fillAlpha);
    var fillColor = getColor('fill');
    if (fillAlpha != null && fillColor != null) {
      fillColor = fillColor.blendOpacity(fillAlpha);
    }
    if (fillGradient != null) fillColor = null;

    final strokeAlpha = getDouble('stroke-opacity');
    var strokeGradient = getGradientFromUrl('stroke', strokeAlpha);
    var strokeColor = getColor('stroke');
    if (strokeAlpha != null && strokeColor != null) {
      strokeColor = strokeColor.blendOpacity(strokeAlpha);
    }
    if (strokeGradient != null) strokeColor = null;

    final strokeWidth = getDouble('stroke-width');
    final strokeJoin = getStrokeJoin('stroke-linejoin');
    final strokeCap = getStrokeCap('stroke-linecap');

    VgFill? fill;
    if (fillColor != null || fillGradient != null) {
      fill = VgFill(color: fillColor, shader: fillGradient);
    }

    VgStroke? stroke;
    if (strokeColor != null || strokeGradient != null || strokeWidth != null) {
      stroke = VgStroke(
        color: strokeColor ?? const VgColor(0xFF000000),
        shader: strokeGradient,
        width: strokeWidth ?? 1,
        cap: strokeCap,
        join: strokeJoin,
      );
    }

    VgPaint? paint;
    if (fill != null || stroke != null) {
      paint = VgPaint(fill: fill, stroke: stroke);
      final paintId = decoder.addPaint(paint);
      decoder.drawCalls.add(VgDrawCallPaint(pathId: pathId, paintId: paintId));
    }
    return true;
  }
}

extension VgXmlElementXRectSvg on XmlElement {
  static const _rectAttrs = {
    'x', 'y', 'width', 'height', 'rx', 'ry',
    'fill', 'fill-opacity', 'fill-rule',
    'stroke', 'stroke-opacity', 'stroke-width',
    'stroke-linejoin', 'stroke-linecap', 'transform',
  };

  bool get asVgRectSvg {
    if (checkName('rect')) return false;
    if (checkAttr(_rectAttrs)) return false;
    final w = getDouble('width');
    final h = getDouble('height');
    if (w == null || h == null) {
      addError('rect requires width and height');
      return false;
    }
    final x = getDouble('x') ?? 0;
    final y = getDouble('y') ?? 0;
    var rx = getDouble('rx') ?? 0;
    var ry = getDouble('ry') ?? rx;
    rx = rx > 0 ? math.min(rx, w / 2) : 0;
    ry = ry > 0 ? math.min(ry, h / 2) : 0;

    var commands = _rectToPathCommands(x, y, w, h, rx, ry);
    final matrix = VgXmlElementXGroup.parseSvgTransformToMatrix(attr('transform'));
    if (matrix != null) {
      commands = VgXmlElementXGroup.transformPathCommands(commands, matrix);
    }
    return addPathFromCommandsSvg(commands);
  }

  List<VgPathCommand> _rectToPathCommands(
    double x, double y, double w, double h, double rx, double ry,
  ) {
    if (rx <= 0 && ry <= 0) {
      return [VgPathCommand(VgPathC.b, false, [x, y, w, h])];
    }
    return [VgPathCommand(VgPathC.r, false, [x, y, w, h, rx, ry])];
  }
}

extension VgXmlElementXEllipseSvg on XmlElement {
  static const _ellipseAttrs = {
    'cx', 'cy', 'rx', 'ry',
    'fill', 'fill-opacity', 'fill-rule',
    'stroke', 'stroke-opacity', 'stroke-width',
    'stroke-linejoin', 'stroke-linecap', 'transform',
  };

  bool get asVgEllipseSvg {
    if (checkName('ellipse')) return false;
    if (checkAttr(_ellipseAttrs)) return false;
    final cx = getDouble('cx') ?? 0;
    final cy = getDouble('cy') ?? 0;
    final rx = getDouble('rx') ?? 0;
    final ry = getDouble('ry') ?? 0;
    if (rx <= 0 || ry <= 0) {
      addError('ellipse requires rx and ry > 0');
      return false;
    }
    var commands = [VgPathCommand(VgPathC.o, false, [cx, cy, rx, ry])];
    final matrix = VgXmlElementXGroup.parseSvgTransformToMatrix(attr('transform'));
    if (matrix != null) {
      commands = VgXmlElementXGroup.transformPathCommands(commands, matrix);
    }
    return addPathFromCommandsSvg(commands);
  }
}

extension VgXmlElementXCircleSvg on XmlElement {
  static const _circleAttrs = {
    'cx', 'cy', 'r',
    'fill', 'fill-opacity', 'fill-rule',
    'stroke', 'stroke-opacity', 'stroke-width',
    'stroke-linejoin', 'stroke-linecap', 'transform',
  };

  bool get asVgCircleSvg {
    if (checkName('circle')) return false;
    if (checkAttr(_circleAttrs)) return false;
    final cx = getDouble('cx') ?? 0;
    final cy = getDouble('cy') ?? 0;
    final r = getDouble('r') ?? 0;
    if (r <= 0) {
      addError('circle requires r > 0');
      return false;
    }
    var commands = [VgPathCommand(VgPathC.o, false, [cx, cy, r, r])];
    final matrix = VgXmlElementXGroup.parseSvgTransformToMatrix(attr('transform'));
    if (matrix != null) {
      commands = VgXmlElementXGroup.transformPathCommands(commands, matrix);
    }
    return addPathFromCommandsSvg(commands);
  }
}
