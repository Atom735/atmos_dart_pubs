import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../reader/atmos_x_file_reader.dart';
import '../reader/atmos_x_file_reader_ram.dart';
import 'atmos_x_file.dart';

class AtmosXFileRam extends AtmosXFile {
  @override
  final String name;
  @override
  final String path;
  @override
  final String? mimeType;
  @override
  final String nameExt;

  AtmosXFileRam({
    required this.name,
    required this.path,
    this.mimeType,
    required this.nameExt,
    required this.bytes,
  });

  @override
  int get platformId => 0;

  /// Бинарные данные файла.
  final Uint8List bytes;

  @override
  late final int size = bytes.length;

  final _lastModified = DateTime.now();
  late final _lastModifiedF = Future.value(_lastModified);

  @override
  Future<DateTime> lastModified() => _lastModifiedF;
  late final _lengthF = Future.value(size);

  @override
  Future<int> length() => _lengthF;

  @override
  Stream<Uint8List> openRead([int? start, int? end]) async* {
    assert((start ?? 0) <= (end ?? size));
    assert((end ?? 0) <= size);
    start ??= 0;
    end ??= size;
    const chunkSize = 8 * 1024;
    for (var i = start; i < end; i += chunkSize) {
      if (i + chunkSize < end) {
        yield bytes.sublist(i, i + chunkSize);
      } else {
        yield bytes.sublist(i, end);
        return;
      }
    }
  }

  late final _readAsBytesF = Future.value(bytes);

  @override
  Future<Uint8List> readAsBytes() => _readAsBytesF;

  @override
  Future<String> readAsString({Encoding encoding = utf8}) =>
      Future.value(encoding.decode(bytes));

  @override
  Future<Uint8List> readChunk([int? start, int? end]) {
    assert((start ?? 0) <= (end ?? size));
    assert((end ?? 0) <= size);
    return Future.value(bytes.sublist(start ?? 0, end));
  }

  @override
  Future<void> saveTo(String path) {
    final file = File(path);
    // Записываем потоком в файл только если размеры больше 64Кб.
    if (size > 64 * 1024) {
      final sink = file.openWrite();
      sink.addStream(openRead());
      return sink.close();
    } else {
      file.writeAsBytesSync(bytes);
      return Future.value();
    }
  }

  @override
  Future<AtmosXFileReader> startRead([int? start, int? end]) {
    assert((start ?? 0) <= (end ?? size));
    assert((end ?? 0) <= size);
    return Future.value(
      AtmosXFileReaderRam(
        file: this,
        start: start ?? 0,
        end: end,
      ),
    );
  }
}
