import 'package:atmos_vector_graphics_core/atmos_vector_graphics_core.dart';

/// How generated Dart should expose the asset.
///
/// Как сгенерированный Dart отдаёт ассет.
enum VgEmitStyle {
  /// Pure Dart: `VgContainer` bytes + accessors (no Flutter imports).
  ///
  /// Pure Dart: байты `VgContainer` + аксессоры (без Flutter).
  dart,

  /// Flutter helpers: `getWidget()` / `CustomPainter` via
  /// `atmos_vector_graphics_flutter`.
  ///
  /// Flutter-хелперы через `atmos_vector_graphics_flutter`.
  flutter,
}

/// One SVG asset to compile into GVG3.
///
/// Один SVG-ассет для компиляции в GVG3.
class VgAssetSpec {
  /// Creates an asset spec.
  ///
  /// Создаёт спецификацию ассета.
  VgAssetSpec({
    required this.name,
    required this.svgSource,
    this.sourceLabel,
  });

  /// Dart identifier stem (`cross` → `cross` / `_cross`).
  ///
  /// Основа Dart-идентификатора.
  final String name;

  /// Raw SVG XML.
  ///
  /// Исходный SVG XML.
  final String svgSource;

  /// Optional label for comments (for example file name).
  ///
  /// Опциональная метка для комментариев (например имя файла).
  final String? sourceLabel;
}

/// Input for `generateVgLibrary`.
///
/// Вход для `generateVgLibrary`.
class VgGenSpec {
  /// Creates a generation spec.
  ///
  /// Создаёт спецификацию генерации.
  VgGenSpec({
    required this.libraryName,
    required this.className,
    required this.assets,
    this.emitStyle = VgEmitStyle.flutter,
    this.partOfLibrary,
    this.generatedBy = 'atmos_vg_gen',
    this.prefix = '',
  });

  /// `library` / file basename hint (`my_icons`).
  ///
  /// Имя библиотеки / файла (`my_icons`).
  final String libraryName;

  /// Public holder class for static accessors (`MyIcons`).
  ///
  /// Публичный класс со static-аксессорами (`MyIcons`).
  final String className;

  /// Assets to embed.
  ///
  /// Ассеты для встраивания.
  final List<VgAssetSpec> assets;

  /// Dart-only or Flutter-oriented output.
  ///
  /// Pure Dart или Flutter-ориентированный вывод.
  final VgEmitStyle emitStyle;

  /// If set, each asset file is a `part of` this library URI.
  ///
  /// Если задано, каждый файл ассета — `part of` этой библиотеки.
  final String? partOfLibrary;

  /// Marker in generated headers.
  ///
  /// Метка в шапках сгенерированных файлов.
  final String generatedBy;

  /// Optional prefix for static fields (`ic_` → `ic_cross`).
  ///
  /// Опциональный префикс static-полей (`ic_` → `ic_cross`).
  final String prefix;
}

/// One compiled asset inside `VgGenResult`.
///
/// Один скомпилированный ассет в `VgGenResult`.
class VgCompiledAsset {
  /// Creates a compiled asset.
  ///
  /// Создаёт скомпилированный ассет.
  VgCompiledAsset({
    required this.name,
    required this.identifier,
    required this.container,
    required this.bytes,
    required this.sourceLabel,
  });

  /// Original [VgAssetSpec.name].
  final String name;

  /// Normalized Dart identifier.
  final String identifier;

  /// Decoded GVG3 container.
  final VgContainer container;

  /// Serialized GVG3 bytes.
  final List<int> bytes;

  /// Source label for docs.
  final String sourceLabel;
}

/// Output of `generateVgLibrary`.
///
/// Результат `generateVgLibrary`.
class VgGenResult {
  /// Creates a result.
  ///
  /// Создаёт результат.
  VgGenResult({
    required this.librarySource,
    required this.assetSources,
    required this.assets,
    this.previewHtml,
  });

  /// Main library Dart source.
  ///
  /// Исходник главной библиотеки.
  final String librarySource;

  /// Per-asset Dart sources, keyed by suggested file name
  /// (`cross.g.dart`).
  ///
  /// Исходники по ассетам, ключ — имя файла (`cross.g.dart`).
  final Map<String, String> assetSources;

  /// Compiled assets (same order as input).
  ///
  /// Скомпилированные ассеты (тот же порядок, что на входе).
  final List<VgCompiledAsset> assets;

  /// Optional HTML preview (original SVGs).
  ///
  /// Опциональный HTML-превью исходных SVG.
  final String? previewHtml;
}
