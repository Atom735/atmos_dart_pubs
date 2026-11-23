import 'errors.dart';

/// Parsed SVG `viewBox` (`minX minY width height`).
///
/// Разобранный SVG `viewBox` (`minX minY width height`).
class SvgViewBox {
  /// Creates a viewBox.
  ///
  /// Создаёт viewBox.
  const SvgViewBox({
    required this.minX,
    required this.minY,
    required this.width,
    required this.height,
  });

  /// Parses a `viewBox` attribute value.
  ///
  /// Разбирает значение атрибута `viewBox`.
  factory SvgViewBox.parse(String raw) {
    final parts = raw
        .trim()
        .split(RegExp(r'[\s,]+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length != 4) {
      throw SvgFormatException('viewBox must have 4 numbers, got "$raw"');
    }
    final nums = parts.map(double.parse).toList();
    return SvgViewBox(
      minX: nums[0],
      minY: nums[1],
      width: nums[2],
      height: nums[3],
    );
  }

  /// Minimum X.
  final double minX;

  /// Minimum Y.
  final double minY;

  /// Width.
  final double width;

  /// Height.
  final double height;

  @override
  String toString() {
    String f(double v) {
      if (v == v.roundToDouble()) return v.toInt().toString();
      return v.toString();
    }

    return '${f(minX)} ${f(minY)} ${f(width)} ${f(height)}';
  }

  @override
  bool operator ==(Object other) =>
      other is SvgViewBox &&
      other.minX == minX &&
      other.minY == minY &&
      other.width == width &&
      other.height == height;

  @override
  int get hashCode => Object.hash(minX, minY, width, height);
}
