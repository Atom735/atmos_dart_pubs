/// Icon font + Dart `IconData` code generator on top of `atmos_ttf`.
///
/// ## ENG
/// Turn named glyphs (contours or SVG paths) into a TrueType file and a
/// tree-shake-friendly Dart library of `IconData` constants.
///
/// ## RU
/// Превращает именованные глифы (контуры или SVG path) в файл TrueType и
/// Dart-библиотеку констант `IconData`, удобную для tree-shaking.
library atmos_icon_font_gen;

export 'package:atmos_ttf/atmos_ttf.dart'
    show TtfContour, TtfFont, TtfGlyph, TtfPoint, isTtf, openTtf;

export 'src/dart_emitter.dart';
export 'src/generator.dart';
export 'src/names.dart';
export 'src/spec.dart';
export 'src/svg_file.dart';
export 'src/svg_path.dart';
