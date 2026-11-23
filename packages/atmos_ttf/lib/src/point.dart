/// One point of a TrueType contour.
///
/// Одна точка контура TrueType.
class TtfPoint {
  /// Creates a point. [onCurve] defaults to `true` (line vertex).
  ///
  /// Создаёт точку. [onCurve] по умолчанию `true` (вершина линии).
  const TtfPoint(this.x, this.y, {this.onCurve = true});

  /// X in font units.
  ///
  /// X в единицах шрифта.
  final int x;

  /// Y in font units.
  ///
  /// Y в единицах шрифта.
  final int y;

  /// Whether the point lies on the curve (`true`) or is a quadratic
  /// control point (`false`).
  ///
  /// Лежит ли точка на кривой (`true`) или является контрольной
  /// точкой квадратичной Безье (`false`).
  final bool onCurve;

  @override
  String toString() => 'TtfPoint($x, $y, onCurve: $onCurve)';

  @override
  bool operator ==(Object other) =>
      other is TtfPoint &&
      other.x == x &&
      other.y == y &&
      other.onCurve == onCurve;

  @override
  int get hashCode => Object.hash(x, y, onCurve);
}

/// Closed contour: an ordered list of [TtfPoint]s.
///
/// Замкнутый контур: упорядоченный список [TtfPoint].
class TtfContour {
  /// Creates a contour from [points]. Must not be empty.
  ///
  /// Создаёт контур из [points]. Список не должен быть пустым.
  TtfContour(List<TtfPoint> points)
      : assert(points.isNotEmpty, 'Contour needs at least one point'),
        points = List<TtfPoint>.unmodifiable(points);

  /// Points in contour order.
  ///
  /// Точки в порядке обхода контура.
  final List<TtfPoint> points;
}
