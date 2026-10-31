import 'package:atmos_local_fonts/atmos_local_fonts.dart';
import 'package:atmos_local_fonts_web/atmos_local_fonts_web.dart';
import 'package:test/test.dart';

void main() {
  test('web source is unsupported on VM', () {
    const source = WebLocalFontSource();
    expect(source.isSupported, isFalse);
  });

  test('query throws when unsupported', () {
    expect(
      const WebLocalFontSource().query(),
      throwsA(isA<LocalFontsUnsupportedException>()),
    );
  });
}
