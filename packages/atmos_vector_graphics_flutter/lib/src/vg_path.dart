part of 'vector_graphics_flutter.dart';

extension VgPathXFlutter on VgPath {
  ui.Path get asFlutter {
    final p = ui.Path();
    p.fillType = fillType.asFlutter;

    var x = 0.0;
    var y = 0.0;
    double? prevCx2;
    double? prevCy2;
    double? prevQx;
    double? prevQy;

    for (final e in coms) {
      final r = e.r;
      final v = e.v;
      switch (e.c) {
        case VgPathC.z:
          p.close();
          prevCx2 = null;
          prevCy2 = null;
          prevQx = null;
          prevQy = null;
          break;
        case VgPathC.m:
          if (r) {
            p.moveTo(x += v[0], y += v[1]);
          } else {
            p.moveTo(x = v[0], y = v[1]);
          }
          prevCx2 = null;
          prevCy2 = null;
          prevQx = null;
          prevQy = null;
          break;
        case VgPathC.l:
          if (r) {
            p.lineTo(x += v[0], y += v[1]);
          } else {
            p.lineTo(x = v[0], y = v[1]);
          }
          prevCx2 = null;
          prevCy2 = null;
          prevQx = null;
          prevQy = null;
          break;
        case VgPathC.h:
          if (r) {
            p.lineTo(x += v[0], y);
          } else {
            p.lineTo(x = v[0], y);
          }
          prevCx2 = null;
          prevCy2 = null;
          prevQx = null;
          prevQy = null;
          break;
        case VgPathC.v:
          if (r) {
            p.lineTo(x, y += v[0]);
          } else {
            p.lineTo(x, y = v[0]);
          }
          prevCx2 = null;
          prevCy2 = null;
          prevQx = null;
          prevQy = null;
          break;
        case VgPathC.c:
          if (r) {
            p.cubicTo(
              x + v[0],
              y + v[1],
              x + v[2],
              y + v[3],
              x + v[4],
              y + v[5],
            );
            prevCx2 = x + v[2];
            prevCy2 = y + v[3];
            x += v[4];
            y += v[5];
          } else {
            p.cubicTo(v[0], v[1], v[2], v[3], x = v[4], y = v[5]);
            prevCx2 = v[2];
            prevCy2 = v[3];
          }
          prevQx = null;
          prevQy = null;
          break;

        case VgPathC.s:
          final cx1 = prevCx2 != null && prevCy2 != null
              ? 2 * x - prevCx2
              : x;
          final cy1 = prevCx2 != null && prevCy2 != null
              ? 2 * y - prevCy2
              : y;
          if (r) {
            p.cubicTo(
              cx1,
              cy1,
              x + v[0],
              y + v[1],
              x + v[2],
              y + v[3],
            );
            prevCx2 = x + v[0];
            prevCy2 = y + v[1];
            x += v[2];
            y += v[3];
          } else {
            p.cubicTo(cx1, cy1, v[0], v[1], x = v[2], y = v[3]);
            prevCx2 = v[0];
            prevCy2 = v[1];
          }
          prevQx = null;
          prevQy = null;
          break;
        case VgPathC.q:
          if (r) {
            p.quadraticBezierTo(x + v[0], y + v[1], x + v[2], y + v[3]);
            prevQx = x + v[0];
            prevQy = y + v[1];
            x += v[2];
            y += v[3];
          } else {
            p.quadraticBezierTo(
              v[0],
              v[1],
              x = v[2],
              y = v[3],
            );
            prevQx = v[0];
            prevQy = v[1];
          }
          prevCx2 = null;
          prevCy2 = null;
          break;

        case VgPathC.t:
          final qx = prevQx != null && prevQy != null
              ? 2 * x - prevQx
              : x;
          final qy = prevQx != null && prevQy != null
              ? 2 * y - prevQy
              : y;
          if (r) {
            p.quadraticBezierTo(qx, qy, x + v[0], y + v[1]);
            prevQx = qx;
            prevQy = qy;
            x += v[0];
            y += v[1];
          } else {
            p.quadraticBezierTo(qx, qy, x = v[0], y = v[1]);
            prevQx = qx;
            prevQy = qy;
          }
          prevCx2 = null;
          prevCy2 = null;
          break;

        case VgPathC.a:
          if (r) {
            p.arcToPoint(
              ui.Offset(x += v[5], y += v[6]),
              radius: ui.Radius.elliptical(v[0], v[1]),
              rotation: v[2],
              largeArc: v[3] > 0.5,
              clockwise: v[4] > 0.5,
            );
          } else {
            p.arcToPoint(
              ui.Offset(x = v[5], y = v[6]),
              radius: ui.Radius.elliptical(v[0], v[1]),
              rotation: v[2],
              largeArc: v[3] > 0.5,
              clockwise: v[4] > 0.5,
            );
          }
          prevCx2 = null;
          prevCy2 = null;
          prevQx = null;
          prevQy = null;
          break;

        case VgPathC.b:
          {
            final x0 = r ? x + v[0] : v[0];
            final y0 = r ? y + v[1] : v[1];
            p.addRect(ui.Rect.fromLTWH(x0, y0, v[2], v[3]));
            break;
          }
        case VgPathC.r:
          {
            final x0 = r ? x + v[0] : v[0];
            final y0 = r ? y + v[1] : v[1];
            final rect = ui.Rect.fromLTWH(x0, y0, v[2], v[3]);
            p.addRRect(
              ui.RRect.fromRectAndRadius(
                rect,
                ui.Radius.elliptical(v[4], v[5]),
              ),
            );
            break;
          }
        case VgPathC.o:
          {
            final cx = r ? x + v[0] : v[0];
            final cy = r ? y + v[1] : v[1];
            p.addOval(
              ui.Rect.fromCenter(
                center: ui.Offset(cx, cy),
                width: 2 * v[2],
                height: 2 * v[3],
              ),
            );
            break;
          }
      }
    }
    return p;
  }
}
