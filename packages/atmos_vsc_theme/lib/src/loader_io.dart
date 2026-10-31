import 'dart:io';
import 'dart:typed_data';

import 'loader.dart';
import 'theme.dart';
import 'theme_uri.dart';

/// Filesystem loading for VS Code / Cursor color themes.
///
/// ## ENG
/// Import `package:atmos_vsc_theme/atmos_vsc_theme_io.dart`.
/// These helpers need `dart:io` (VM, desktop, mobile). On the web, parse
/// JSON with [VscThemeLoader] and pass an include reader yourself.
///
/// ## RU
/// Импорт `package:atmos_vsc_theme/atmos_vsc_theme_io.dart`.
/// Нужен `dart:io` (VM, desktop, mobile). На web разбирайте JSON через
/// [VscThemeLoader] и передавайте свой reader для `include`.
abstract final class VscThemeIo {
  /// Loads a theme file and resolves `include` relative to each file.
  static VscColorTheme loadColorThemeFile(File file) {
    final uri = file.uri;
    return VscThemeLoader.parseColorTheme(
      file.readAsStringSync(),
      includeBase: themeDirectoryUri(uri),
      readIncludeUri: readThemeFile,
    );
  }

  /// Loads from [path].
  static VscColorTheme loadColorThemePath(String path) =>
      loadColorThemeFile(File(path));

  /// Loads UTF-8 theme bytes; [includeBase] is the directory for `include`.
  static VscColorTheme loadColorThemeBytes(
    List<int> bytes, {
    Directory? includeBase,
  }) {
    return VscThemeLoader.parseColorThemeUtf8(
      bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
      includeBase: includeBase?.uri,
      readIncludeUri: includeBase == null ? null : readThemeFile,
    );
  }

  /// Reads a theme file addressed by [fileUri].
  static String readThemeFile(Uri fileUri) {
    final file = File.fromUri(fileUri);
    if (!file.existsSync()) {
      throw FileSystemException('Included theme not found', file.path);
    }
    return file.readAsStringSync();
  }
}
