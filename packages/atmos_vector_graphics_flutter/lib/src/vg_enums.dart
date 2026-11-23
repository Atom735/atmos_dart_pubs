part of 'vector_graphics_flutter.dart';

extension VgPathFillTypeXFlutter on VgPathFillType {
  ui.PathFillType get asFlutter {
    if (this == VgPathFillType.evenOdd) {
      return ui.PathFillType.evenOdd;
    } else {
      return ui.PathFillType.nonZero;
    }
  }
}

extension VgColorXFlutter on VgColor {
  ui.Color get asFlutter {
    return ui.Color(value);
  }
}

extension VgStrokeCapXFlutter on VgStrokeCap {
  ui.StrokeCap get asFlutter {
    return ui.StrokeCap.values[index];
  }
}

extension VgStrokeJoinXFlutter on VgStrokeJoin {
  ui.StrokeJoin get asFlutter {
    return ui.StrokeJoin.values[index];
  }
}

extension VgPointXFlutter on VgPoint {
  ui.Alignment get asFlutterAlignment {
    return ui.Alignment(x, y);
  }
}
