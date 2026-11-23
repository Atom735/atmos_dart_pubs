part of 'vector_graphics_flutter.dart';

/// Convenience widget that paints a [VgContainer] with CustomPaint.
///
/// Удобный виджет, рисующий [VgContainer] через CustomPaint.
class VgWidget extends flt.StatelessWidget {
  /// Creates a widget for [container].
  ///
  /// Создаёт виджет для [container].
  const VgWidget({
    super.key,
    required this.container,
    this.frameIndex = 0,
    this.width,
    this.height,
    this.fit = flt.BoxFit.contain,
    this.withoutClip = false,
    this.onlyWithFill = false,
    this.onlyWithStroke = false,
    this.whiteOnly = false,
  });

  /// Vector graphics to paint.
  final VgContainer container;

  /// Frame index inside [container].
  final int frameIndex;

  /// Optional layout width.
  final double? width;

  /// Optional layout height.
  final double? height;

  /// How to inscribe the graphic into the layout box.
  final flt.BoxFit fit;

  /// Forwarded to [VgContainerXFlutter.renderToCanvas].
  final bool withoutClip;

  /// Forwarded to [VgContainerXFlutter.renderToCanvas].
  final bool onlyWithFill;

  /// Forwarded to [VgContainerXFlutter.renderToCanvas].
  final bool onlyWithStroke;

  /// Forwarded to [VgContainerXFlutter.renderToCanvas].
  final bool whiteOnly;

  @override
  flt.Widget build(flt.BuildContext context) {
    final intrinsic = container.getSize(frameIndex);
    return flt.SizedBox(
      width: width ?? intrinsic.width,
      height: height ?? intrinsic.height,
      child: flt.FittedBox(
        fit: fit,
        child: flt.SizedBox(
          width: intrinsic.width,
          height: intrinsic.height,
          child: flt.CustomPaint(
            size: intrinsic,
            painter: VgFlutterCustomPainter(
              vcg: container,
              frameIndex: frameIndex,
              withoutClip: withoutClip,
              onlyWithFill: onlyWithFill,
              onlyWithStroke: onlyWithStroke,
              whiteOnly: whiteOnly,
            ),
          ),
        ),
      ),
    );
  }
}
