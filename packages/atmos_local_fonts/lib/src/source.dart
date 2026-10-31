import 'face.dart';

/// Enumerates local font faces.
///
/// Перечисляет начертания локальных шрифтов.
abstract class LocalFontSource {
  /// Whether this runtime can list local fonts.
  ///
  /// Можно ли в этом окружении получить список шрифтов.
  bool get isSupported;

  /// Returns installed faces.
  ///
  /// [postscriptNames], when set, keeps only those names.
  /// An empty list returns no faces.
  ///
  /// Возвращает установленные начертания.
  /// [postscriptNames] оставляет только эти имена.
  /// Пустой список не возвращает начертаний.
  Future<List<LocalFontFace>> query({List<String>? postscriptNames});
}
