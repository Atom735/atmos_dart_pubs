part of 'vector_graphics_core.dart';

extension on int {
  bool get haveScale => (this & (1 << 0)) != 0;
  int get withHaveScale => this | (1 << 0);
  bool get haveTranslate => (this & (1 << 1)) != 0;
  int get withHaveTranslate => this | (1 << 1);
}

/// Вызов для рисования начала группы.
final class VgDrawCallGroupBegin extends VgDrawCall {
  /// Масштаб по оси X.
  final double? scaleX;

  /// Масштаб по оси Y.
  final double? scaleY;

  /// Смещение по оси X.
  final double? translateX;

  /// Смещение по оси Y.
  final double? translateY;

  bool get haveScale => scaleX != null || scaleY != null;
  bool get haveTranslate => translateX != null || translateY != null;

  const VgDrawCallGroupBegin({
    required this.scaleX,
    required this.scaleY,
    required this.translateX,
    required this.translateY,
  }) : super(VgDrawCallType.groupBegin);
}

/// Вызов для рисования конца группы.
final class VgDrawCallGroupEnd extends VgDrawCall {
  const VgDrawCallGroupEnd() : super(VgDrawCallType.groupEnd);
}

extension VgGroupXBinaryReader on BinaryReader {
  VgDrawCallGroupBegin readVgDrawCallGroupBegin() {
    final flags = readUint8();
    double? scaleX;
    double? scaleY;
    double? translateX;
    double? translateY;
    if (flags.haveScale) {
      scaleX = readFloat16();
      scaleY = readFloat16();
    }
    if (flags.haveTranslate) {
      translateX = readFloat16();
      translateY = readFloat16();
    }
    return VgDrawCallGroupBegin(
      scaleX: scaleX,
      scaleY: scaleY,
      translateX: translateX,
      translateY: translateY,
    );
  }

  VgDrawCallGroupEnd readVgDrawCallGroupEnd() {
    return const VgDrawCallGroupEnd();
  }
}

extension VgGroupXBinaryWriter on BinaryWriter {
  void writeVgDrawCallGroupBegin(VgDrawCallGroupBegin d) {
    var flags = 0;
    if (d.haveScale) flags = flags.withHaveScale;
    if (d.haveTranslate) flags = flags.withHaveTranslate;
    writeUint8(flags);
    if (d.haveScale) {
      writeFloat16(d.scaleX ?? 1);
      writeFloat16(d.scaleY ?? 1);
    }
    if (d.haveTranslate) {
      writeFloat16(d.translateX ?? 0);
      writeFloat16(d.translateY ?? 0);
    }
  }

  void writeVgDrawCallGroupEnd(VgDrawCallGroupEnd d) {}
}
