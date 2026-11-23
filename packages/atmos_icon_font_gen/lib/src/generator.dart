import 'dart:typed_data';

import 'package:atmos_ttf/atmos_ttf.dart';

import 'dart_emitter.dart';
import 'spec.dart';
import 'svg_path.dart';

/// Builds a TrueType icon font and Dart `IconData` source from [spec].
///
/// Собирает TrueType-шрифт иконок и Dart-исходник `IconData` из [spec].
IconFontResult generateIconFont(IconFontSpec spec) {
  if (spec.icons.isEmpty) {
    throw ArgumentError('IconFontSpec.icons must not be empty');
  }

  final viewBoxHeight = spec.svgViewBoxHeight ?? spec.unitsPerEm.toDouble();
  final builder = TtfFontBuilder(
    familyName: spec.fontFamily,
    unitsPerEm: spec.unitsPerEm,
  )..addEmptyGlyph(advanceWidth: spec.unitsPerEm);

  final usedCodePoints = <int>{};
  for (final icon in spec.icons) {
    if (!usedCodePoints.add(icon.codePoint)) {
      throw ArgumentError(
        'Duplicate code point 0x${icon.codePoint.toRadixString(16)} '
        'for icon "${icon.name}".',
      );
    }
    final contours = icon.contours ??
        svgPathToContours(
          icon.svgPath!,
          viewBoxHeight: viewBoxHeight,
        );
    final glyph = TtfGlyph.simple(
      advanceWidth: icon.advanceWidth ?? spec.unitsPerEm,
      leftSideBearing: icon.leftSideBearing ?? 0,
      contours: contours,
    );
    builder.addGlyph(glyph, codePoint: icon.codePoint);
  }

  final font = builder.build();
  final ttfBytes = font.toBytes();
  final dartSource = emitIconDataLibrary(spec);

  return IconFontResult(
    ttfBytes: ttfBytes,
    dartSource: dartSource,
    font: openTtf(Uint8List.fromList(ttfBytes)),
  );
}
