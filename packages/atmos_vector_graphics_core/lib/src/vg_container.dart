part of 'vector_graphics_core.dart';

/// Контейнер для векторной графики.
final class VgContainer {
  /// Контуры.
  final List<VgPath> paths;

  /// Кисти.
  final List<VgPaint> paints;

  /// Кадры.
  final List<VgContainerFrame> frames;

  const VgContainer({
    required this.paths,
    required this.paints,
    required this.frames,
  });

  VgContainer.empty()
      : paths = [],
        paints = [],
        frames = [];

  factory VgContainer.fromBase64(String base64) {
    return const VgContainerBase64Decoder().convert(base64);
  }

  String toBase64() {
    return const VgContainerBase64Encoder().convert(this);
  }

  factory VgContainer.fromBytes(List<int> bytes) {
    return const VgContainerBytesDecoder().convert(bytes);
  }

  List<int> toBytes() {
    return const VgContainerBytesEncoder().convert(this);
  }
}

extension VgContainerXBinaryReader on VgBinaryReader {
  VgContainer readVgContainer() {
    final magic = readString(size: 4);
    if (magic != 'GVG3') {
      throw Exception('Invalid magic number: $magic');
    }
    final version = readUint16();
    if (version != 3) {
      throw Exception('Invalid version: $version');
    }
    return VgContainer(
      paths: readVgPaths(),
      paints: readVgPaints(),
      frames: readVgContainerFrames(),
    );
  }
}

extension VgContainerXBinaryWriter on VgBinaryWriter {
  void writeVgContainer(VgContainer d) {
    writeString('GVG3', size: 4);
    writeUint16(3);
    writeVgPaths(d.paths);
    writeVgPaints(d.paints);
    writeVgContainerFrames(d.frames);
  }
}

/// Контейнер кадра векторной графики.
final class VgContainerFrame {
  /// Ширина.
  final double width;

  /// Высота.
  final double height;

  /// Вызовы для рисования.
  final List<VgDrawCall> drawCalls;

  const VgContainerFrame({
    required this.width,
    required this.height,
    required this.drawCalls,
  });
}

extension VgContainerFrameXBinaryReader on VgBinaryReader {
  VgContainerFrame readVgContainerFrame() {
    return VgContainerFrame(
      width: readUint16().toDouble(),
      height: readUint16().toDouble(),
      drawCalls: readVgDrawCalls(),
    );
  }

  List<VgContainerFrame> readVgContainerFrames() =>
      readList((i, reader) => reader.readVgContainerFrame());
}

extension VgContainerFrameXBinaryWriter on VgBinaryWriter {
  void writeVgContainerFrames(List<VgContainerFrame> d) {
    writeList(d, (e, i, writer) => writer.writeVgContainerFrame(e));
  }

  void writeVgContainerFrame(VgContainerFrame d) {
    writeUint16(d.width.toInt());
    writeUint16(d.height.toInt());
    writeVgDrawCalls(d.drawCalls);
  }
}
