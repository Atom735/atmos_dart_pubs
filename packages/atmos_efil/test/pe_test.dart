import 'dart:typed_data';

import 'package:atmos_efil/atmos_efil.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  test('PE32+ reads the entry RVA and .text', () {
    final original = pe64();
    final image = openExecutable(original) as PeImage;
    expect(image.is64, isTrue);
    expect(image.machine, 0x8664);
    expect(image.subsystem, 3);
    expect(image.entryPoint, 0x1000);
    expect(image.toBytes(), original);

    final found = image.sectionByName('.text');
    expect(found, isNotNull);
    final text = found!;
    expect(text.bytes, [0xC3, 0x90, 0x90, 0x90]);
    expect(text.flags, 0x60000020);

    image.entryPoint = 0x1001;
    text.writeBytes([0x90, 0x90, 0x90, 0xC3]);
    final edited = image.toBytes();
    final data = ByteData.sublistView(edited);
    expect(data.getUint32(0x80 + 24 + 16, Endian.little), 0x1001);
    expect(edited.sublist(0x200, 0x204), [0x90, 0x90, 0x90, 0xC3]);
    expect(
      () => image.entryPoint = 1 << 32,
      throwsA(isA<ExecutableEditException>()),
    );
  });

  test('an MZ file without a PE signature is rejected', () {
    final bytes = Uint8List(0x40);
    bytes[0] = 0x4D;
    bytes[1] = 0x5A;
    ByteData.sublistView(bytes).setUint32(0x3C, 0x80, Endian.little);
    expect(
      () => openExecutable(bytes),
      throwsA(isA<ExecutableFormatException>()),
    );
  });

  test('PE32 magic is distinct from PE32+', () {
    final bytes = pe64();
    ByteData.sublistView(bytes).setUint16(0x80 + 24, 0x10B, Endian.little);
    final image = openExecutable(bytes) as PeImage;
    expect(image.is64, isFalse);
    expect(image.entryPoint, 0x1000);
    expect(image.subsystem, 3);
    expect(
      image.sectionByName('.text')!.bytes,
      [0xC3, 0x90, 0x90, 0x90],
    );
  });
}
