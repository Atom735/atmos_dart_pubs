import 'package:atmos_icon_font_gen/atmos_icon_font_gen.dart';
import 'package:test/test.dart';

void main() {
  test('generates ttf + dart from svg paths', () {
    final result = generateIconFont(
      IconFontSpec(
        fontFamily: 'DemoIcons',
        className: 'DemoIcons',
        fontPackage: 'demo_icons',
        icons: [
          IconGlyphSpec(
            name: 'square',
            codePoint: 0xE001,
            svgPath: 'M100 100H900V900H100Z',
          ),
          IconGlyphSpec(
            name: 'git-pull',
            codePoint: 0xE002,
            svgPath: 'M200 500L450 750L800 250',
          ),
        ],
      ),
    );

    expect(isTtf(result.ttfBytes), isTrue);
    expect(result.font.maxp.numGlyphs, 3);
    expect(result.font.cmap.glyphFor(0xE001), 1);
    expect(result.font.cmap.glyphFor(0xE002), 2);

    expect(result.dartSource, contains('abstract final class DemoIcons'));
    expect(result.dartSource, contains('static const IconData square'));
    expect(result.dartSource, contains('static const IconData gitPull'));
    expect(result.dartSource, contains('0xE001'));
    expect(result.dartSource, contains("fontPackage = 'demo_icons'"));
  });

  test('svg path square maps into font space', () {
    final contours = svgPathToContours(
      'M100 100H900V900H100Z',
      viewBoxHeight: 1000,
    );
    expect(contours, hasLength(1));
    final bounds = contourBounds(contours);
    expect(bounds.xMin, 100);
    expect(bounds.xMax, 900);
    // SVG y=100 → font y=900; SVG y=900 → font y=100
    expect(bounds.yMin, 100);
    expect(bounds.yMax, 900);
  });

  test('icon id to dart name', () {
    expect(iconIdToDartName('git-pull-request'), 'gitPullRequest');
    expect(iconIdToDartName('arrow_left'), 'arrowLeft');
    expect(iconIdToDartName('2x'), 'n2x');
  });
}
