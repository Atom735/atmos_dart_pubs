import 'dart:io';
import 'dart:ui';

import 'package:atmos_tiled_text_renderer/atmos_tiled_text_renderer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const String _monoFamily = 'JetBrains Mono';
const String _monoPath = 'example/fonts/JetBrainsMono-Regular.ttf';

const Color _red = Color(0xFFFF0000);
const Color _green = Color(0xFF00FF00);
const Color _blue = Color(0xFF0000FF);

bool _fontLoaded = false;

Future<void> _ensureMonoFont() async {
  if (_fontLoaded) {
    return;
  }
  final file = File(_monoPath);
  if (!file.existsSync()) {
    throw StateError('Bundled font not found: $_monoPath');
  }
  final bytes = await file.readAsBytes();
  final loader = FontLoader(_monoFamily)
    ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
  await loader.load();
  _fontLoaded = true;
}

Future<void> _bake(WidgetTester tester, AtlasManager manager, double dpr) {
  return tester.runAsync(() async {
    await _ensureMonoFont();
    await manager.updateDpr(dpr, const <String>['==']);
  });
}

AtlasGlyph _glyph(
  String text,
  int charCount,
  AtlasTextStyle style,
  AtlasTextSpan span,
) {
  return AtlasGlyph(
    text: text,
    style: style,
    sourceSpan: span,
    charCount: charCount,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const span = AtlasTextSpan(text: 'x');

  test('shouldRepaint молчит, пока строки, DPR и текстура те же', () {
    final manager = AtlasManager(
      fontFamily: _monoFamily,
      logicalFontSize: 16,
    );
    addTearDown(manager.dispose);
    final line = FlattenedLineCache.fromSpan(
      const AtlasTextSpan(text: 'a==b'),
      const <String>['=='],
    );
    final first = AtlasTextPainter(
      atlasManager: manager,
      visibleLines: <FlattenedLineCache>[line],
    );
    final sameLines = AtlasTextPainter(
      atlasManager: manager,
      visibleLines: <FlattenedLineCache>[line],
    );
    final otherText = AtlasTextPainter(
      atlasManager: manager,
      visibleLines: <FlattenedLineCache>[
        FlattenedLineCache.fromSpan(
          const AtlasTextSpan(text: 'z'),
          const <String>[],
        ),
      ],
    );

    expect(sameLines.shouldRepaint(first), isFalse);
    expect(otherText.shouldRepaint(first), isTrue);
    expect(
      AtlasTextPainter(
        atlasManager: manager,
        visibleLines: const <FlattenedLineCache>[],
      ).shouldRepaint(first),
      isTrue,
    );
  });

  testWidgets('пустой вьюпорт и неготовый атлас не рисуют пиксели', (
    WidgetTester tester,
  ) async {
    final manager = AtlasManager(
      fontFamily: _monoFamily,
      logicalFontSize: 16,
    );
    addTearDown(manager.dispose);
    final painter = AtlasTextPainter(
      atlasManager: manager,
      visibleLines: <FlattenedLineCache>[
        FlattenedLineCache.fromSpan(
          const AtlasTextSpan(text: 'A'),
          const <String>[],
        ),
      ],
    );

    final blank = await _raster(tester, painter, 32, 32);
    expect(_hasInk(blank!, 32, const Rect.fromLTWH(0, 0, 32, 32)), isFalse);
  });

  testWidgets('фон строк и лигатура стоят на сетке, буква красится', (
    WidgetTester tester,
  ) async {
    final manager = AtlasManager(
      fontFamily: _monoFamily,
      logicalFontSize: 32,
    );
    addTearDown(manager.dispose);
    await _bake(tester, manager, 1);

    final cellWidth = manager.cellWidthPx;
    final cellHeight = manager.cellHeightPx;
    final backgrounds = FlattenedLineCache(<AtlasGlyph>[
      _glyph(' ', 1, const AtlasTextStyle(backgroundColor: _red), span),
      _glyph('==', 2, const AtlasTextStyle(backgroundColor: _blue), span),
    ]);
    final tinted = FlattenedLineCache.fromSpan(
      const AtlasTextSpan(
        text: '8',
        style: AtlasTextStyle(color: _green),
      ),
      const <String>[],
    );
    final painter = AtlasTextPainter(
      atlasManager: manager,
      visibleLines: <FlattenedLineCache>[backgrounds, tinted],
    );

    final width = cellWidth * 4;
    final height = cellHeight * 2;
    final bytes = await _raster(tester, painter, width, height);
    expect(bytes, isNotNull);

    expect(
      _pixel(bytes!, width, cellWidth ~/ 2, cellHeight ~/ 2),
      _red.value,
    );
    expect(
      _pixel(bytes, width, cellWidth + 1, 1),
      _blue.value,
    );
    expect(
      _pixel(bytes, width, cellWidth * 2 + 1, 1),
      _blue.value,
    );
    expect(
      _hasColor(
        bytes,
        width,
        Rect.fromLTWH(0, cellHeight.toDouble(), cellWidth.toDouble(),
            cellHeight.toDouble(),),
        _green,
      ),
      isTrue,
      reason: 'глиф 8 должен быть зелёным, а не белым',
    );
  });

  testWidgets('перевод строки не занимает ячейку', (WidgetTester tester) async {
    final manager = AtlasManager(
      fontFamily: _monoFamily,
      logicalFontSize: 32,
    );
    addTearDown(manager.dispose);
    await _bake(tester, manager, 1);

    final line = FlattenedLineCache(<AtlasGlyph>[
      _glyph('\n', 1, AtlasTextStyle.empty, span),
      _glyph(' ', 1, const AtlasTextStyle(backgroundColor: _red), span),
    ]);
    expect(line.charCount, 2);
    final painter = AtlasTextPainter(
      atlasManager: manager,
      visibleLines: <FlattenedLineCache>[line],
    );
    final width = manager.cellWidthPx * 2;
    final height = manager.cellHeightPx;
    final bytes = await _raster(tester, painter, width, height);

    expect(
      _pixel(
          bytes!, width, manager.cellWidthPx ~/ 2, manager.cellHeightPx ~/ 2,),
      _red.value,
    );
  });

  testWidgets('смена DPR и текстуры требует перерисовки', (
    WidgetTester tester,
  ) async {
    final manager = AtlasManager(
      fontFamily: _monoFamily,
      logicalFontSize: 16,
    );
    addTearDown(manager.dispose);
    final line = FlattenedLineCache.fromSpan(
      const AtlasTextSpan(text: 'A'),
      const <String>[],
    );
    final before = AtlasTextPainter(
      atlasManager: manager,
      visibleLines: <FlattenedLineCache>[line],
    );

    await _bake(tester, manager, 1);
    final baked = AtlasTextPainter(
      atlasManager: manager,
      visibleLines: <FlattenedLineCache>[line],
    );
    expect(baked.shouldRepaint(before), isTrue);
    expect(baked.shouldRepaint(baked), isFalse);

    await _bake(tester, manager, 2);
    final hidpi = AtlasTextPainter(
      atlasManager: manager,
      visibleLines: <FlattenedLineCache>[line],
    );
    expect(hidpi.shouldRepaint(baked), isTrue);
    expect(hidpi.dpr, 2);
    expect(hidpi.cellWidthPx, greaterThan(baked.cellWidthPx));
  });
}

Future<ByteData?> _raster(
  WidgetTester tester,
  AtlasTextPainter painter,
  int width,
  int height,
) {
  return tester.runAsync<ByteData?>(() async {
    final recorder = PictureRecorder();
    painter.paint(
      Canvas(recorder),
      Size(width.toDouble(), height.toDouble()),
    );
    final picture = recorder.endRecording();
    try {
      final image = await picture.toImage(width, height);
      try {
        return image.toByteData(format: ImageByteFormat.rawRgba);
      } finally {
        image.dispose();
      }
    } finally {
      picture.dispose();
    }
  });
}

int _pixel(ByteData bytes, int width, int x, int y) {
  final offset = (y * width + x) * 4;
  final red = bytes.getUint8(offset);
  final green = bytes.getUint8(offset + 1);
  final blue = bytes.getUint8(offset + 2);
  final alpha = bytes.getUint8(offset + 3);
  return (alpha << 24) | (red << 16) | (green << 8) | blue;
}

bool _hasInk(ByteData bytes, int width, Rect area) {
  final left = area.left.toInt();
  final top = area.top.toInt();
  final right = area.right.toInt();
  final bottom = area.bottom.toInt();
  for (var y = top; y < bottom; y++) {
    for (var x = left; x < right; x++) {
      if (bytes.getUint8((y * width + x) * 4 + 3) != 0) {
        return true;
      }
    }
  }
  return false;
}

bool _hasColor(ByteData bytes, int width, Rect area, Color color) {
  final left = area.left.toInt();
  final top = area.top.toInt();
  final right = area.right.toInt();
  final bottom = area.bottom.toInt();
  for (var y = top; y < bottom; y++) {
    for (var x = left; x < right; x++) {
      final pixel = _pixel(bytes, width, x, y);
      if (pixel == 0) {
        continue;
      }
      final red = (pixel >> 16) & 0xFF;
      final green = (pixel >> 8) & 0xFF;
      final blue = pixel & 0xFF;
      if (color == _green && green > red + 40 && green > blue + 40) {
        return true;
      }
    }
  }
  return false;
}
