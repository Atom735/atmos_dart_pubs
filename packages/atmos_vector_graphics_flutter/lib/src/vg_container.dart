part of 'vector_graphics_flutter.dart';

extension VgContainerXFlutter on VgContainer {
  void renderToCanvas(
    flt.Canvas canvas,
    flt.Size size, {
    bool withoutClip = false,
    bool onlyWithFill = false,
    bool onlyWithStroke = false,
    bool whiteOnly = false,
    int frameIndex = 0,
    flt.Color? defaultColor,
  }) {
    // ~ white54 without Material dependency.
    defaultColor ??= const flt.Color(0x8AFFFFFF);
    canvas.save();
    final frame = frames[frameIndex];
    final rect = flt.Offset.zero & flt.Size(frame.width, frame.height);
    final paths = List<ui.Path?>.filled(this.paths.length, null);
    ui.Path getPath(int pathId) =>
        paths[pathId] ?? (paths[pathId] = this.paths[pathId].asFlutter);
    final paintsFill = List<ui.Paint?>.filled(paints.length, null);
    final paintsStroke = List<ui.Paint?>.filled(paints.length, null);
    ui.Paint? getPaintFill(int paintId) =>
        paintsFill[paintId] ??
        (paintsFill[paintId] = paints[paintId].toFlutterFill(rect));
    ui.Paint? getPaintStroke(int paintId) =>
        paintsStroke[paintId] ??
        (paintsStroke[paintId] = paints[paintId].toFlutterStroke(rect));
    for (final dc in frame.drawCalls) {
      if (dc is VgDrawCallGroupBegin) {
        canvas.save();
        if (dc.haveTranslate) {
          canvas.translate(dc.translateX!, dc.translateY!);
        }
        if (dc.haveScale) {
          canvas.scale(dc.scaleX!, dc.scaleY);
        }
      }
      if (dc is VgDrawCallGroupEnd) {
        canvas.restore();
      }
      if (dc is VgDrawCallClipPath) {
        if (withoutClip) {
          continue;
        }
        canvas.clipPath(getPath(dc.pathId));
      }
      if (dc is VgDrawCallPaint) {
        if (dc.pathId != null) {
          final path = getPath(dc.pathId!);
          final fill = getPaintFill(dc.paintId);
          if (onlyWithFill) {
            final paint = ui.Paint()
              ..style = ui.PaintingStyle.fill
              ..color = fill?.color ?? defaultColor;
            if (whiteOnly) {
              paint.color = defaultColor;
            }
            canvas.drawPath(path, paint);
          } else if (fill != null && !onlyWithStroke) {
            if (whiteOnly) {
              fill.color = defaultColor;
            }
            canvas.drawPath(path, fill);
          }
          final stroke = getPaintStroke(dc.paintId);
          if (onlyWithStroke) {
            final paint = ui.Paint()
              ..style = ui.PaintingStyle.stroke
              ..strokeWidth = 1
              ..color = stroke?.color ?? defaultColor;
            if (whiteOnly) {
              paint.color = defaultColor;
            }
            canvas.drawPath(path, paint);
          } else if (stroke != null && !onlyWithFill) {
            if (whiteOnly) {
              stroke.color = defaultColor;
            }
            canvas.drawPath(path, stroke);
          }
        }
      }
    }
    canvas.restore();
  }

  /// Получает размер для заданного кадра.
  flt.Size getSize(int frameIndex) {
    final frame = frames[frameIndex];
    return flt.Size(frame.width, frame.height);
  }
}

class VgFlutterCustomPainter extends flt.CustomPainter {
  final VgContainer vcg;
  final bool withoutClip;
  final bool onlyWithFill;
  final bool onlyWithStroke;
  final bool whiteOnly;
  final int frameIndex;

  VgFlutterCustomPainter({
    super.repaint,
    required this.vcg,
    this.withoutClip = false,
    this.onlyWithFill = false,
    this.onlyWithStroke = false,
    this.whiteOnly = false,
    this.frameIndex = 0,
  });

  @override
  void paint(flt.Canvas canvas, flt.Size size) {
    vcg.renderToCanvas(
      canvas,
      size,
      withoutClip: withoutClip,
      onlyWithFill: onlyWithFill,
      onlyWithStroke: onlyWithStroke,
      whiteOnly: whiteOnly,
      frameIndex: frameIndex,
    );
  }

  @override
  bool shouldRepaint(covariant flt.CustomPainter oldDelegate) {
    return true;
  }
}
