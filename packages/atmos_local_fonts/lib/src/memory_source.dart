import 'errors.dart';
import 'face.dart';
import 'source.dart';

/// [LocalFontSource] backed by an in-memory face list.
///
/// [LocalFontSource] из списка начертаний в памяти.
class MemoryLocalFontSource implements LocalFontSource {
  /// Creates a source from [faces].
  ///
  /// [supported] is reported by [isSupported]. When it is false, [query]
  /// throws [LocalFontsUnsupportedException].
  ///
  /// Создаёт источник из [faces].
  /// Если [supported] равен false, [query] бросает
  /// [LocalFontsUnsupportedException].
  MemoryLocalFontSource(
    Iterable<LocalFontFace> faces, {
    this.supported = true,
  }) : _faces = List<LocalFontFace>.unmodifiable(faces);

  final List<LocalFontFace> _faces;

  /// When false, [query] fails as unsupported.
  ///
  /// Если false, [query] завершается как неподдерживаемый.
  final bool supported;

  @override
  bool get isSupported => supported;

  @override
  Future<List<LocalFontFace>> query({
    List<String>? postscriptNames,
  }) async {
    if (!supported) {
      throw const LocalFontsUnsupportedException();
    }
    final names = postscriptNames;
    if (names == null) return _faces;
    final wanted = names.toSet();
    return List<LocalFontFace>.unmodifiable(
      _faces.where((face) => wanted.contains(face.postscriptName)),
    );
  }
}
