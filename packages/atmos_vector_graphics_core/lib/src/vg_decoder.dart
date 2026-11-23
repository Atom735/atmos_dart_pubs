part of 'vector_graphics_core.dart';

/// Декодер векторной графики.
abstract class VgDecoderBase {
  /// Добавление ошибки.
  void addError(String message);

  /// Ошибки.
  final errors = StringBuffer();

  /// Список контуров.
  final paths = <VgPath>[];

  /// Список кистей.
  final paints = <VgPaint>[];

  /// Вызовы рисования.
  final drawCalls = <VgDrawCall>[];

  /// Ширина.
  double? width;

  /// Высота.
  double? height;

  int addPath(VgPath path) {
    for (var i = 0; i < paths.length; i++) {
      if (paths[i].isEquals(path, 0.5)) {
        return i;
      }
    }
    paths.add(path);
    return paths.length - 1;
  }

  int addPaint(VgPaint paint) {
    for (var i = 0; i < paints.length; i++) {
      if (paints[i].isEquals(paint, 0.5)) {
        return i;
      }
    }
    paints.add(paint);
    return paints.length - 1;
  }

  /// Кадр.
  VgContainerFrame get asFrame => VgContainerFrame(
        width: width!,
        height: height!,
        drawCalls: drawCalls,
      );

  /// Контейнер.
  VgContainer get asContainer => VgContainer(
        paths: paths,
        paints: paints,
        frames: [asFrame],
      );

  R run<R>(R Function() f) => runZoned(
        f,
        zoneValues: {
          VgDecoderBase: this,
        },
      );

  static VgDecoderBase? get it => Zone.current[VgDecoderBase] as VgDecoderBase?;
}

class VgContainerBase64Decoder extends Converter<String, VgContainer> {
  const VgContainerBase64Decoder();

  @override
  VgContainer convert(String input) {
    final reader = VgBinaryReader(const Base64Decoder().convert(input));
    return reader.readVgContainer();
  }
}

class VgContainerBase64Encoder extends Converter<VgContainer, String> {
  const VgContainerBase64Encoder();

  @override
  String convert(VgContainer input) {
    final writer = VgBinaryWriter();
    writer.writeVgContainer(input);
    return const Base64Encoder().convert(writer.takeBytes());
  }
}

class VgContainerBytesDecoder extends Converter<List<int>, VgContainer> {
  const VgContainerBytesDecoder();

  @override
  VgContainer convert(List<int> input) {
    final reader = VgBinaryReader(Uint8List.fromList(input));
    return reader.readVgContainer();
  }
}

class VgContainerBytesEncoder extends Converter<VgContainer, List<int>> {
  const VgContainerBytesEncoder();

  @override
  List<int> convert(VgContainer input) {
    final writer = VgBinaryWriter();
    writer.writeVgContainer(input);
    return writer.takeBytes();
  }
}
