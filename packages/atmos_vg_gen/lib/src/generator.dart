import 'package:atmos_vector_graphics_xml/atmos_vector_graphics_xml.dart';

import 'dart_emitter.dart';
import 'names.dart';
import 'preview.dart';
import 'spec.dart';

/// Compiles SVG assets into GVG3 and emits Dart / Flutter sources.
///
/// Компилирует SVG в GVG3 и генерирует Dart / Flutter исходники.
///
/// Set [withPreview] to also build an HTML gallery of the original SVGs.
VgGenResult generateVgLibrary(
  VgGenSpec spec, {
  bool withPreview = false,
}) {
  if (spec.assets.isEmpty) {
    throw ArgumentError('VgGenSpec.assets must not be empty');
  }

  final compiled = <VgCompiledAsset>[];
  final svgByName = <String, String>{};
  final usedIds = <String>{};

  for (final asset in spec.assets) {
    final id = toDartIdentifier(asset.name);
    if (!usedIds.add(id)) {
      throw ArgumentError('Duplicate asset identifier "$id"');
    }
    final vg = VgSvgDecoder.convertFromSvg(asset.svgSource);
    if (vg == null) {
      throw FormatException(
        'Failed to decode SVG for asset "${asset.name}"'
        '${asset.sourceLabel == null ? '' : ' (${asset.sourceLabel})'}',
      );
    }
    final label = asset.sourceLabel ?? asset.name;
    compiled.add(
      VgCompiledAsset(
        name: asset.name,
        identifier: id,
        container: vg,
        bytes: vg.toBytes(),
        sourceLabel: label,
      ),
    );
    svgByName[asset.name] = asset.svgSource;
  }

  final partLibrary = '${spec.libraryName}.dart';
  final assetSources = <String, String>{};
  for (final a in compiled) {
    assetSources['${a.identifier}.g.dart'] = emitAssetSource(
      spec: VgGenSpec(
        libraryName: spec.libraryName,
        className: spec.className,
        assets: spec.assets,
        emitStyle: spec.emitStyle,
        partOfLibrary: partLibrary,
        generatedBy: spec.generatedBy,
        prefix: spec.prefix,
      ),
      asset: a,
    );
  }

  final librarySource = emitLibrarySource(
    spec: spec,
    assets: compiled,
  );

  final preview = withPreview
      ? buildSvgPreviewHtml(
          spec: spec,
          assets: compiled,
          svgByName: svgByName,
        )
      : null;

  return VgGenResult(
    librarySource: librarySource,
    assetSources: assetSources,
    assets: compiled,
    previewHtml: preview,
  );
}
