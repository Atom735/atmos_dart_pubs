part of 'vector_graphics_core.dart';

typedef VgFill = Fill;

extension VgFillX on VgFill {
  bool isEquals(VgFill other, [double delta = 1e-6]) {
    if (shader == null && other.shader == null) {
      return color.isEquals(other.color, delta);
    }
    if (shader == null || other.shader == null) {
      return false;
    }
    return color.isEquals(other.color, delta) &&
        shader!.isEquals(other.shader!, delta);
  }
}

typedef VgStroke = Stroke;

extension VgStrokeX on VgStroke {
  bool isEquals(VgStroke other, [double delta = 1e-6]) {
    final thisShader = shader;
    final otherShader = other.shader;
    if (thisShader == null && otherShader == null) {
      if (!color.isEquals(other.color, delta)) return false;
      final w = width ?? 0;
      final ow = other.width ?? 0;
      if ((w - ow).abs() > delta) return false;
      if (cap != other.cap || join != other.join) return false;
      return true;
    }
    if (thisShader == null || otherShader == null) {
      return false;
    }
    if (!color.isEquals(other.color, delta)) return false;
    final w = width ?? 0;
    final ow = other.width ?? 0;
    if ((w - ow).abs() > delta) return false;
    if (cap != other.cap || join != other.join) return false;
    return thisShader.isEquals(otherShader, delta);
  }
}

/// Кисть.
typedef VgPaint = Paint;

extension VgPaintX on VgPaint {
  bool isEquals(VgPaint other, [double delta = 1e-6]) {
    if ((fill == null) != (other.fill == null)) return false;
    if ((stroke == null) != (other.stroke == null)) return false;
    if (fill != null && other.fill != null) {
      if (!fill!.isEquals(other.fill!, delta)) return false;
    }
    if (stroke != null && other.stroke != null) {
      if (!stroke!.isEquals(other.stroke!, delta)) return false;
    }
    return true;
  }
}

typedef VgGradient = Gradient;

extension VgGradientX on VgGradient {
  bool isEquals(VgGradient other, [double delta = 1e-6]) {
    if (runtimeType != other.runtimeType) return false;

    if (this is VgGradientLinear) {
      final that = this as VgGradientLinear;
      other as VgGradientLinear;

      return that.from.isEquals(other.from, delta) &&
          that.to.isEquals(other.to, delta) &&
          that.colors!.isEquals(other.colors!, delta) &&
          that.offsets!.isEquals(other.offsets!, delta);
    }

    if (this is VgGradientRadial) {
      final that = this as VgGradientRadial;
      other as VgGradientRadial;

      return that.center.isEquals(other.center, delta) &&
          that.radius.isEquals(other.radius, delta) &&
          that.colors!.isEquals(other.colors!, delta) &&
          that.offsets!.isEquals(other.offsets!, delta);
    }
    return false;
  }
}

extension on int {
  VgStrokeCap get strokeCap => VgStrokeCap.values[this & 0xF];
  int withStrokeCap(VgStrokeCap cap) => this | cap.index;

  VgStrokeJoin get strokeJoin => VgStrokeJoin.values[(this >> 4) & 0xF];
  int withStrokeJoin(VgStrokeJoin join) => this | (join.index << 4);

  bool get haveFillColor => (this & (1 << 0)) != 0;
  int get withHaveFillColor => this | (1 << 0);
  bool get haveFillLinearShader => (this & (1 << 1)) != 0;
  int get withHaveFillLinearShader => this | (1 << 1);
  bool get haveFillRadialShader => (this & (1 << 2)) != 0;
  int get withHaveFillRadialShader => this | (1 << 2);

  bool get haveStrokeColor => (this & (1 << 3)) != 0;
  int get withHaveStrokeColor => this | (1 << 3);
  bool get haveStrokeLinearShader => (this & (1 << 4)) != 0;
  int get withHaveStrokeLinearShader => this | (1 << 4);
  bool get haveStrokeRadialShader => (this & (1 << 5)) != 0;
  int get withHaveStrokeRadialShader => this | (1 << 5);

  bool get haveStroke =>
      haveStrokeColor || haveStrokeLinearShader || haveStrokeRadialShader;
}

