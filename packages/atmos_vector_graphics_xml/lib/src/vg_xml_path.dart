part of 'vector_graphics_xml.dart';

extension VgXmlElementXPath on XmlElement {
  bool get asVgPathXml {
    if (fullCheck(
      'path',
      const {
        'android:pathData',
        'android:fillColor',
        'android:fillAlpha',
        'android:fillType',
        'android:strokeColor',
        'android:strokeAlpha',
        'android:strokeWidth',
        'android:strokeLineJoin',
        'android:strokeLineCap',
      },
      const {'aapt:attr'},
    )) return false;

    final commands = getPathCommands('android:pathData');
    if (commands == null) {
      addError('Invalid path data for path');
      return false;
    }
    final fillType = getFillType('android:fillType');
    final pathId = decoder.addPath(
      VgPath(fillType ?? VgPathFillType.nonZero, commands),
    );

    var fillColor = getColor('android:fillColor');
    final fillAlpha = getDouble('android:fillAlpha');
    if (fillAlpha != null) {
      fillColor = fillColor?.blendOpacity(fillAlpha);
    }

    var strokeColor = getColor('android:strokeColor');
    final strokeAlpha = getDouble('android:strokeAlpha');
    if (strokeAlpha != null) {
      strokeColor = strokeColor?.blendOpacity(strokeAlpha);
    }

    final strokeWidth = getDouble('android:strokeWidth');
    final strokeJoin = getStrokeJoin('android:strokeLineJoin');
    final strokeCap = getStrokeCap('android:strokeLineCap');

    VgGradient? fillGradient;
    VgGradient? strokeGradient;

    for (final child in childElements) {
      if (child.tName == 'aapt:attr') {
        final name = child.attr('name');
        if (name == 'android:fillColor') {
          if (fillGradient != null || fillColor != null) {
            child.addError('Multiple fill attributes');
            return false;
          }
          if (child.childElements.length != 1) {
            child.addError('Invalid fill attribute');
            return false;
          }
          final childItem = child.childElements.first;
          fillGradient = childItem.asVgGradient(fillAlpha);
        } else if (name == 'android:strokeColor') {
          if (strokeGradient != null || strokeColor != null) {
            child.addError('Multiple stroke attributes');
            return false;
          }
          if (child.childElements.length != 1) {
            child.addError('Invalid stroke attribute');
            return false;
          }
          final childItem = child.childElements.first;
          strokeGradient = childItem.asVgGradient(strokeAlpha);
        } else {
          child.addError('Unknown attribute: $name');
        }
      }
    }

    VgFill? fill;
    if (fillColor != null || fillGradient != null) {
      fill = VgFill(
        color: fillColor,
        shader: fillGradient,
      );
    }

    VgStroke? stroke;
    if (strokeColor != null || strokeWidth != null || strokeGradient != null) {
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
      paint = VgPaint(
        fill: fill,
        stroke: stroke,
      );
      final paintId = decoder.addPaint(paint);
      decoder.drawCalls.add(
        VgDrawCallPaint(
          pathId: pathId,
          paintId: paintId,
        ),
      );
    }
    return true;
  }

  bool get asVgPathSvg {
    if (fullCheck(
      'path',
      const {
        'd',
        'fill',
        'fill-opacity',
        'fill-rule',
        'stroke',
        'stroke-opacity',
        'stroke-width',
        'stroke-dasharray',
        'stroke-linejoin',
        'stroke-linecap',
      },
      const {},
    )) return false;

    final commands = getPathCommands('d');
    if (commands == null) {
      addError('Invalid path data for path');
      return false;
    }
    final fillType = getFillType('fill-rule');
    final pathId = decoder.addPath(
      VgPath(fillType ?? VgPathFillType.nonZero, commands),
    );

    final fillAlpha = getDouble('fill-opacity');
    VgGradient? fillGradient = getGradientFromUrl('fill', fillAlpha);
    var fillColor = getColor('fill');
    if (fillAlpha != null) {
      fillColor = fillColor?.blendOpacity(fillAlpha);
    }
    if (fillGradient != null) fillColor = null;

    final strokeAlpha = getDouble('stroke-opacity');
    VgGradient? strokeGradient = getGradientFromUrl('stroke', strokeAlpha);
    var strokeColor = getColor('stroke');
    if (strokeAlpha != null) {
      strokeColor = strokeColor?.blendOpacity(strokeAlpha);
    }
    if (strokeGradient != null) strokeColor = null;

    final strokeWidth = getDouble('stroke-width');
    final strokeJoin = getStrokeJoin('stroke-linejoin');
    final strokeCap = getStrokeCap('stroke-linecap');

    for (final child in childElements) {
      if (child.tName == 'aapt:attr') {
        final name = child.attr('name');
        if (name == 'android:fillColor') {
          if (fillGradient != null || fillColor != null) {
            child.addError('Multiple fill attributes');
            return false;
          }
          if (child.childElements.length != 1) {
            child.addError('Invalid fill attribute');
            return false;
          }
          final childItem = child.childElements.first;
          fillGradient = childItem.asVgGradient(fillAlpha);
        } else if (name == 'android:strokeColor') {
          if (strokeGradient != null || strokeColor != null) {
            child.addError('Multiple stroke attributes');
            return false;
          }
          if (child.childElements.length != 1) {
            child.addError('Invalid stroke attribute');
            return false;
          }
          final childItem = child.childElements.first;
          strokeGradient = childItem.asVgGradient(strokeAlpha);
        } else {
          child.addError('Unknown attribute: $name');
        }
      }
    }

    VgFill? fill;
    if (fillColor != null || fillGradient != null) {
      fill = VgFill(
        color: fillColor,
        shader: fillGradient,
      );
    }

    VgStroke? stroke;
    if (strokeColor != null || strokeWidth != null || strokeGradient != null) {
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
      paint = VgPaint(
        fill: fill,
        stroke: stroke,
      );
      final paintId = decoder.addPaint(paint);
      decoder.drawCalls.add(
        VgDrawCallPaint(
          pathId: pathId,
          paintId: paintId,
        ),
      );
    }
    return true;
  }
}
