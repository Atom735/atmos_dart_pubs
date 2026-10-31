import 'dart:convert';
import 'dart:io';

/// Copies the built Codicon font and writes Dart code points from the
/// `vscode-codicons` submodule.
///
/// Run from `packages/atmos_vsc_codicon_flutter` after
/// `npm run fonts` inside `third_party/vscode-codicons`.
void main() {
  final root = _packageRoot();
  final upstream = Directory('${root.path}/third_party/vscode-codicons');
  final mappingFile = File('${upstream.path}/src/template/mapping.json');
  final metadataFile = File('${upstream.path}/src/template/metadata.json');
  final packageFile = File('${upstream.path}/package.json');
  final fontFile = File('${upstream.path}/dist/codicon.ttf');
  final licenseFile = File('${upstream.path}/LICENSE');

  for (final file in [mappingFile, metadataFile, packageFile, licenseFile]) {
    if (!file.existsSync()) {
      _fail('Missing ${file.path}. Init the vscode-codicons submodule.');
    }
  }
  if (!fontFile.existsSync()) {
    _fail(
      'Missing ${fontFile.path}. '
      'From the submodule run: npm ci && npm run fonts',
    );
  }

  final mapping = jsonDecode(mappingFile.readAsStringSync());
  if (mapping is! Map) {
    _fail('mapping.json must be an object of code point → names.');
  }
  final metadataJson = jsonDecode(metadataFile.readAsStringSync());
  final metadata = metadataJson is Map ? metadataJson : const {};
  final packageJson = jsonDecode(packageFile.readAsStringSync());
  if (packageJson is! Map) {
    _fail('package.json must be an object.');
  }
  final fontVersion = packageJson['fontVersion'];
  if (fontVersion is! String || fontVersion.isEmpty) {
    _fail('package.json fontVersion is missing.');
  }

  final commit = _gitHead(upstream);
  final icons = _icons(mapping, metadata);

  final names = <String>{};
  for (final icon in icons) {
    if (!names.add(icon.dartName)) {
      _fail('Duplicate Dart name ${icon.dartName} for ${icon.id}.');
    }
  }

  final assetFont = File('${root.path}/assets/codicon.ttf');
  assetFont.parent.createSync(recursive: true);
  fontFile.copySync(assetFont.path);

  final noticeDir =
      Directory('${root.path}/third_party_notices/vscode-codicons');
  noticeDir.createSync(recursive: true);
  licenseFile.copySync('${noticeDir.path}/LICENSE');
  File('${noticeDir.path}/SOURCE.md').writeAsStringSync(
    _sourceNotice(fontVersion: fontVersion, commit: commit),
  );

  File('${root.path}/lib/src/vsc_codicons.g.dart').writeAsStringSync(
    _iconsLibrary(icons),
  );
  File('${root.path}/lib/src/vsc_codicon_catalog.g.dart').writeAsStringSync(
    _catalogPart(
      icons: icons,
      fontVersion: fontVersion,
      commit: commit,
    ),
  );

  final codepoints = icons.map((icon) => icon.codePoint).toSet().length;
  stderr.writeln(
    'Wrote ${icons.length} icons ($codepoints code points), '
    'font $fontVersion @ $commit',
  );
}

final class _Icon {
  const _Icon({
    required this.id,
    required this.dartName,
    required this.codePoint,
    required this.primary,
    required this.category,
    required this.description,
  });

  final String id;
  final String dartName;
  final int codePoint;
  final bool primary;
  final String? category;
  final String? description;
}

