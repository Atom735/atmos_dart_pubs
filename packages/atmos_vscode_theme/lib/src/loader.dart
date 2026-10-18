import 'dart:io';

import 'package:atmos_jsonc/atmos_jsonc.dart';

import 'color.dart';
import 'theme.dart';
import 'token_color.dart';

/// Resolves a relative `include` path to theme JSONC source text.
typedef VscodeThemeIncludeResolver = String Function(String relativePath);

/// Parses and merges VS Code / Cursor color themes (JSONC + `include`).
///
/// ## ENG
/// Use [parseColorTheme] with an include resolver, or [loadColorThemeFile]
/// for filesystem themes.
///
/// ## RU
/// Используйте [parseColorTheme] с резолвером `include`, либо
/// [loadColorThemeFile] для файлов на диске.
abstract final class VscodeThemeLoader {
  /// Parses [source] JSONC and recursively merges `include`.
  ///
  /// [resolveInclude] must return the text of a relative include path
  /// (as written in the theme, e.g. `./dark_vs.json`).
  static VscodeColorTheme parseColorTheme(
    String source, {
    VscodeThemeIncludeResolver? resolveInclude,
  }) =>
      _parse(source, resolveInclude: resolveInclude, includeStack: <String>{});

  static VscodeColorTheme _parse(
    String source, {
    required VscodeThemeIncludeResolver? resolveInclude,
    required Set<String> includeStack,
  }) {
    final decoded = jsoncDecode(source);
    if (decoded is! Map) {
      throw const FormatException('Color theme root must be a JSON object');
    }
    final map = decoded.cast<String, Object?>();

    VscodeColorTheme? parent;
    final include = map['include'];
    if (include is String && include.isNotEmpty) {
      if (resolveInclude == null) {
        throw FormatException(
          'Theme includes "$include" but no resolveInclude was provided',
        );
      }
      if (!includeStack.add(include)) {
        throw FormatException('Circular theme include: $include');
      }
      parent = _parse(
        resolveInclude(include),
        resolveInclude: resolveInclude,
        includeStack: includeStack,
      );
      includeStack.remove(include);
    }

    return _merge(parent, _parseLeaf(map));
  }

  /// Loads a theme file and resolves `include` relative to its directory.
  static VscodeColorTheme loadColorThemeFile(File file) {
    final dir = file.parent;
    return parseColorTheme(
      file.readAsStringSync(),
      resolveInclude: (relative) {
        final target = File.fromUri(dir.uri.resolve(relative));
        if (!target.existsSync()) {
          throw FileSystemException('Included theme not found', target.path);
        }
        return target.readAsStringSync();
      },
    );
  }

  /// Loads from [path] string.
  static VscodeColorTheme loadColorThemePath(String path) =>
      loadColorThemeFile(File(path));

  static _LeafTheme _parseLeaf(Map<String, Object?> map) {
    final colors = <String, VscodeColor>{};
    final rawColors = map['colors'];
    if (rawColors is Map) {
      rawColors.forEach((key, value) {
        if (key is! String || value is! String) return;
        final color = VscodeColor.tryParse(value);
        if (color != null) colors[key] = color;
      });
    }

    final tokenColors = <VscodeTokenColor>[];
    final rawTokens = map['tokenColors'];
    if (rawTokens is List) {
      for (final item in rawTokens) {
        if (item is Map) {
          tokenColors.add(
            VscodeTokenColor.fromJson(item.cast<String, Object?>()),
          );
        }
      }
    }

    final semantic = <String, String>{};
    final rawSemantic = map['semanticTokenColors'];
    if (rawSemantic is Map) {
      rawSemantic.forEach((key, value) {
        if (key is! String) return;
        if (value is String) {
          semantic[key] = value;
        } else if (value is Map && value['foreground'] is String) {
          semantic[key] = value['foreground'] as String;
        }
      });
    }

    return _LeafTheme(
      name: map['name'] as String?,
      type: _parseType(map['type'] as String?),
      semanticHighlighting: map['semanticHighlighting'] as bool?,
      colors: colors,
      tokenColors: tokenColors,
      semanticTokenColors: semantic,
    );
  }

  static VscodeThemeType? _parseType(String? type) {
    switch (type) {
      case 'dark':
        return VscodeThemeType.dark;
      case 'light':
        return VscodeThemeType.light;
      case 'hc':
      case 'hcDark':
      case 'hc-black':
        return VscodeThemeType.hcDark;
      case 'hcLight':
      case 'hc-light':
        return VscodeThemeType.hcLight;
      default:
        return null;
    }
  }

  static VscodeColorTheme _merge(VscodeColorTheme? parent, _LeafTheme leaf) {
    final colors = <String, VscodeColor>{
      if (parent != null) ...parent.colors,
      ...leaf.colors,
    };
    final tokens = <VscodeTokenColor>[
      if (parent != null) ...parent.tokenColors,
      ...leaf.tokenColors,
    ];
    final semantic = <String, String>{
      if (parent != null) ...parent.semanticTokenColors,
      ...leaf.semanticTokenColors,
    };

    return VscodeColorTheme(
      name: leaf.name ?? parent?.name,
      type: leaf.type ?? parent?.type,
      semanticHighlighting:
          leaf.semanticHighlighting ?? parent?.semanticHighlighting,
      colors: Map<String, VscodeColor>.unmodifiable(colors),
      tokenColors: List<VscodeTokenColor>.unmodifiable(tokens),
      semanticTokenColors: Map<String, String>.unmodifiable(semantic),
    );
  }
}

class _LeafTheme {
  const _LeafTheme({
    required this.name,
    required this.type,
    required this.semanticHighlighting,
    required this.colors,
    required this.tokenColors,
    required this.semanticTokenColors,
  });

  final String? name;
  final VscodeThemeType? type;
  final bool? semanticHighlighting;
  final Map<String, VscodeColor> colors;
  final List<VscodeTokenColor> tokenColors;
  final Map<String, String> semanticTokenColors;
}
