part of 'vector_graphics_core.dart';

/// Данные контура векторной графики.
///
/// <https://www.w3.org/TR/SVG/paths.html>
final class VgPath {
  /// Тип заливки контура.
  final VgPathFillType fillType;

  /// Инструкции контура.
  final List<VgPathCommand> coms;

  /// Равен ли объект другому объекту с заданной точностью.
  bool isEquals(VgPath other, [double delta = 1e-6]) {
    if (fillType != other.fillType) return false;
    if (coms.length != other.coms.length) return false;
    for (var i = 0; i < coms.length; i++) {
      if (!coms[i].isEquals(other.coms[i], delta)) return false;
    }
    return true;
  }

  const VgPath(this.fillType, this.coms);
}

extension VgPathXBinaryReader on VgBinaryReader {
  List<VgPath> readVgPaths() => readList((i, reader) => reader.readVgPath());

  VgPath readVgPath() {
    final fillType = VgPathFillType.values[readUint8()];
    final coms = readList((i, p) => p.readVgPathCommand());
    return VgPath(fillType, coms);
  }
}

extension VgPathXBinaryWriter on VgBinaryWriter {
  void writeVgPaths(List<VgPath> d) {
    writeList(d, (e, i, p) => p.writeVgPath(e));
  }

  void writeVgPath(VgPath d) {
    writeUint8(d.fillType.index);
    writeList(d.coms, (d, i, p) => p.writeVgPathCommand(d));
  }
}

/// Данные инструкций для контура [VgPath].
///
/// <https://www.w3.org/TR/SVG/paths.html>
final class VgPathCommand {
  /// Литера инструкции.
  final VgPathC c;

  /// Является ли реальная литера незаглавной. т.е. координаты относительные.
  final bool r;

  /// Список значений.
  ///
  /// Их количество зависит от литеры команды.
  final List<double> v;

  const VgPathCommand(this.c, this.r, this.v);

  /// Равен ли объект другому объекту с заданной точностью.
  bool isEquals(VgPathCommand other, [double delta = 1e-6]) {
    if (c != other.c) return false;
    if (r != other.r) return false;
    if (v.length != other.v.length) return false;
    for (var i = 0; i < v.length; i++) {
      if ((v[i] - other.v[i]).abs() > delta) return false;
    }
    return true;
  }
}

extension VgPathCommandXBinaryReader on VgBinaryReader {
  VgPathCommand readVgPathCommand() {
    var ch = readString(size: 1);
    final r = ch.toLowerCase() == ch;
    if (r) ch = ch.toUpperCase();
    final c = VgPathC.values.firstWhere((e) => e.str == ch);
    final v = readListFloat16(size: c.count);
    return VgPathCommand(c, r, v);
  }
}

extension VgPathCommandXBinaryWriter on VgBinaryWriter {
  void writeVgPathCommand(VgPathCommand d) {
    writeString(d.r ? d.c.str.toLowerCase() : d.c.str, size: 1);
    writeListFloat16(d.v, size: d.c.count);
  }
}

/// Вызов для вырезания по контуру.
final class VgDrawCallClipPath extends VgDrawCall {
  /// Идентификатор пути.
  final int pathId;

  const VgDrawCallClipPath({
    required this.pathId,
  }) : super(VgDrawCallType.clipPath);
}

extension VgDrawCallClipPathXBinaryReader on VgBinaryReader {
  VgDrawCallClipPath readVgDrawCallClipPath() {
    return VgDrawCallClipPath(pathId: readUint16());
  }
}

extension VgDrawCallClipPathXBinaryWriter on VgBinaryWriter {
  void writeVgDrawCallClipPath(VgDrawCallClipPath d) {
    writeUint16(d.pathId);
  }
}

/// Литера инструкции.
enum VgPathC {
  /// Закрытие пути.
  z('Z', 0),

  /// Перемещение в точку.
  m('M', 2),

  /// Линия в точку.
  l('L', 2),

  /// Горизонтальная линия.
  h('H', 1),

  /// Вертикальная линия.
  v('V', 1),

  /// Кубическая кривая Безье.
  c('C', 6),

  /// Кубическая кривая Безье.
  s('S', 4),

  /// Квадратичная кривая Безье.
  q('Q', 4),

  /// Квадратичная кривая Безье.
  t('T', 2),

  /// Эллипс или его часть.
  a('A', 7),

  /// Прямоугольник (x, y, width, height) — аналог SVG rect.
  b('B', 4),

  /// Скруглённый прямоугольник (x, y, width, height, rx, ry).
  r('R', 6),

  /// Эллипс (cx, cy, rx, ry) — аналог SVG ellipse/circle.
  o('O', 4),
  ;

  const VgPathC(this.str, this.count);
  final String str;
  final int count;
}
