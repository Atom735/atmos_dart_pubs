import 'dart:io';

import 'package:atmos_vg_gen/atmos_vg_gen.dart';
import 'package:test/test.dart';

void main() {
  final fixture = File('test/fixtures/cross.svg').readAsStringSync();

  test('compiles SVG to GVG3 and emits flutter library', () {
    final result = generateVgLibrary(
      VgGenSpec(
        libraryName: 'demo_icons',
        className: 'DemoIcons',
        prefix: 'ic_',
        emitStyle: VgEmitStyle.flutter,
        assets: [
          VgAssetSpec(
            name: 'cross',
            svgSource: fixture,
            sourceLabel: 'cross.svg',
          ),
        ],
      ),
      withPreview: true,
    );

    expect(result.assets, hasLength(1));
    expect(result.assets.single.bytes.sublist(0, 4), 'GVG3'.codeUnits);
    expect(result.librarySource, contains('abstract class DemoIconsAsset'));
    expect(result.librarySource, contains('getWidget()'));
    expect(result.librarySource, contains('ic_cross'));
    expect(result.assetSources.keys, contains('cross.g.dart'));
    expect(result.assetSources['cross.g.dart'], contains('part of'));
    expect(result.previewHtml, contains('<svg'));
  });

  test('dart emit style has no Flutter imports', () {
    final result = generateVgLibrary(
      VgGenSpec(
        libraryName: 'plain',
        className: 'Plain',
        emitStyle: VgEmitStyle.dart,
        assets: [
          VgAssetSpec(name: 'cross', svgSource: fixture),
        ],
      ),
    );
    expect(result.librarySource, isNot(contains('flutter')));
    expect(result.librarySource, contains('VgContainer'));
  });

  test('rejects empty assets', () {
    expect(
      () => generateVgLibrary(
        VgGenSpec(libraryName: 'x', className: 'X', assets: const []),
      ),
      throwsArgumentError,
    );
  });
}
