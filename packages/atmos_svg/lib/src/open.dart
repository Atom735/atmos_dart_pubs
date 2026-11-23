import 'document.dart';
import 'element.dart';

/// Parses [source] as an SVG document.
///
/// Разбирает [source] как SVG-документ.
SvgDocument parseSvg(String source) => SvgDocument.parse(source);

/// Builds a minimal empty `<svg>` document.
///
/// Собирает минимальный пустой документ `<svg>`.
SvgDocument createSvg({
  String? viewBox,
  String? width,
  String? height,
  String xmlns = 'http://www.w3.org/2000/svg',
}) {
  final root = SvgElement(
    'svg',
    attributes: {
      'xmlns': xmlns,
      if (viewBox != null) 'viewBox': viewBox,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
    },
  );
  return SvgDocument(root);
}
