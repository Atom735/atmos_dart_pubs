import 'dart:typed_data';

import 'package:atmos_efil/atmos_efil.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  test('magics identify elf, pe, macho, and unknown', () {
    expect(identifyExecutable(elf64()), ExecutableFormat.elf);
    expect(identifyExecutable(pe64()), ExecutableFormat.pe);
    expect(identifyExecutable(machoStub()), ExecutableFormat.macho);
    expect(
      identifyExecutable(Uint8List.fromList([1, 2, 3, 4])),
      ExecutableFormat.unknown,
    );
    final javaClass = Uint8List.fromList([
      0xCA, 0xFE, 0xBA, 0xBE, // magic shared with fat Mach-O
      0x00, 0x00, 0x00, 61, // class file version, not an arch count
    ]);
    expect(identifyExecutable(javaClass), ExecutableFormat.unknown);
  });

  test('Mach-O and unknown bytes are refused', () {
    expect(
      () => openExecutable(machoStub()),
      throwsA(isA<ExecutableUnsupportedException>()),
    );
    expect(
      () => openExecutable(Uint8List.fromList([1, 2, 3, 4])),
      throwsA(isA<ExecutableFormatException>()),
    );
  });
}
