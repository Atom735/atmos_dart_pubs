import 'package:atmos_vsc_theme/atmos_vsc_theme.dart';
import 'package:test/test.dart';

void main() {
  group('VscColor parse', () {
    test('parses #RGB and #RRGGBB', () {
      expect(VscColor.parse('#1e1'), const VscColor(0x11, 0xEE, 0x11));
      expect(
        VscColor.parse('#1E1E1E'),
        const VscColor(0x1E, 0x1E, 0x1E),
      );
    });

    test('parses alpha forms', () {
      expect(
        VscColor.parse('#ADD6FF26'),
        const VscColor(0xAD, 0xD6, 0xFF, 0x26),
      );
      expect(VscColor.parse('#0000'), VscColor.transparent);
    });

    test('toHex round-trip', () {
      const c = VscColor(0x1F, 0x1F, 0x1F);
      expect(VscColor.parse(c.toHex()), c);
      const withAlpha = VscColor(0xAD, 0xD6, 0xFF, 0x26);
      expect(VscColor.parse(withAlpha.toHex()), withAlpha);
    });

    test('luminance marks dark editor bg', () {
      expect(VscColor.parse('#1E1E1E').isDark, isTrue);
      expect(VscColor.parse('#FFFFFF').isDark, isFalse);
    });
  });

  group('VscColor alpha helpers', () {
    test('withAlpha / withOpacity / opaque', () {
      const c = VscColor(10, 20, 30);
      expect(c.withAlpha(128).alpha, 128);
      expect(c.withOpacity(0.5).alpha, 128);
      expect(c.withAlpha(0).isTransparent, isTrue);
      expect(c.isOpaque, isTrue);
      expect(c.withAlpha(100).opaque, c);
    });
  });

  group('VscColor blendOver', () {
    test('opaque source unchanged', () {
      const fg = VscColor(255, 0, 0);
      const bg = VscColor(0, 0, 255);
      expect(fg.blendOver(bg), fg);
    });

    test('transparent source yields background', () {
      expect(VscColor.transparent.blendOver(VscColor.white), VscColor.white);
    });

    test('50% black over white is mid gray', () {
      final blended = VscColor.black.withOpacity(0.5).blendOver(VscColor.white);
      expect(blended.isOpaque, isTrue);
      expect(blended.red, closeTo(128, 1));
      expect(blended.green, closeTo(128, 1));
      expect(blended.blue, closeTo(128, 1));
    });

    test('theme-like selection over editor background', () {
      final bg = VscColor.parse('#1F1F1F');
      final selection = VscColor.parse('#26477866');
      final out = selection.blendOver(bg);
      expect(out.isOpaque, isTrue);
      expect(out.isDark, isTrue);
      // Must differ from both pure bg and fully opaque selection RGB.
      expect(out, isNot(bg));
      expect(out, isNot(selection.opaque));
    });
  });

  group('VscColor mix / lighten / darken', () {
    test('lerp endpoints and midpoint', () {
      expect(VscColor.lerp(VscColor.black, VscColor.white, 0), VscColor.black);
      expect(VscColor.lerp(VscColor.black, VscColor.white, 1), VscColor.white);
      final mid = VscColor.lerp(VscColor.black, VscColor.white, 0.5);
      expect(mid.red, 128);
    });

    test('mix aliases lerp', () {
      expect(
        VscColor.black.mix(VscColor.white, 0.25),
        VscColor.lerp(VscColor.black, VscColor.white, 0.25),
      );
    });

    test('lighten / darken', () {
      const base = VscColor(100, 100, 100);
      expect(base.lighten(0.2).red, greaterThan(base.red));
      expect(base.darken(0.2).red, lessThan(base.red));
    });
  });

  group('VscColor contrast', () {
    test('contrastRatio white/black is 21', () {
      expect(
        VscColor.white.contrastRatio(VscColor.black),
        closeTo(21.0, 0.01),
      );
    });

    test('onContrast picks readable foreground', () {
      expect(VscColor.black.onContrast(), VscColor.white);
      expect(VscColor.white.onContrast(), VscColor.black);
      final darkBg = VscColor.parse('#1F1F1F');
      expect(darkBg.onContrast(), VscColor.white);
    });
  });
}
