/// Public API of the `atmos_tiled_text_renderer` package.
///
/// Callers see the span and glyph models, the flattened-line cache,
/// the texture-atlas manager, and `AtlasTextPainter`.
/// A text frame is assembled with one `Canvas.drawAtlas`.
///
/// Публичный API пакета `atmos_tiled_text_renderer`.
///
/// Снаружи видны модели спана и глифа, кэш плоской строки,
/// менеджер текстурного атласа и `AtlasTextPainter`.
/// Кадр текста собирается одним `Canvas.drawAtlas`.
library atmos_tiled_text_renderer;

export 'src/atlas_manager.dart';
export 'src/atlas_text_painter.dart';
export 'src/models/atlas_glyph.dart';
export 'src/models/atlas_text_span.dart';
export 'src/models/flattened_line_cache.dart';
