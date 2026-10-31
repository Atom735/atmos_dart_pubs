import 'package:atmos_jsonc/atmos_jsonc.dart';

import 'color.dart';
import 'theme.dart';
import 'theme_uri.dart';
import 'token_color.dart';

/// Resolves a relative `include` path to theme JSONC source text.
///
/// [relativePath] is the raw `include` value (e.g. `./dark_plus.json`).
typedef VscThemeIncludeResolver = String Function(String relativePath);

/// Async variant of [VscThemeIncludeResolver].
typedef VscThemeIncludeResolverAsync = Future<String> Function(
  String relativePath,
);

/// Reads theme source for an absolute [fileUri] (after resolving `include`).
typedef VscThemeUriReader = String Function(Uri fileUri);

/// Async [VscThemeUriReader].
typedef VscThemeUriReaderAsync = Future<String> Function(Uri fileUri);

/// Parses and merges VS Code / Cursor color themes (JSONC + `include`).
///
/// ## ENG
/// Use [parseColorTheme] with an include resolver. UTF-8 bytes:
/// [parseColorThemeUtf8]. Async / AssetBundle: [parseColorThemeAsync] /
/// [loadColorThemeUriAsync].
///
/// Filesystem helpers live in
/// `package:atmos_vsc_theme/atmos_vsc_theme_io.dart`
/// (`VscThemeIo`) so this library stays free of `dart:io`.
///
/// Nested `include` paths are resolved relative to **each** theme file’s
/// directory (VS Code behavior). A color set to JSON `null` or `""` removes
/// that key from an included parent.
///
/// ## RU
/// [parseColorTheme] с резолвером `include`. UTF-8: [parseColorThemeUtf8].
/// Async: [parseColorThemeAsync] / [loadColorThemeUriAsync].
///
/// Файловые хелперы — `package:atmos_vsc_theme/atmos_vsc_theme_io.dart`
/// (`VscThemeIo`), чтобы эта библиотека не тянула `dart:io`.
///
/// Вложенные `include` резолвятся относительно каталога **каждого** файла.
/// Цвет `null` или `""` убирает ключ, унаследованный из `include`.
///
/// Unsupported: `tokenColors` as a path to a TextMate `.tmTheme` file
/// (only inline JSON arrays are merged).
abstract final class VscThemeLoader {
  /// Parses [source] JSONC and recursively merges `include`.
  ///
  /// When [resolveInclude] is set without [includeBase], relatives are passed
  /// through as-is. With [includeBase] and [readIncludeUri], each relative
  /// path is resolved against that theme file’s directory.
  static VscColorTheme parseColorTheme(
    String source, {
    VscThemeIncludeResolver? resolveInclude,
    Uri? includeBase,
    VscThemeUriReader? readIncludeUri,
  }) =>
      _parseDecoded(
        jsoncDecode(source),
        resolveInclude: resolveInclude,
        readIncludeUri: readIncludeUri,
        baseDir: includeBase ?? Uri.parse('theme:/'),
        includeStack: <String>{},
      );

  /// Parses UTF-8 JSONC bytes (no full document [String] allocation for scan).
  static VscColorTheme parseColorThemeUtf8(
    List<int> bytes, {
    VscThemeIncludeResolver? resolveInclude,
    Uri? includeBase,
    VscThemeUriReader? readIncludeUri,
  }) =>
      _parseDecoded(
        jsoncDecodeUtf8(bytes),
        resolveInclude: resolveInclude,
        readIncludeUri: readIncludeUri,
        baseDir: includeBase ?? Uri.parse('theme:/'),
        includeStack: <String>{},
      );

  /// Async parse with URI-based include reads (AssetBundle, isolate, …).
  static Future<VscColorTheme> parseColorThemeAsync(
    String source, {
    required VscThemeUriReaderAsync readIncludeUri,
    required Uri includeBase,
  }) =>
      _parseDecodedAsync(
        jsoncDecode(source),
        readIncludeUri: readIncludeUri,
        baseDir: includeBase,
        includeStack: <String>{},
      );

  /// Async load: [themeUri] is the entry theme; [readIncludeUri] loads files.
  ///
  /// Example asset URI: `asset:packages/atmos_vsc_theme/themes/defaults/dark_modern.json`
  /// with [readIncludeUri] mapping `asset:…` paths to `AssetBundle.loadString`.
  static Future<VscColorTheme> loadColorThemeUriAsync(
    Uri themeUri, {
    required VscThemeUriReaderAsync readIncludeUri,
  }) async {
    final source = await readIncludeUri(themeUri);
    return parseColorThemeAsync(
      source,
      readIncludeUri: readIncludeUri,
      includeBase: themeDirectoryUri(themeUri),
    );
  }

