import 'dart:async';
import 'dart:typed_data';

import 'package:atmos_local_fonts/atmos_local_fonts.dart';
import 'package:atmos_local_fonts_flutter/atmos_local_fonts_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Uint8List> _oneByte() async => Uint8List.fromList(<int>[1]);

LocalFontFace _arial({String postscriptName = 'ArialMT'}) {
  return LocalFontFace(
    family: 'Arial',
    fullName: 'Arial',
    postscriptName: postscriptName,
    style: 'Regular',
    readBytes: _oneByte,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('empty file list does not touch the engine', () async {
    await loadLocalFontFiles('Arial', const <Uint8List>[]);
  });

  test('isLoading wraps a successful query', () async {
    final fonts = FlutterLocalFonts(
      MemoryLocalFontSource(<LocalFontFace>[_arial()]),
    );
    addTearDown(fonts.dispose);
    final states = <bool>[];
    fonts.addListener(() => states.add(fonts.isLoading));

    final future = fonts.query();
    expect(fonts.isLoading, isTrue);

    await future;

    expect(fonts.isLoading, isFalse);
    expect(fonts.families, <String>['Arial']);
    expect(fonts.isLoaded(fonts.faces.single), isFalse);
    expect(states, <bool>[true, false]);
  });

  test('loadFamily registers bytes and sets isLoaded', () async {
    final loaded = <String, int>{};
    final fonts = FlutterLocalFonts(
      MemoryLocalFontSource(<LocalFontFace>[
        _arial(),
        _arial(postscriptName: 'Arial-BoldMT'),
      ]),
      loadFiles: (String family, List<Uint8List> files) async {
        loaded[family] = files.length;
      },
    );
    addTearDown(fonts.dispose);

    await fonts.query();
    await fonts.loadFamily('Arial');

    expect(loaded['Arial'], 2);
    expect(fonts.isFamilyLoaded('Arial'), isTrue);
    expect(fonts.isLoading, isFalse);
  });

  test('a second load of the same family does no work', () async {
    var calls = 0;
    final fonts = FlutterLocalFonts(
      MemoryLocalFontSource(<LocalFontFace>[_arial()]),
      loadFiles: (String family, List<Uint8List> files) async {
        calls++;
      },
    );
    addTearDown(fonts.dispose);

    await fonts.query();
    await fonts.loadFamily('Arial');
    await fonts.loadFamily('Arial');

    expect(calls, 1);
  });

  test('isLoading stays true until loadFiles finishes', () async {
    final gate = Completer<void>();
    final fonts = FlutterLocalFonts(
      MemoryLocalFontSource(<LocalFontFace>[_arial()]),
      loadFiles: (String family, List<Uint8List> files) => gate.future,
    );
    addTearDown(fonts.dispose);
    await fonts.query();

    final pending = fonts.loadFamily('Arial');
    await pumpEventQueue();

    expect(fonts.isLoading, isTrue);
    gate.complete();
    await pending;
    expect(fonts.isLoading, isFalse);
    expect(fonts.isLoaded(fonts.faces.single), isTrue);
  });

  test('loadFamily throws when the family was not queried', () async {
    final fonts = FlutterLocalFonts(
      MemoryLocalFontSource(const <LocalFontFace>[]),
    );
    addTearDown(fonts.dispose);

    await expectLater(
      fonts.loadFamily('Arial'),
      throwsA(isA<LocalFontsException>()),
    );
    expect(fonts.isLoading, isFalse);
  });

  test('unsupported query clears isLoading', () async {
    final fonts = FlutterLocalFonts(
      MemoryLocalFontSource(
        const <LocalFontFace>[],
        supported: false,
      ),
    );
    addTearDown(fonts.dispose);

    final future = fonts.query();
    expect(fonts.isLoading, isTrue);
    await expectLater(
      future,
      throwsA(isA<LocalFontsUnsupportedException>()),
    );
    expect(fonts.isLoading, isFalse);
  });
}
