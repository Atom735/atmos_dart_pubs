/// Editor for ELF and PE executable images.
///
/// ## ENG
/// Parses a copy of the file, edits the entry point, and replaces a
/// section when the new bytes have the same length. Mach-O is identified
/// and not edited.
///
/// ## RU
/// Разбирает копию файла, меняет точку входа и заменяет секцию, если
/// новые байты той же длины. Mach-O узнаётся, но не редактируется.
library atmos_efil;

export 'src/elf_image.dart';
export 'src/format.dart';
export 'src/image.dart' hide requireInFile;
export 'src/open.dart';
export 'src/pe_image.dart';
