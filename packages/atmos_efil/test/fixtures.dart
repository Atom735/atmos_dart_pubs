import 'dart:typed_data';

Uint8List elf64({
  Endian endian = Endian.little,
  int entry = 0x400000,
  List<int> text = const [0x90, 0x90, 0x90, 0x90],
  int textType = 1,
  bool extended = false,
}) {
  return _elf(
    is64: true,
    elfClass: 2,
    endian: endian,
    machine: 62,
    entry: entry,
    text: text,
    textType: textType,
    extended: extended,
  );
}

Uint8List elf32({
  int entry = 0x8048000,
  List<int> text = const [0x90, 0x90, 0x90, 0x90],
}) {
  return _elf(
    is64: false,
    elfClass: 1,
    endian: Endian.little,
    machine: 3,
    entry: entry,
    text: text,
  );
}

Uint8List _elf({
  required bool is64,
  required int elfClass,
  required Endian endian,
  required int machine,
  required int entry,
  required List<int> text,
  int textType = 1,
  bool extended = false,
}) {
  final headerSize = is64 ? 64 : 52;
  final textAt = headerSize;
  final stringsAt = textAt + text.length;
  final strings = <int>[
    0,
    ...'.text'.codeUnits,
    0,
    ...'.shstrtab'.codeUnits,
    0,
  ];
  final sectionsAt = stringsAt + strings.length;
  final sectionSize = is64 ? 64 : 40;
  final bytes = Uint8List(sectionsAt + 3 * sectionSize);
  final data = ByteData.sublistView(bytes);
  bytes[0] = 0x7F;
  bytes[1] = 0x45;
  bytes[2] = 0x4C;
  bytes[3] = 0x46;
  bytes[4] = elfClass;
  bytes[5] = endian == Endian.little ? 1 : 2;
  bytes[6] = 1;
  bytes.setRange(textAt, textAt + text.length, text);
  bytes.setRange(stringsAt, stringsAt + strings.length, strings);

  void u16(int offset, int value) => data.setUint16(offset, value, endian);
  void u32(int offset, int value) => data.setUint32(offset, value, endian);
  void u64(int offset, int value) => data.setUint64(offset, value, endian);

  u16(16, 2);
  u16(18, machine);
  u32(20, 1);
  if (is64) {
    u64(24, entry);
    u64(40, sectionsAt);
    u16(52, headerSize);
    u16(58, sectionSize);
    u16(60, 3);
    u16(62, 2);
  } else {
    u32(24, entry);
    u32(32, sectionsAt);
    u16(40, headerSize);
    u16(46, sectionSize);
    u16(48, 3);
    u16(50, 2);
  }
  _elfSection(
    data,
    endian,
    is64: is64,
    at: sectionsAt + sectionSize,
    name: 1,
    type: textType,
    flags: 6,
    address: entry,
    offset: textAt,
    size: text.length,
  );
  _elfSection(
    data,
    endian,
    is64: is64,
    at: sectionsAt + 2 * sectionSize,
    name: 7,
    type: 3,
    flags: 0,
    address: 0,
    offset: stringsAt,
    size: strings.length,
  );
  if (extended) {
    if (is64) {
      u16(60, 0);
      u64(sectionsAt + 32, 3);
    } else {
      u16(48, 0);
      u32(sectionsAt + 20, 3);
    }
  }
  return bytes;
}

void _elfSection(
  ByteData data,
  Endian endian, {
  required bool is64,
  required int at,
  required int name,
  required int type,
  required int flags,
  required int address,
  required int offset,
  required int size,
}) {
  data.setUint32(at, name, endian);
  data.setUint32(at + 4, type, endian);
  if (is64) {
    data
      ..setUint64(at + 8, flags, endian)
      ..setUint64(at + 16, address, endian)
      ..setUint64(at + 24, offset, endian)
      ..setUint64(at + 32, size, endian);
  } else {
    data
      ..setUint32(at + 8, flags, endian)
      ..setUint32(at + 12, address, endian)
      ..setUint32(at + 16, offset, endian)
      ..setUint32(at + 20, size, endian);
  }
}

Uint8List pe64({
  int entry = 0x1000,
  List<int> text = const [0xC3, 0x90, 0x90, 0x90],
}) {
  const lfanew = 0x80;
  const optionalSize = 112;
  const table = lfanew + 24 + optionalSize;
  const raw = 0x200;
  final bytes = Uint8List(raw + text.length);
  final data = ByteData.sublistView(bytes);
  bytes[0] = 0x4D;
  bytes[1] = 0x5A;
  data.setUint32(0x3C, lfanew, Endian.little);
  data.setUint32(lfanew, 0x00004550, Endian.little);
  data.setUint16(lfanew + 4, 0x8664, Endian.little);
  data.setUint16(lfanew + 6, 1, Endian.little);
  data.setUint16(lfanew + 20, optionalSize, Endian.little);
  const optional = lfanew + 24;
  data.setUint16(optional, 0x20B, Endian.little);
  data.setUint32(optional + 16, entry, Endian.little);
  data.setUint16(optional + 68, 3, Endian.little);
  bytes.setRange(table, table + 8, [0x2E, 0x74, 0x65, 0x78, 0x74, 0, 0, 0]);
  data
    ..setUint32(table + 8, text.length, Endian.little)
    ..setUint32(table + 12, entry, Endian.little)
    ..setUint32(table + 16, text.length, Endian.little)
    ..setUint32(table + 20, raw, Endian.little)
    ..setUint32(table + 36, 0x60000020, Endian.little);
  bytes.setRange(raw, raw + text.length, text);
  return bytes;
}

Uint8List machoStub() {
  final bytes = Uint8List(4);
  ByteData.sublistView(bytes).setUint32(0, 0xFEEDFACF, Endian.little);
  return bytes;
}
