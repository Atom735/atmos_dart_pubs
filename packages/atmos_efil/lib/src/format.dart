import 'dart:typed_data';

/// Container kind recognized by [identifyExecutable].
enum ExecutableFormat {
  /// ELF (`\x7FELF`).
  elf,

  /// MS-DOS `MZ`. A PE image is confirmed when the file is opened.
  pe,

  /// Mach-O or a fat Mach-O archive. Editing is not implemented.
  macho,

  /// None of the known magics.
  unknown,
}

/// Names the container at the start of [bytes] without parsing it.
ExecutableFormat identifyExecutable(Uint8List bytes) {
  if (_isElf(bytes)) return ExecutableFormat.elf;
  if (_isMachO(bytes)) return ExecutableFormat.macho;
  if (_isMz(bytes)) return ExecutableFormat.pe;
  return ExecutableFormat.unknown;
}

bool _isElf(Uint8List bytes) {
  return bytes.length >= 4 &&
      bytes[0] == 0x7F &&
      bytes[1] == 0x45 &&
      bytes[2] == 0x4C &&
      bytes[3] == 0x46;
}

bool _isMz(Uint8List bytes) {
  return bytes.length >= 2 && bytes[0] == 0x4D && bytes[1] == 0x5A;
}

bool _isMachO(Uint8List bytes) {
  if (bytes.length < 4) return false;
  final data = ByteData.sublistView(bytes);
  final magic = data.getUint32(0, Endian.little);
  if (magic == 0xFEEDFACE ||
      magic == 0xFEEDFACF ||
      magic == 0xCEFAEDFE ||
      magic == 0xCFFAEDFE) {
    return true;
  }
  // Fat Mach-O shares 0xCAFEBABE with Java class files. A fat header's
  // arch count is tiny; a class file's version word is not.
  if (magic != 0xCAFEBABE && magic != 0xBEBAFECA) return false;
  if (bytes.length < 8) return false;
  final bigFields = magic == 0xBEBAFECA;
  final count = data.getUint32(4, bigFields ? Endian.big : Endian.little);
  return count >= 1 && count <= 32;
}
