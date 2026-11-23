/// TrueType / OpenType (`sfnt`) reader and builder.
///
/// ## ENG
/// Parses font bytes into tables and simple glyphs, rebuilds fonts with
/// checksums, and builds minimal TrueType fonts for icon pipelines.
///
/// ## RU
/// Разбирает байты шрифта на таблицы и простые глифы, пересобирает шрифт
/// с checksum и собирает минимальный TrueType для иконочных пайплайнов.
library atmos_ttf;

export 'src/builder.dart';
export 'src/cmap.dart';
export 'src/errors.dart';
export 'src/font.dart';
export 'src/glyph.dart';
export 'src/open.dart';
export 'src/point.dart';
export 'src/table_record.dart';
export 'src/tables/head.dart';
export 'src/tables/hhea.dart';
export 'src/tables/hmtx.dart';
export 'src/tables/maxp.dart';
export 'src/tables/name.dart';
export 'src/tables/os2.dart';
export 'src/tables/post.dart';
