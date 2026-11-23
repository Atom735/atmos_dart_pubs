import 'dart:io';

import 'package:path/path.dart' as p;

import 'spec.dart';

/// Loads every `*.svg` under [inputDir] (non-recursive by default).
///
/// Загружает все `*.svg` из [inputDir] (по умолчанию без рекурсии).
List<VgAssetSpec> loadSvgAssetsFromDirectory(
  Directory inputDir, {
  bool recursive = false,
}) {
  if (!inputDir.existsSync()) {
    throw ArgumentError('Input directory does not exist: ${inputDir.path}');
  }
  final files = inputDir
      .listSync(recursive: recursive)
      .whereType<File>()
      .where((f) => p.extension(f.path).toLowerCase() == '.svg')
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  final assets = <VgAssetSpec>[];
  for (final file in files) {
    final stem = p.basenameWithoutExtension(file.path);
    // Support `_ic.cross.svg` → name `cross`
    final name = stem.contains('.') ? stem.split('.').last : stem;
    assets.add(
      VgAssetSpec(
        name: name,
        svgSource: file.readAsStringSync(),
        sourceLabel: p.basename(file.path),
      ),
    );
  }
  return assets;
}

/// Writes [result] under [outputDir] and optional preview HTML.
///
/// Пишет [result] в [outputDir] и опциональный HTML-превью.
void writeVgGenResult(
  VgGenResult result, {
  required Directory outputDir,
  String libraryFileName = '',
  String? previewFileName,
}) {
  outputDir.createSync(recursive: true);
  final libName = libraryFileName.isEmpty
      ? 'generated.dart'
      : libraryFileName;
  File(p.join(outputDir.path, libName)).writeAsStringSync(result.librarySource);
  for (final e in result.assetSources.entries) {
    File(p.join(outputDir.path, e.key)).writeAsStringSync(e.value);
  }
  final preview = result.previewHtml;
  if (preview != null && previewFileName != null) {
    File(p.join(outputDir.path, previewFileName)).writeAsStringSync(preview);
  }
}
