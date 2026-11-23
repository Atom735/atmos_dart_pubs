import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';

import '../errors.dart';

/// One horizontal metric.
///
/// Одна горизонтальная метрика.
class TtfHorizontalMetric {
  /// Creates a metric.
  ///
  /// Создаёт метрику.
  const TtfHorizontalMetric({
    required this.advanceWidth,
    required this.leftSideBearing,
  });

  /// Advance width.
  final int advanceWidth;

  /// Left side bearing.
  final int leftSideBearing;
}

/// Horizontal metrics table (`hmtx`).
///
/// Таблица горизонтальных метрик (`hmtx`).
class TtfHmtx {
  /// Creates an `hmtx` table.
  ///
  /// Создаёт таблицу `hmtx`.
  TtfHmtx(List<TtfHorizontalMetric> metrics)
      : metrics = List<TtfHorizontalMetric>.unmodifiable(metrics);

  /// Parses `hmtx` given [numberOfHMetrics] from `hhea` and [numGlyphs].
  ///
  /// Разбирает `hmtx` при [numberOfHMetrics] из `hhea` и [numGlyphs].
  factory TtfHmtx.parse(
    Uint8List data, {
    required int numberOfHMetrics,
    required int numGlyphs,
  }) {
    if (numberOfHMetrics < 1 || numberOfHMetrics > numGlyphs) {
      throw TtfFormatException('Invalid numberOfHMetrics.');
    }
    final r = BinaryReader(data);
    final metrics = <TtfHorizontalMetric>[];
    for (var i = 0; i < numberOfHMetrics; i++) {
      metrics.add(
        TtfHorizontalMetric(
          advanceWidth: r.readUint16(),
          leftSideBearing: r.readInt16(),
        ),
      );
    }
    final lastAdvance = metrics.last.advanceWidth;
    final remaining = numGlyphs - numberOfHMetrics;
    for (var i = 0; i < remaining; i++) {
      metrics.add(
        TtfHorizontalMetric(
          advanceWidth: lastAdvance,
          leftSideBearing: r.readInt16(),
        ),
      );
    }
    return TtfHmtx(metrics);
  }

  /// Per-glyph metrics.
  final List<TtfHorizontalMetric> metrics;

  /// Encodes with one long metric per glyph (`numberOfHMetrics == length`).
  ///
  /// Кодирует с одной длинной метрикой на глиф.
  Uint8List encode() {
    final w = BinaryWriter();
    for (final m in metrics) {
      w
        ..writeUint16(m.advanceWidth)
        ..writeInt16(m.leftSideBearing);
    }
    return w.toBytes();
  }
}
