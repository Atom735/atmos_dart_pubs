import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';

import '../reader/atmos_x_file_reader.dart';

abstract class AtmosXFile implements XFile {
  const AtmosXFile();

  /// Расширение файла без точки.
  String get nameExt;

  /// Уникальный id файла внутри платформы.
  ///
  /// 0 - если не отсутствует.
  int get platformId;

  /// Размер файла в байтах. (null - если размер не известен заранее).
  int? get size;

  /// Чтений куска файла,
  /// _удобен для получения первых байт заголовка._
  Future<Uint8List> readChunk([int? start, int? end]);

  /// Начать чтение данных файла.
  Future<AtmosXFileReader> startRead([int? start, int? end]);
}
