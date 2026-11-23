import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../reader/atmos_x_file_reader_fs.dart';
import 'atmos_x_file.dart';

class AtmosXFileFS extends AtmosXFile {
  @override
  final String path;

  @override
  final String? mimeType;

  AtmosXFileFS({
    required this.path,
    this.mimeType,
  });

  late final file = File(path);

  @override
  late final String nameExt = p.extension(path).replaceAll('.', '');

  @override
  late final String name = p.basename(path);

  @override
  int get platformId => 0;

  @override
  late final int size = file.lengthSync();

  @override
  Future<DateTime> lastModified() => Future.value(file.lastModifiedSync());

  @override
  Future<int> length() => file.length();

  @override
  Stream<Uint8List> openRead([int? start, int? end]) =>
      file.openRead(start, end).cast();

  @override
  Future<Uint8List> readAsBytes() => file.readAsBytes();

  @override
  Future<String> readAsString({Encoding encoding = utf8}) =>
      file.readAsString(encoding: encoding);

  @override
  Future<Uint8List> readChunk([int? start, int? end]) {
    assert((start ?? 0) <= (end ?? size));
    assert((end ?? 0) <= size);
    start ??= 0;
    end ??= size;
    final raf = file.openSync();
    if (start != 0) {
      raf.setPositionSync(start);
    }
    // Записываем потоком в файл только если размеры больше 64Кб.
    if (end - start > 64 * 1024) {
      final out = Future.value(raf.read(end - start));
      out.whenComplete(raf.close);
      return out;
    } else {
      final out = Future.value(raf.readSync(end - start));
      raf.closeSync();
      return out;
    }
  }

  @override
  Future<void> saveTo(String path) {
    // Записываем потоком в файл только если размеры больше 64Кб.
    if (size > 64 * 1024) {
      return file.copy(path);
    } else {
      file.copySync(path);
      return Future.value();
    }
  }

  @override
  Future<AtmosXFileReaderFS> startRead([int? start, int? end]) {
    assert((start ?? 0) <= (end ?? size));
    assert((end ?? 0) <= size);
    return Future.value(
      AtmosXFileReaderFS(
        file: this,
        start: start ?? 0,
        end: end,
      ),
    );
  }
}
