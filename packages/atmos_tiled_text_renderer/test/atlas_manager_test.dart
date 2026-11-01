import 'dart:io';
import 'dart:ui';

import 'package:atmos_tiled_text_renderer/atmos_tiled_text_renderer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const String _monoFamily = 'JetBrains Mono';
const String _monoPath = 'example/fonts/JetBrainsMono-Regular.ttf';

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

Future<void> _bake(
  WidgetTester tester,
  AtlasManager manager,
  double dpr,
  List<String> ligatures,
) {
  return tester.runAsync(() async {
    await _ensureMonoFont();
    await manager.updateDpr(dpr, ligatures);
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  AtlasManager newManager() {
    return AtlasManager(
      fontFamily: _monoFamily,
      logicalFontSize: 16,
    );
  }

  test('конструктор отвергает пустой шрифт и неположительный кегль', () {
    expect(
      () => AtlasManager(fontFamily: '', logicalFontSize: 16),
      throwsArgumentError,
    );
    expect(
      () => AtlasManager(fontFamily: _monoFamily, logicalFontSize: 0),
      throwsArgumentError,
    );
    expect(
      () => AtlasManager(fontFamily: _monoFamily, logicalFontSize: double.nan),
      throwsArgumentError,
    );
  });

  testWidgets('нулевой DPR не запекает атлас', (WidgetTester tester) async {
    final manager = newManager();
    addTearDown(manager.dispose);

    expect(
      () => manager.updateDpr(0, const <String>[]),
      throwsArgumentError,
    );
    expect(
      () => manager.updateDpr(-2, defaultCodeLigatures),
      throwsArgumentError,
    );
    expect(manager.image, isNull);
    expect(manager.isReady, isFalse);
  });

  testWidgets('ASCII, лигатуры и белая ячейка лежат на сетке степени двойки', (
    WidgetTester tester,
  ) async {
    final manager = newManager();
    addTearDown(manager.dispose);

    await _bake(tester, manager, 1, defaultCodeLigatures);

    expect(manager.isReady, isTrue);
    expect(manager.devicePixelRatio, 1);
    expect(manager.logicalCellWidth, greaterThan(0));
    expect(manager.logicalCellHeight, greaterThan(0));
    expect(manager.cellWidthPx, greaterThan(0));
    expect(manager.cellHeightPx, greaterThan(0));
    expect(manager.columns & (manager.columns - 1), 0);
    expect(manager.columnMask, manager.columns - 1);
    expect(
      manager.bakedGlyphCount,
      95 + defaultCodeLigatures.length,
    );

    final image = manager.image!;
    expect(image.width, manager.columns * manager.cellWidthPx);
    expect(image.debugDisposed, isFalse);

    final solid = manager.solidRegion!;
    expect(solid.index, 0);
    expect(solid.charCount, 1);
    expect(
        solid.source,
        Rect.fromLTWH(0, 0, manager.cellWidthPx.toDouble(),
            manager.cellHeightPx.toDouble(),),);

    final regions = <AtlasRegion>[solid];
    for (var code = 32; code <= 126; code++) {
      final region = manager.regionFor(String.fromCharCode(code));
      expect(region, isNotNull, reason: 'нет спрайта для кода $code');
      regions.add(region!);
      _expectGrid(manager, region, image);
    }
    for (final ligature in defaultCodeLigatures) {
      final region = manager.regionFor(ligature)!;
      expect(region.charCount, ligature.length);
      expect(region.source.width, manager.cellWidthPx * ligature.length);
      final column = region.index & manager.columnMask;
      expect(column + region.charCount, lessThanOrEqualTo(manager.columns));
      regions.add(region);
      _expectGrid(manager, region, image);
    }

    expect(manager.regionFor('\n'), isNull);
    expect(manager.regionFor(String.fromCharCode(31)), isNull);
    _expectNoOverlap(regions);

    final bytes = await tester.runAsync(
      () => image.toByteData(format: ImageByteFormat.rawRgba),
    );
    expect(bytes, isNotNull);
    _expectOpaqueWhite(bytes!, image.width, solid.source);
    expect(
      _hasInk(bytes, image.width, manager.regionFor('8')!.source),
      isTrue,
    );
    expect(
      _hasInk(bytes, image.width, manager.regionFor('==')!.source),
      isTrue,
    );
  });

  testWidgets('повторное запекание уничтожает предыдущую текстуру', (
    WidgetTester tester,
  ) async {
    final manager = newManager();
    addTearDown(manager.dispose);

    await _bake(tester, manager, 1, const <String>['==']);
    final first = manager.image!;
    final width1 = manager.cellWidthPx;
    final height1 = manager.cellHeightPx;

    await _bake(tester, manager, 2, const <String>['==', '->']);

    expect(first.debugDisposed, isTrue);
    expect(manager.image!.debugDisposed, isFalse);
    expect(identical(first, manager.image), isFalse);
    expect(manager.devicePixelRatio, 2);
    expect(manager.cellWidthPx / width1, closeTo(2, 0.35));
    expect(manager.cellHeightPx / height1, closeTo(2, 0.35));
    expect(manager.regionFor('->'), isNotNull);
    expect(manager.regionFor('->')!.source.width, manager.cellWidthPx * 2);

    final scaled = manager.logicalCellWidth * manager.devicePixelRatio;
    expect(
      (manager.cellWidthPx - scaled).abs(),
      lessThan(scaled * 0.3 + 2),
    );
  });

  testWidgets('после dispose менеджер не запекает новую текстуру', (
    WidgetTester tester,
  ) async {
    final manager = newManager();
    await _bake(tester, manager, 1, const <String>[]);
    final image = manager.image!;

    manager.dispose();
    manager.dispose();

    expect(image.debugDisposed, isTrue);
    expect(manager.image, isNull);
    expect(manager.isReady, isFalse);
    expect(manager.solidRegion, isNull);
    expect(
      () => manager.updateDpr(1, const <String>[]),
      throwsStateError,
    );
  });
}

void _expectGrid(AtlasManager manager, AtlasRegion region, Image image) {
  final column = region.index & manager.columnMask;
  final row = region.index >> manager.columnShift;
  expect(region.source.left, column * manager.cellWidthPx);
  expect(region.source.top, row * manager.cellHeightPx);
  expect(region.source.width, region.charCount * manager.cellWidthPx);
  expect(region.source.height, manager.cellHeightPx);
  expect(region.source.right, lessThanOrEqualTo(image.width));
  expect(region.source.bottom, lessThanOrEqualTo(image.height));
}

void _expectNoOverlap(List<AtlasRegion> regions) {
  for (var i = 0; i < regions.length; i++) {
    for (var j = i + 1; j < regions.length; j++) {
      final a = regions[i].source;
      final b = regions[j].source;
      final overlaps = a.left < b.right &&
          b.left < a.right &&
          a.top < b.bottom &&
          b.top < a.bottom;
      expect(overlaps, isFalse,
          reason: '${regions[i].index} и ${regions[j].index}',);
    }
  }
}

void _expectOpaqueWhite(ByteData bytes, int width, Rect rect) {
  final x = rect.left.toInt();
  final y = rect.top.toInt();
  final centerX = x + rect.width ~/ 2;
  final centerY = y + rect.height ~/ 2;
  expect(_pixel(bytes, width, x, y), 0xFFFFFFFF);
  expect(_pixel(bytes, width, centerX, centerY), 0xFFFFFFFF);
}

bool _hasInk(ByteData bytes, int width, Rect rect) {
  final left = rect.left.toInt();
  final top = rect.top.toInt();
  final right = rect.right.toInt();
  final bottom = rect.bottom.toInt();
  for (var y = top; y < bottom; y++) {
    for (var x = left; x < right; x++) {
      if (bytes.getUint8((y * width + x) * 4 + 3) > 0) {
        return true;
      }
    }
  }
  return false;
}

int _pixel(ByteData bytes, int width, int x, int y) {
  final offset = (y * width + x) * 4;
  final red = bytes.getUint8(offset);
  final green = bytes.getUint8(offset + 1);
  final blue = bytes.getUint8(offset + 2);
  final alpha = bytes.getUint8(offset + 3);
  return (alpha << 24) | (red << 16) | (green << 8) | blue;
}
