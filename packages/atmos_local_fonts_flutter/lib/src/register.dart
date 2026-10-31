import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show FontLoader;

/// Loads [files] into Flutter as the font [family].
///
/// An empty [files] completes without doing work. Each file is one face.
/// The engine reads weight and style from the font tables.
///
/// Загружает [files] во Flutter как семейство [family].
/// Пустой список ничего не делает. Каждый файл — одно начертание.
/// Движок читает насыщенность и стиль из таблиц шрифта.
Future<void> loadLocalFontFiles(
  String family,
  List<Uint8List> files,
) async {
  if (files.isEmpty) return;
  final loader = FontLoader(family);
  for (final bytes in files) {
    loader.addFont(
      Future<ByteData>.value(ByteData.sublistView(bytes)),
    );
  }
  await loader.load();
}

/// Registers font [files] under [family].
///
/// Регистрирует файлы [files] под именем [family].
typedef LocalFontFileLoader = Future<void> Function(
  String family,
  List<Uint8List> files,
);
