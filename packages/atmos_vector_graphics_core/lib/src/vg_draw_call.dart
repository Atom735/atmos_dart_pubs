part of 'vector_graphics_core.dart';

/// Тип вызова для рисования.
enum VgDrawCallType {
  /// Рисование.
  paint,

  /// Начало группы.
  groupBegin,

  /// Конец группы.
  groupEnd,

  /// Вырезание по контуру.
  clipPath,
  ;
}

/// Вызов для рисования.
sealed class VgDrawCall {
  /// Тип вызова.
  final VgDrawCallType type;

  const VgDrawCall(this.type);
}

extension VgDrawCallXBinaryReader on BinaryReader {
  VgDrawCall readVgDrawCall() {
    final type = VgDrawCallType.values[readUint8()];
    switch (type) {
      case VgDrawCallType.paint:
        return readVgDrawCallPaint();
      case VgDrawCallType.groupBegin:
        return readVgDrawCallGroupBegin();
      case VgDrawCallType.groupEnd:
        return readVgDrawCallGroupEnd();
      case VgDrawCallType.clipPath:
        return readVgDrawCallClipPath();
    }
  }

  List<VgDrawCall> readVgDrawCalls() =>
      readList((i, reader) => reader.readVgDrawCall());
}

extension VgDrawCallXBinaryWriter on BinaryWriter {
  void writeVgDrawCalls(List<VgDrawCall> d) {
    writeList(d, (e, i, writer) => writer.writeVgDrawCall(e));
  }

  void writeVgDrawCall(VgDrawCall d) {
    writeUint8(d.type.index);
    switch (d.type) {
      case VgDrawCallType.paint:
        writeVgDrawCallPaint(d as VgDrawCallPaint);
      case VgDrawCallType.groupBegin:
        writeVgDrawCallGroupBegin(d as VgDrawCallGroupBegin);
      case VgDrawCallType.groupEnd:
        writeVgDrawCallGroupEnd(d as VgDrawCallGroupEnd);
      case VgDrawCallType.clipPath:
        writeVgDrawCallClipPath(d as VgDrawCallClipPath);
    }
  }
}