extension VgPaintXBinaryReader on BinaryReader {
  VgPaint readVgPaint() {
    final flags = readUint8();

    VgColor? fillColor;
    VgGradientLinear? fillLinear;
    VgGradientRadial? fillRadial;
    VgColor? strokeColor;
    VgGradientLinear? strokeLinear;
    VgGradientRadial? strokeRadial;
    double? strokeWidth;
    VgStrokeCap? strokeCap;
    VgStrokeJoin? strokeJoin;

    if (flags.haveFillColor) fillColor = readVgColor();
    if (flags.haveFillLinearShader) {
      fillLinear = readGradientLinear();
    }
    if (flags.haveFillRadialShader) {
      fillRadial = readVgGradientRadial();
    }
    if (flags.haveStrokeColor) strokeColor = readVgColor();
    if (flags.haveStrokeLinearShader) {
      strokeLinear = readGradientLinear();
    }
    if (flags.haveStrokeRadialShader) {
      strokeRadial = readVgGradientRadial();
    }

    if (flags.haveStroke) {
      strokeWidth = readFloat16();
      final strokeFlags = readUint8();
      strokeCap = strokeFlags.strokeCap;
      strokeJoin = strokeFlags.strokeJoin;
    }

    VgFill? fill;
    if (fillColor != null || fillLinear != null || fillRadial != null) {
      fill = VgFill(
        color: fillColor,
        shader: fillLinear ?? fillRadial,
      );
    }

    VgStroke? stroke;
    if (strokeColor != null || strokeLinear != null || strokeRadial != null) {
      stroke = VgStroke(
        color: strokeColor,
        shader: strokeLinear ?? strokeRadial,
        width: strokeWidth,
        cap: strokeCap,
        join: strokeJoin,
      );
    }

    return VgPaint(
      fill: fill,
      stroke: stroke,
    );
  }

  List<VgPaint> readVgPaints() => readList((i, reader) => reader.readVgPaint());
}

extension VgPaintXBinaryWriter on BinaryWriter {
  void writeVgPaints(List<VgPaint> d) {
    writeList(d, (e, i, writer) => writer.writeVgPaint(e));
  }

  void writeVgPaint(VgPaint d) {
    var flags = 0;

    final fill = d.fill;
    if (fill?.color != null) flags = flags.withHaveFillColor;
    if (fill?.shader is LinearGradient) flags = flags.withHaveFillLinearShader;
    if (fill?.shader is RadialGradient) flags = flags.withHaveFillRadialShader;
    final stroke = d.stroke;
    if (stroke != null) flags = flags.withHaveStrokeColor;
    if (stroke?.color != null) flags = flags.withHaveStrokeColor;
    if (stroke?.shader is LinearGradient) {
      flags = flags.withHaveStrokeLinearShader;
    }
    if (stroke?.shader is RadialGradient) {
      flags = flags.withHaveStrokeRadialShader;
    }
    writeUint8(flags);

    if (flags.haveFillColor) writeVgColor(fill!.color);
    if (flags.haveFillLinearShader) {
      writeVgGradientLinear(fill!.shader! as VgGradientLinear);
    }
    if (flags.haveFillRadialShader) {
      writeVgGradientRadial(fill!.shader! as VgGradientRadial);
    }
    if (flags.haveStrokeColor) writeVgColor(stroke!.color);
    if (flags.haveStrokeLinearShader) {
      writeVgGradientLinear(stroke!.shader! as VgGradientLinear);
    }
    if (flags.haveStrokeRadialShader) {
      writeVgGradientRadial(stroke!.shader! as VgGradientRadial);
    }

    if (flags.haveStroke) {
      stroke!;
      writeFloat16(stroke.width!);
      writeUint8(0.withStrokeCap(stroke.cap!).withStrokeJoin(stroke.join!));
    }
  }
}

/// Точка.
typedef VgPoint = Point;

extension VgDoubleX on double {
  bool isEquals(double other, [double delta = 1e-6]) {
    return (this - other).abs() < delta;
  }
}

extension VgListDoubleX on List<double> {
  bool isEquals(List<double> other, [double delta = 1e-6]) {
    if (length != other.length) return false;
    for (var i = 0; i < length; i++) {
      if (!this[i].isEquals(other[i], delta)) return false;
    }
    return true;
  }
}

extension VgPointX on VgPoint {
  bool isEquals(VgPoint other, [double delta = 1e-6]) {
    return x.isEquals(other.x, delta) && y.isEquals(other.y, delta);
  }
}

extension VgPointXBinaryReader on BinaryReader {
  /// Чтение точки.
  VgPoint readVgPoint() {
    return VgPoint(readFloat16(), readFloat16());
  }
}

