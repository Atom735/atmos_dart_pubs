import 'dart:typed_data';

import 'package:atmos_efil/atmos_efil.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  test('ELF64 little-endian round-trips and edits in place', () {
    final original = elf64();
    final image = openExecutable(original) as ElfImage;
    expect(image.is64, isTrue);
    expect(image.machine, 62);
    expect(image.entryPoint, 0x400000);
    expect(image.toBytes(), original);

    final text = image.sectionByName('.text');
    expect(text, isNotNull);
    expect(text!.bytes, [0x90, 0x90, 0x90, 0x90]);
    expect(text.virtualAddress, 0x400000);

    image.entryPoint = 0x400001;
    text.writeBytes([0xC3, 0x90, 0x90, 0x90]);
    final edited = image.toBytes();
    expect(ByteData.sublistView(edited).getUint64(24, Endian.little), 0x400001);
    expect(edited.sublist(64, 68), [0xC3, 0x90, 0x90, 0x90]);
    expect(
      () => text.writeBytes([0x90]),
      throwsA(isA<ExecutableEditException>()),
    );
  });

  test('ELF64 big-endian and ELF32 use the same section names', () {
    final big = openExecutable(elf64(endian: Endian.big)) as ElfImage;
    expect(big.endian, Endian.big);
    expect(big.sectionByName('.text')!.fileSize, 4);
    expect(big.sectionByName('.shstrtab'), isNotNull);

    final small = openExecutable(elf32()) as ElfImage;
    expect(small.is64, isFalse);
    expect(small.entryPoint, 0x8048000);
    small.entryPoint = 0x8048001;
    expect(small.entryPoint, 0x8048001);
  });

  test('NOBITS has no file bytes and e_shnum 0 still names sections', () {
    final nobits = openExecutable(elf64(textType: 8)) as ElfImage;
    final empty = nobits.sectionByName('.text');
    expect(empty, isNotNull);
    expect(empty!.fileSize, 0);
    expect(empty.bytes, isEmpty);
    expect(empty.virtualSize, 4);

    final extended = openExecutable(elf64(extended: true)) as ElfImage;
    expect(extended.sectionByName('.text')!.bytes, [0x90, 0x90, 0x90, 0x90]);
    expect(extended.sections.first.fileSize, 0);
    expect(extended.toBytes(), elf64(extended: true));
  });
}
