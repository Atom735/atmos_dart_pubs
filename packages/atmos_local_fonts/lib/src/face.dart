import 'dart:typed_data';

/// Reads one font file.
///
/// Читает один файл шрифта.
typedef LocalFontReadBytes = Future<Uint8List> Function();

/// One local font face.
///
/// [postscriptName] identifies the face across queries.
///
/// Одно начертание локального шрифта.
/// [postscriptName] опознаёт начертание между запросами.
class LocalFontFace {
  /// Creates a face.
  ///
  /// [readBytes] opens the font file when a loader asks for it.
  ///
  /// Создаёт начертание.
  /// [readBytes] открывает файл шрифта, когда загрузчик его запросит.
  LocalFontFace({
    required this.family,
    required this.fullName,
    required this.postscriptName,
    required this.style,
    required LocalFontReadBytes readBytes,
  }) : _readBytes = readBytes;

  /// CSS family name.
  ///
  /// Имя семейства CSS.
  final String family;

  /// Full name, for example `Arial Bold`.
  ///
  /// Полное имя, например `Arial Bold`.
  final String fullName;

  /// PostScript name, for example `Arial-BoldMT`.
  ///
  /// PostScript-имя, например `Arial-BoldMT`.
  final String postscriptName;

  /// Face style, for example `Regular` or `Bold Italic`.
  ///
  /// Стиль начертания, например `Regular` или `Bold Italic`.
  final String style;

  final LocalFontReadBytes _readBytes;

  /// Reads the font file bytes.
  ///
  /// Читает байты файла шрифта.
  Future<Uint8List> readBytes() => _readBytes();
}
