import 'dart:io';

import 'package:atmos_vg_gen/atmos_vg_gen.dart';

/// Compiles a tiny SVG and prints the generated library header.
void main() {
  const svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
  <path d="M6 6L18 18M6 18L18 6" stroke="#fff" stroke-width="2"/>
</svg>
''';

  final result = generateVgLibrary(
    VgGenSpec(
      libraryName: 'example_icons',
      className: 'ExampleIcons',
      prefix: 'ic_',
      emitStyle: VgEmitStyle.dart,
      assets: [
        VgAssetSpec(name: 'cross', svgSource: svg, sourceLabel: 'inline'),
      ],
    ),
    withPreview: true,
  );

  // ignore: avoid_print
  print(result.librarySource.split('\n').take(20).join('\n'));
  // ignore: avoid_print
  print('… GVG3 bytes: ${result.assets.single.bytes.length}');

  final out = Directory('example/out')..createSync(recursive: true);
  writeVgGenResult(
    result,
    outputDir: out,
    libraryFileName: 'example_icons.dart',
    previewFileName: 'preview.html',
  );
}
