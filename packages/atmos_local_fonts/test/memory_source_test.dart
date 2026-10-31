import 'dart:typed_data';

import 'package:atmos_local_fonts/atmos_local_fonts.dart';
import 'package:test/test.dart';

Future<Uint8List> _oneByte() async => Uint8List.fromList(<int>[1]);

LocalFontFace _face(String family, String postscriptName) {
  return LocalFontFace(
    family: family,
    fullName: family,
    postscriptName: postscriptName,
    style: 'Regular',
    readBytes: _oneByte,
  );
}

void main() {
  test('query returns every face', () async {
    final arial = _face('Arial', 'ArialMT');
    final source = MemoryLocalFontSource(<LocalFontFace>[arial]);

    final faces = await source.query();

    expect(faces, <LocalFontFace>[arial]);
    expect(await faces.single.readBytes(), Uint8List.fromList(<int>[1]));
  });

  test('query filters by PostScript name', () async {
    final source = MemoryLocalFontSource(<LocalFontFace>[
      _face('Arial', 'ArialMT'),
      _face('Arial', 'Arial-BoldMT'),
    ]);

    final faces = await source.query(
      postscriptNames: <String>['Arial-BoldMT'],
    );

    expect(faces.single.postscriptName, 'Arial-BoldMT');
  });

  test('empty PostScript filter returns no faces', () async {
    final source = MemoryLocalFontSource(<LocalFontFace>[
      _face('Arial', 'ArialMT'),
    ]);

    final faces = await source.query(postscriptNames: const <String>[]);

    expect(faces, isEmpty);
  });

  test('unsupported source throws', () {
    final source = MemoryLocalFontSource(
      const <LocalFontFace>[],
      supported: false,
    );

    expect(source.isSupported, isFalse);
    expect(
      source.query(),
      throwsA(isA<LocalFontsUnsupportedException>()),
    );
  });
}
