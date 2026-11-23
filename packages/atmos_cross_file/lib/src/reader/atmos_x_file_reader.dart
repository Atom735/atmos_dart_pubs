import '../x_files/atmos_x_file.dart';

abstract class AtmosXFileReader<T extends AtmosXFile> {
  /// Читаемый файл.
  final AtmosXFile file;

  /// Позиция первых байт для чтения.
  final int start;

  /// Позиция последних байт для чтения (null - конец файла).
  final int? end;

  const AtmosXFileReader({
    required this.file,
    this.start = 0,
    this.end,
  });

  int get platformId;
}