  static VscColorTheme _parseDecoded(
    Object? decoded, {
    required VscThemeIncludeResolver? resolveInclude,
    required VscThemeUriReader? readIncludeUri,
    required Uri baseDir,
    required Set<String> includeStack,
  }) {
    if (decoded is! Map) {
      throw const FormatException('Color theme root must be a JSON object');
    }
    final map = decoded.cast<String, Object?>();

    VscColorTheme? parent;
    final include = map['include'];
    if (include is String && include.isNotEmpty) {
      if (readIncludeUri != null) {
        final target = baseDir.resolve(include);
        final key = target.toString();
        if (!includeStack.add(key)) {
          throw FormatException('Circular theme include: $key');
        }
        parent = _parseDecoded(
          jsoncDecode(readIncludeUri(target)),
          resolveInclude: null,
          readIncludeUri: readIncludeUri,
          baseDir: themeDirectoryUri(target),
          includeStack: includeStack,
        );
        includeStack.remove(key);
      } else if (resolveInclude != null) {
        if (!includeStack.add(include)) {
          throw FormatException('Circular theme include: $include');
        }
        parent = _parseDecoded(
          jsoncDecode(resolveInclude(include)),
          resolveInclude: resolveInclude,
          readIncludeUri: null,
          baseDir: baseDir,
          includeStack: includeStack,
        );
        includeStack.remove(include);
      } else {
        throw FormatException(
          'Theme includes "$include" but no include resolver was provided',
        );
      }
    }

    return _merge(parent, _parseLeaf(map));
  }

  static Future<VscColorTheme> _parseDecodedAsync(
    Object? decoded, {
    required VscThemeUriReaderAsync readIncludeUri,
    required Uri baseDir,
    required Set<String> includeStack,
  }) async {
    if (decoded is! Map) {
      throw const FormatException('Color theme root must be a JSON object');
    }
    final map = decoded.cast<String, Object?>();

    VscColorTheme? parent;
    final include = map['include'];
    if (include is String && include.isNotEmpty) {
      final target = baseDir.resolve(include);
      final key = target.toString();
      if (!includeStack.add(key)) {
        throw FormatException('Circular theme include: $key');
      }
      final parentSource = await readIncludeUri(target);
      parent = await _parseDecodedAsync(
        jsoncDecode(parentSource),
        readIncludeUri: readIncludeUri,
        baseDir: themeDirectoryUri(target),
        includeStack: includeStack,
      );
      includeStack.remove(key);
    }

    return _merge(parent, _parseLeaf(map));
  }

  static _LeafTheme _parseLeaf(Map<String, Object?> map) {
    final colors = <String, VscColor>{};
    final clearedColors = <String>{};
    final rawColors = map['colors'];
    if (rawColors is Map) {
      rawColors.forEach((key, value) {
        if (key is! String) return;
        if (_clearsColor(value)) {
          clearedColors.add(key);
          return;
        }
        if (value is! String) return;
        final color = VscColor.tryParse(value);
        if (color != null) colors[key] = color;
      });
    }

    final tokenColors = <VscTokenColor>[];
    final rawTokens = map['tokenColors'];
    if (rawTokens is List) {
      for (final item in rawTokens) {
        if (item is Map) {
          tokenColors.add(
            VscTokenColor.fromJson(item.cast<String, Object?>()),
          );
        }
        // String paths to .tmTheme are intentionally skipped.
      }
    }

    final semantic = <String, VscSemanticTokenStyle>{};
    final rawSemantic = map['semanticTokenColors'];
    if (rawSemantic is Map) {
      rawSemantic.forEach((key, value) {
        if (key is! String) return;
        semantic[key] = VscSemanticTokenStyle.fromJson(value);
      });
    }

    return _LeafTheme(
      name: map['name'] as String?,
      type: _parseType(map['type'] as String?),
      semanticHighlighting: map['semanticHighlighting'] as bool?,
      colors: colors,
      clearedColors: clearedColors,
      tokenColors: tokenColors,
      semanticTokenColors: semantic,
    );
  }

  /// JSON `null` or a blank string drops an inherited workbench color.
  static bool _clearsColor(Object? value) =>
      value == null || (value is String && value.trim().isEmpty);

  static VscThemeType? _parseType(String? type) {
    switch (type) {
      case 'dark':
        return VscThemeType.dark;
      case 'light':
        return VscThemeType.light;
      case 'hc':
      case 'hcDark':
      case 'hc-black':
        return VscThemeType.hcDark;
      case 'hcLight':
      case 'hc-light':
        return VscThemeType.hcLight;
      default:
        return null;
    }
  }

  static VscColorTheme _merge(VscColorTheme? parent, _LeafTheme leaf) {
    final colors = <String, VscColor>{
      if (parent != null) ...parent.colorMap,
    };
    leaf.clearedColors.forEach(colors.remove);
    colors.addAll(leaf.colors);
    final tokens = <VscTokenColor>[
      if (parent != null) ...parent.tokenColors,
      ...leaf.tokenColors,
    ];
    final semantic = <String, VscSemanticTokenStyle>{
      if (parent != null) ...parent.semanticTokenColors,
      ...leaf.semanticTokenColors,
    };

    return VscColorTheme(
      name: leaf.name ?? parent?.name,
      type: leaf.type ?? parent?.type,
      semanticHighlighting:
          leaf.semanticHighlighting ?? parent?.semanticHighlighting,
      colors: Map<String, VscColor>.unmodifiable(colors),
      tokenColors: List<VscTokenColor>.unmodifiable(tokens),
      semanticTokenColors:
          Map<String, VscSemanticTokenStyle>.unmodifiable(semantic),
    );
  }
}

class _LeafTheme {
  const _LeafTheme({
    required this.name,
    required this.type,
    required this.semanticHighlighting,
    required this.colors,
    required this.clearedColors,
    required this.tokenColors,
    required this.semanticTokenColors,
  });

  final String? name;
  final VscThemeType? type;
  final bool? semanticHighlighting;
  final Map<String, VscColor> colors;
  final Set<String> clearedColors;
  final List<VscTokenColor> tokenColors;
  final Map<String, VscSemanticTokenStyle> semanticTokenColors;
}
