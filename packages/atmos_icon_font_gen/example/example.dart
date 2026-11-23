import 'package:atmos_icon_font_gen/atmos_icon_font_gen.dart';

/// Builds a tiny icon font and prints the generated Dart library.
void main() {
  final result = generateIconFont(
    IconFontSpec(
      fontFamily: 'ExampleIcons',
      className: 'ExampleIcons',
      fontPackage: 'example_icons',
      icons: [
        IconGlyphSpec(
          name: 'box',
          codePoint: 0xE001,
          svgPath: 'M100 100H900V900H100Z',
        ),
      ],
    ),
  );

  // ignore: avoid_print
  print('TTF bytes: ${result.ttfBytes.length}');
  // ignore: avoid_print
  print(result.dartSource);
}
