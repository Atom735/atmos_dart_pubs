/// SVG → GVG3 → Dart / Flutter codegen with optional HTML preview.
///
/// ## ENG
/// Compile SVG assets into embedded `VgContainer` bytes and emit a library
/// of accessors (pure Dart or Flutter widgets).
///
/// ## RU
/// Компилирует SVG-ассеты в байты `VgContainer` и генерирует библиотеку
/// аксессоров (pure Dart или Flutter-виджеты).
library atmos_vg_gen;

export 'package:atmos_vector_graphics_core/atmos_vector_graphics_core.dart'
    show VgContainer, VgContainerFrame;

export 'src/bytes_emitter.dart';
export 'src/dart_emitter.dart';
export 'src/generator.dart';
export 'src/io.dart';
export 'src/names.dart';
export 'src/preview.dart';
export 'src/spec.dart';
