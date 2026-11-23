/// Pure-Dart SVG document model: parse, edit, serialize.
///
/// ## ENG
/// Mutable element tree, simple CSS queries, and path `d` transforms.
///
/// ## RU
/// Изменяемое дерево элементов, простые CSS-запросы и трансформации path `d`.
library atmos_svg;

export 'src/document.dart';
export 'src/element.dart';
export 'src/errors.dart';
export 'src/node.dart';
export 'src/open.dart';
export 'src/path/command.dart';
export 'src/path/path.dart';
export 'src/query.dart';
export 'src/transform.dart';
export 'src/view_box.dart';
