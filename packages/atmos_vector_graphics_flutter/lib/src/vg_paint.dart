part of 'vector_graphics_flutter.dart';

extension VgPaintXFlutter on VgPaint {
  ui.Paint? toFlutterFill(ui.Rect rect) {
    final fill = this.fill;
    final paint = ui.Paint()..style = ui.PaintingStyle.fill;

    if (fill != null) {
      final shader = fill.shader;
      if (shader != null) {
        if (shader is VgGradientLinear) {
          paint.shader = shader.asFlutter.createShader(rect);
          return paint;
        } else if (shader is VgGradientRadial) {
          paint.shader = shader.asFlutter.createShader(rect);
          return paint;
        }
      } else {
        paint.color = ui.Color(fill.color.value);
        return paint;
      }
    }
    return null;
  }

  ui.Paint? toFlutterStroke(ui.Rect rect) {
    final stroke = this.stroke;
    final paint = ui.Paint()..style = ui.PaintingStyle.stroke;
    if (stroke != null) {
      // Нулевая/отсутствующая ширина обводки не рисуется;
      // минимум 0.5 для видимости тонких обводок из SVG.
      final w = stroke.width ?? 1.0;
      paint.strokeWidth = w <= 0 ? 1.0 : (w < 0.5 ? 0.5 : w);
      paint.strokeCap = stroke.cap?.asFlutter ?? ui.StrokeCap.butt;
      paint.strokeJoin = stroke.join?.asFlutter ?? ui.StrokeJoin.miter;

      final shader = stroke.shader;
      if (shader != null) {
        if (shader is VgGradientLinear) {
          paint.shader = shader.asFlutter.createShader(rect);
          return paint;
        } else if (shader is VgGradientRadial) {
          paint.shader = shader.asFlutter.createShader(rect);
          return paint;
        }
      } else {
        paint.color = ui.Color(stroke.color.value);
        return paint;
      }
    }
    return null;
  }
}

extension VgLinearGradientXFlutter on VgGradientLinear {
  ui.LinearGradient get asFlutter {
    return ui.LinearGradient(
      begin: from.asFlutterAlignment,
      end: to.asFlutterAlignment,
      colors: colors?.map((e) => e.asFlutter).toList() ?? [],
      stops: offsets,
    );
  }
}

extension VgRadialGradientXFlutter on VgGradientRadial {
  ui.RadialGradient get asFlutter {
    return ui.RadialGradient(
      center: center.asFlutterAlignment,
      radius: radius,
      colors: colors?.map((e) => e.asFlutter).toList() ?? [],
      stops: offsets,
    );
  }
}
