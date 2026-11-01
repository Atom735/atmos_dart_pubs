import 'package:atmos_tiled_text_renderer/atmos_tiled_text_renderer.dart';
import 'package:flutter/material.dart';

/// Card for one block: the font name and four atlas-drawn lines.
///
/// Карточка блока: имя шрифта и четыре строки, нарисованные атласом.
class AtlasCodeCard extends StatelessWidget {
  const AtlasCodeCard({
    super.key,
    required this.family,
    required this.note,
    required this.manager,
    required this.lines,
  });

  final String family;
  final String note;
  final AtlasManager manager;
  final List<FlattenedLineCache> lines;

  @override
  Widget build(BuildContext context) {
    final cellWidth = manager.cellWidthPx / manager.dpr;
    final cellHeight = manager.cellHeightPx / manager.dpr;
    var columns = 0;
    for (final line in lines) {
      if (line.charCount > columns) {
        columns = line.charCount;
      }
    }
    final textWidth = columns * cellWidth;
    final textHeight = lines.length * cellHeight;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3C3C3C)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              family,
              style: TextStyle(
                fontFamily: family,
                fontSize: 14,
                height: 1.2,
                color: const Color(0xFFE6EDF3),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              note,
              style: TextStyle(
                fontFamily: family,
                fontSize: 12,
                height: 1.3,
                color: const Color(0xFF9AA3B2),
              ),
            ),
            const SizedBox(height: 12),
            CustomPaint(
              size: Size(textWidth, textHeight),
              painter: AtlasTextPainter(
                atlasManager: manager,
                visibleLines: lines,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
