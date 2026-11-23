/// 2D affine matrix `[[a c e], [b d f], [0 0 1]]` (SVG / CSS order).
///
/// 2D аффинная матрица `[[a c e], [b d f], [0 0 1]]` (порядок SVG / CSS).
class SvgMatrix {
  /// Creates a matrix.
  ///
  /// Создаёт матрицу.
  const SvgMatrix(this.a, this.b, this.c, this.d, this.e, this.f);

  /// Identity matrix.
  ///
  /// Единичная матрица.
  static const identity = SvgMatrix(1, 0, 0, 1, 0, 0);

  /// Translation by ([tx], [ty]).
  ///
  /// Сдвиг на ([tx], [ty]).
  factory SvgMatrix.translate(double tx, double ty) =>
      SvgMatrix(1, 0, 0, 1, tx, ty);

  /// Scale by ([sx], [sy]).
  ///
  /// Масштаб ([sx], [sy]).
  factory SvgMatrix.scale(double sx, [double? sy]) =>
      SvgMatrix(sx, 0, 0, sy ?? sx, 0, 0);

  /// Matrix coefficient `a`.
  final double a;

  /// Matrix coefficient `b`.
  final double b;

  /// Matrix coefficient `c`.
  final double c;

  /// Matrix coefficient `d`.
  final double d;

  /// Matrix coefficient `e` (translate x).
  final double e;

  /// Matrix coefficient `f` (translate y).
  final double f;

  /// Multiplies `this · other`.
  ///
  /// Умножает `this · other`.
  SvgMatrix multiply(SvgMatrix other) {
    return SvgMatrix(
      a * other.a + c * other.b,
      b * other.a + d * other.b,
      a * other.c + c * other.d,
      b * other.c + d * other.d,
      a * other.e + c * other.f + e,
      b * other.e + d * other.f + f,
    );
  }

  /// Transforms a point.
  ///
  /// Преобразует точку.
  SvgPoint2 transformPoint(double x, double y) => SvgPoint2(
        a * x + c * y + e,
        b * x + d * y + f,
      );

  /// Transforms a vector (ignores translation).
  ///
  /// Преобразует вектор (без трансляции).
  SvgPoint2 transformVector(double x, double y) => SvgPoint2(
        a * x + c * y,
        b * x + d * y,
      );

  @override
  String toString() => 'matrix($a $b $c $d $e $f)';
}

/// A 2D point or vector.
///
/// 2D точка или вектор.
class SvgPoint2 {
  /// Creates a point.
  ///
  /// Создаёт точку.
  const SvgPoint2(this.x, this.y);

  /// X coordinate.
  final double x;

  /// Y coordinate.
  final double y;
}
