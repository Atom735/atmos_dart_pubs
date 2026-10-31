import 'package:atmos_vsc_theme/atmos_vsc_theme.dart';
import 'package:flutter/services.dart';

/// Loads bundled [VscBundledTheme] JSON from a Flutter [AssetBundle].
///
/// ## ENG
/// Resolves nested `include` relative to each theme file (same as VS Code).
/// Declare package assets (see package `pubspec.yaml`) or list
/// `packages/atmos_vsc_theme/themes/...` in the app.
///
/// ## RU
/// Резолвит вложенные `include` относительно каждого файла.
/// Ассеты пакета уже объявлены в `pubspec.yaml` этого пакета.
abstract final class VscThemeAssetLoader {
  /// Loads [theme] via [bundle] (defaults to [rootBundle]).
  static Future<VscColorTheme> load(
    VscBundledTheme theme, {
    AssetBundle? bundle,
  }) {
    return loadAssetPath(theme.assetPath, bundle: bundle);
  }

  /// Loads a theme asset path such as
  /// `packages/atmos_vsc_theme/themes/defaults/dark_modern.json`.
  static Future<VscColorTheme> loadAssetPath(
    String assetPath, {
    AssetBundle? bundle,
  }) {
    final b = bundle ?? rootBundle;
    final cache = <String, Future<String>>{};

    Future<String> loadString(String path) =>
        cache.putIfAbsent(path, () => b.loadString(path));

    final entry = _assetUri(assetPath);
    return VscThemeLoader.loadColorThemeUriAsync(
      entry,
      readIncludeUri: (uri) {
        if (uri.scheme != 'asset') {
          throw FormatException('Expected asset: URI, got $uri');
        }
        final path = _assetPathFromUri(uri);
        return loadString(path);
      },
    );
  }

  static Uri _assetUri(String assetPath) {
    final normalized = assetPath.startsWith('/') ? assetPath : '/$assetPath';
    return Uri(scheme: 'asset', path: normalized);
  }

  static String _assetPathFromUri(Uri uri) {
    final path = uri.path;
    return path.startsWith('/') ? path.substring(1) : path;
  }
}
