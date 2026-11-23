import 'package:atmos_svg/atmos_svg.dart';

/// Extracts the first `<path d="…">` from an SVG document string.
///
/// Берёт первый `<path d="…">` из строки SVG-документа.
///
/// Throws [StateError] if no path with a `d` attribute is found.
String svgDocumentFirstPathD(String svgSource) {
  final doc = parseSvg(svgSource);
  final paths = doc.root.querySelectorAll('path');
  for (final el in paths) {
    final d = el.getAttribute('d');
    if (d != null && d.trim().isNotEmpty) {
      return d.trim();
    }
  }
  throw StateError('SVG has no <path> with a non-empty d attribute');
}
