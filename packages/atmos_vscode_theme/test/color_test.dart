import 'package:atmos_vscode_theme/atmos_vscode_theme.dart';
import 'package:test/test.dart';

void main() {
  group('VscodeColor', () {
    test('parses #RGB and #RRGGBB', () {
      expect(VscodeColor.parse('#1e1'), const VscodeColor(0x11, 0xEE, 0x11));
      expect(
        VscodeColor.parse('#1E1E1E'),
        const VscodeColor(0x1E, 0x1E, 0x1E),
      );
    });

    test('parses alpha forms', () {
      expect(
        VscodeColor.parse('#ADD6FF26'),
        const VscodeColor(0xAD, 0xD6, 0xFF, 0x26),
      );
      expect(VscodeColor.parse('#0000'), const VscodeColor(0, 0, 0, 0));
    });

    test('toHex round-trip', () {
      const c = VscodeColor(0x1F, 0x1F, 0x1F);
      expect(VscodeColor.parse(c.toHex()), c);
    });

    test('luminance marks dark editor bg', () {
      expect(VscodeColor.parse('#1E1E1E').isDark, isTrue);
      expect(VscodeColor.parse('#FFFFFF').isDark, isFalse);
    });
  });
}