List<_Icon> _icons(
  Map<Object?, Object?> mapping,
  Map<Object?, Object?> metadata,
) {
  final icons = <_Icon>[];
  final usedNames = <String>{};
  for (final entry in mapping.entries) {
    final key = entry.key;
    if (key is! String) {
      _fail('Code point key must be a string, got $key.');
    }
    final codePoint = int.tryParse(key);
    if (codePoint == null) {
      _fail('Code point "$key" is not an integer.');
    }
    final aliases = entry.value;
    if (aliases is! List || aliases.isEmpty) {
      _fail('Code point $key must list at least one icon id.');
    }
    for (var i = 0; i < aliases.length; i++) {
      final id = aliases[i];
      if (id is! String || id.isEmpty) {
        _fail('Icon id at $key[$i] must be a non-empty string.');
      }
      final meta = metadata[id];
      String? category;
      String? description;
      if (meta is Map) {
        final rawCategory = meta['category'];
        final rawDescription = meta['description'];
        if (rawCategory is String && rawCategory.isNotEmpty) {
          category = rawCategory;
        }
        if (rawDescription is String && rawDescription.isNotEmpty) {
          description = rawDescription;
        }
      }
      icons.add(
        _Icon(
          id: id,
          dartName: _uniqueDartName(id, usedNames),
          codePoint: codePoint,
          primary: i == 0,
          category: category,
          description: description,
        ),
      );
    }
  }
  return icons;
}

const _reserved = {
  'assert',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'default',
  'do',
  'else',
  'enum',
  'extends',
  'false',
  'final',
  'finally',
  'for',
  'if',
  'in',
  'is',
  'new',
  'null',
  'rethrow',
  'return',
  'super',
  'switch',
  'this',
  'throw',
  'true',
  'try',
  'var',
  'void',
  'while',
  'with',
};

final _camel = RegExp(r'-([a-z])');
final _ident = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

String _uniqueDartName(String id, Set<String> used) {
  final camel = id.replaceAllMapped(_camel, (match) => match[1]!.toUpperCase());
  if (!_ident.hasMatch(camel)) {
    _fail('Icon id "$id" is not a Dart identifier ("$camel").');
  }
  final name = _reserved.contains(camel) ? '${camel}Icon' : camel;
  if (!_ident.hasMatch(name)) {
    _fail('Icon id "$id" is not a Dart identifier ("$name").');
  }
  if (!used.add(name)) {
    _fail('Dart name "$name" collided while adding "$id".');
  }
  return name;
}

String _iconsLibrary(List<_Icon> icons) {
  final buffer = StringBuffer()
    ..writeln('// Generated by tool/generate_codicons.dart. Do not edit.')
    ..writeln("import 'package:flutter/widgets.dart';")
    ..writeln()
    ..writeln('/// Every Codicon glyph as a static [IconData].')
    ..writeln('///')
    ..writeln('/// ## ENG')
    ..writeln('/// Names follow `vscode-codicons`: `git-pull-request` becomes')
    ..writeln('/// [gitPullRequest]. Aliases that share a code point are')
    ..writeln('/// separate constants. Pass one to [Icon].')
    ..writeln('///')
    ..writeln('/// Only static constants live here, so Flutter can tree-shake')
    ..writeln('/// unused code points. String lookup is `VscCodiconCatalog`.')
    ..writeln('///')
    ..writeln('/// ## RU')
    ..writeln('/// Имена как в `vscode-codicons`: `git-pull-request` →')
    ..writeln('/// [gitPullRequest]. Алиасы с общим кодпоинтом — отдельные')
    ..writeln('/// константы. Передавайте их в [Icon].')
    ..writeln('///')
    ..writeln('/// Здесь только static const, чтобы Flutter выкидывал')
    ..writeln('/// неиспользуемые кодпоинты. Поиск по строке —')
    ..writeln('/// `VscCodiconCatalog`.')
    ..writeln('@staticIconProvider')
    ..writeln('abstract final class VscCodicons {')
    ..writeln('  /// Font family declared in this package.')
    ..writeln("  static const String fontFamily = 'codicon';")
    ..writeln()
    ..writeln('  /// Package that ships [fontFamily].')
    ..writeln(
      '  static const String fontPackage = '
      "'atmos_vsc_codicon_flutter';",
    )
    ..writeln();

  for (final icon in icons) {
    final hex = icon.codePoint.toRadixString(16).toUpperCase();
    buffer
      ..writeln('  /// `${icon.id}` · U+$hex')
      ..writeln('  static const IconData ${icon.dartName} = IconData(')
      ..writeln('    0x$hex,')
      ..writeln('    fontFamily: fontFamily,')
      ..writeln('    fontPackage: fontPackage,')
      ..writeln('  );')
      ..writeln();
  }

  buffer.writeln('}');
  return buffer.toString();
}