extension VgPointXBinaryWriter on BinaryWriter {
  /// Запись точки.
  void writeVgPoint(VgPoint d) {
    writeFloat16(d.x);
    writeFloat16(d.y);
  }
}

/// Градиент линейный.
typedef VgGradientLinear = LinearGradient;

extension VgGradientLinearXBinaryReader on BinaryReader {
  /// Чтение градиента линейный.
  VgGradientLinear readGradientLinear() {
    final from = readVgPoint();
    final to = readVgPoint();

    final items = readVgGradientItems();
    return VgGradientLinear(
      id: '',
      from: from,
      to: to,
      colors: items.map((e) => e.color).toList(),
      offsets: items.map((e) => e.offset).toList(),
    );
  }
}

extension VgGradientLinearXBinaryWriter on BinaryWriter {
  /// Запись градиента линейный.
  void writeVgGradientLinear(VgGradientLinear d) {
    writeVgPoint(d.from);
    writeVgPoint(d.to);
    final colors = d.colors ?? [];
    final offsets = d.offsets ?? [];
    final items = List.generate(
      colors.length,
      (i) => VgGradientItem(color: colors[i], offset: offsets[i]),
    );
    writeVgGradientItems(items);
  }
}

/// Градиент радиальный.
typedef VgGradientRadial = RadialGradient;

extension VgGradientRadialXBinaryReader on BinaryReader {
  /// Чтение градиента радиальный.
  VgGradientRadial readVgGradientRadial() {
    final flags = readUint8();
    final center = readVgPoint();
    final radius = readFloat16();
    final focal = (flags & 1 != 0) ? readVgPoint() : null;
    final items = readVgGradientItems();
    return VgGradientRadial(
      id: '',
      center: center,
      radius: radius,
      focalPoint: focal,
      colors: items.map((e) => e.color).toList(),
      offsets: items.map((e) => e.offset).toList(),
    );
  }
}

extension VgGradientRadialXBinaryWriter on BinaryWriter {
  /// Запись градиента радиальный.
  void writeVgGradientRadial(VgGradientRadial d) {
    var flags = 0;
    if (d.focalPoint != null) flags |= 1;
    writeUint8(flags);
    writeVgPoint(d.center);
    writeFloat16(d.radius);
    if (d.focalPoint != null) writeVgPoint(d.focalPoint!);
    final colors = d.colors ?? [];
    final offsets = d.offsets ?? [];
    final items = List.generate(
      colors.length,
      (i) => VgGradientItem(color: colors[i], offset: offsets[i]),
    );
    writeVgGradientItems(items);
  }
}

/// Точка градиента.
final class VgGradientItem {
  /// Цвет.
  final VgColor color;

  /// Смещение.
  final double offset;

  const VgGradientItem({required this.color, required this.offset});
}

extension VgGradientItemXBinaryReader on BinaryReader {
  /// Чтение точки градиента.
  VgGradientItem readVgGradientItem() {
    final color = readVgColor();
    final offset = readFloat16();
    return VgGradientItem(color: color, offset: offset);
  }

  /// Чтение точек градиента.
  List<VgGradientItem> readVgGradientItems() =>
      readList((i, reader) => reader.readVgGradientItem());
}

extension VgGradientItemXBinaryWriter on BinaryWriter {
  /// Запись точки градиента.
  void writeVgGradientItem(VgGradientItem d) {
    writeVgColor(d.color);
    writeFloat16(d.offset);
  }

  /// Запись точек градиента.
  void writeVgGradientItems(List<VgGradientItem> d) {
    writeList(d, (e, i, writer) => writer.writeVgGradientItem(e));
  }
}

/// Вызов для рисования кистью.
final class VgDrawCallPaint extends VgDrawCall {
  /// Идентификатор пути.
  final int? pathId;

  /// Идентификатор кисти.
  final int paintId;

  const VgDrawCallPaint({
    required this.pathId,
    required this.paintId,
  }) : super(VgDrawCallType.paint);
}

extension VgDrawCallPaintXBinaryReader on VgBinaryReader {
  VgDrawCallPaint readVgDrawCallPaint() {
    final pathId = readUint16();
    final paintId = readUint16();
    return VgDrawCallPaint(
      pathId: pathId == 0xFFFF ? null : pathId,
      paintId: paintId,
    );
  }
}

extension VgDrawCallPaintXBinaryWriter on VgBinaryWriter {
  void writeVgDrawCallPaint(VgDrawCallPaint d) {
    writeUint16(d.pathId ?? 0xFFFF);
    writeUint16(d.paintId);
  }
}
