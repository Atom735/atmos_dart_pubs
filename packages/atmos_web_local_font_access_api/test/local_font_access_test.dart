import 'package:atmos_web_local_font_access_api/atmos_web_local_font_access_api.dart';
import 'package:test/test.dart';

void main() {
  test('Local Font Access API is unsupported on VM', () {
    expect(isLocalFontAccessApiSupported, isFalse);
  });

  test('queryLocalFonts throws when unsupported', () {
    expect(
      queryLocalFonts(),
      throwsA(isA<LocalFontAccessException>()),
    );
  });

  test('query options keep the PostScript filter', () {
    const options = QueryLocalFontsOptions(
      postscriptNames: <String>['ArialMT'],
    );
    expect(options.postscriptNames, <String>['ArialMT']);
  });
}