String _catalogPart({
  required List<_Icon> icons,
  required String fontVersion,
  required String commit,
}) {
  final codepoints = icons.map((icon) => icon.codePoint).toSet().length;
  final buffer = StringBuffer()
    ..writeln('// Generated by tool/generate_codicons.dart. Do not edit.')
    ..writeln("part of 'vsc_codicon_catalog.dart';")
    ..writeln()
    ..writeln(
      'const String _upstreamFontVersion = ${_dartString(fontVersion)};',
    )
    ..writeln(
      'const String _upstreamCommit = ${_dartString(commit)};',
    )
    ..writeln('const int _codepointCount = $codepoints;')
    ..writeln('const int _iconCount = ${icons.length};')
    ..writeln()
    ..writeln('const List<VscCodiconInfo> _all = <VscCodiconInfo>[');

  for (final icon in icons) {
    buffer
      ..writeln('  VscCodiconInfo(')
      ..writeln('    id: ${_dartString(icon.id)},')
      ..writeln('    dartName: ${_dartString(icon.dartName)},')
      ..writeln('    icon: VscCodicons.${icon.dartName},')
      ..writeln('    primary: ${icon.primary},');
    final category = icon.category;
    final description = icon.description;
    if (category != null) {
      buffer.writeln('    category: ${_dartString(category)},');
    }
    if (description != null) {
      buffer.writeln('    description: ${_dartString(description)},');
    }
    buffer.writeln('  ),');
  }

  buffer
    ..writeln('];')
    ..writeln()
    ..writeln('const Map<String, IconData> _byId = <String, IconData>{');
  for (final icon in icons) {
    buffer.writeln(
      '  ${_dartString(icon.id)}: VscCodicons.${icon.dartName},',
    );
  }
  buffer
    ..writeln('};')
    ..writeln()
    ..writeln('const Map<String, IconData> _byDartName = <String, IconData>{');
  for (final icon in icons) {
    if (icon.dartName == icon.id) continue;
    buffer.writeln(
      '  ${_dartString(icon.dartName)}: VscCodicons.${icon.dartName},',
    );
  }
  buffer.writeln('};');
  return buffer.toString();
}

String _sourceNotice({
  required String fontVersion,
  required String commit,
}) {
  return '''
# vscode-codicons

Font file copied to `assets/codicon.ttf`.

- Upstream: https://github.com/microsoft/vscode-codicons
- Commit: `$commit`
- Font version: $fontVersion
- License: CC-BY-4.0 (see [LICENSE](LICENSE))

Built with the upstream Fantasticon pipeline (`npm run fonts`) from the
git submodule at that commit. Icon ids and code points come from
`src/template/mapping.json`.
''';
}

String _dartString(String value) {
  final escaped = value
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll('\r', '')
      .replaceAll('\n', r'\n');
  return "'$escaped'";
}

Directory _packageRoot() {
  final cwd = Directory.current;
  final marker = File('${cwd.path}/tool/generate_codicons.dart');
  if (marker.existsSync()) return cwd;
  final script = File(Platform.script.toFilePath());
  return script.parent.parent;
}

String _gitHead(Directory upstream) {
  final result = Process.runSync(
    'git',
    ['rev-parse', 'HEAD'],
    workingDirectory: upstream.path,
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );
  if (result.exitCode != 0) {
    _fail('git rev-parse failed: ${result.stderr}');
  }
  final commit = (result.stdout as String).trim();
  if (commit.length < 7) {
    _fail('Unexpected git revision "$commit".');
  }
  return commit;
}

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}
