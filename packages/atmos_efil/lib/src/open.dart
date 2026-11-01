import 'dart:typed_data';

import 'elf_image.dart';
import 'format.dart';
import 'image.dart';
import 'pe_image.dart';

/// Parses [bytes] as ELF or PE.
///
/// Mach-O is recognized and rejected: this version does not edit it.
/// Any other magic throws [ExecutableFormatException].
ExecutableImage openExecutable(Uint8List bytes) {
  switch (identifyExecutable(bytes)) {
    case ExecutableFormat.elf:
      return ElfImage.parse(bytes);
    case ExecutableFormat.pe:
      return PeImage.parse(bytes);
    case ExecutableFormat.macho:
      throw ExecutableUnsupportedException(
        ExecutableFormat.macho,
        'Mach-O editing is not implemented.',
      );
    case ExecutableFormat.unknown:
      throw ExecutableFormatException('Unrecognized executable image.');
  }
}
