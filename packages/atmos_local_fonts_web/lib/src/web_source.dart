import 'package:atmos_local_fonts/atmos_local_fonts.dart';
import 'package:atmos_web_local_font_access_api/atmos_web_local_font_access_api.dart';

/// [LocalFontSource] backed by `window.queryLocalFonts`.
///
/// [LocalFontSource] через `window.queryLocalFonts`.
class WebLocalFontSource implements LocalFontSource {
  /// Creates a browser source.
  ///
  /// Создаёт браузерный источник.
  const WebLocalFontSource();

  @override
  bool get isSupported => isLocalFontAccessApiSupported;

  @override
  Future<List<LocalFontFace>> query({
    List<String>? postscriptNames,
  }) async {
    if (!isSupported) {
      throw const LocalFontsUnsupportedException();
    }
    try {
      final fonts = await queryLocalFonts(
        postscriptNames == null
            ? null
            : QueryLocalFontsOptions(postscriptNames: postscriptNames),
      );
      return <LocalFontFace>[
        for (final font in fonts)
          LocalFontFace(
            family: font.family,
            fullName: font.fullName,
            postscriptName: font.postscriptName,
            style: font.style,
            readBytes: font.readBytes,
          ),
      ];
    } on LocalFontAccessNotAllowedException catch (error) {
      throw LocalFontsNotAllowedException(cause: error);
    } on LocalFontAccessException catch (error) {
      throw LocalFontsException(error.message, cause: error);
    }
  }
}
