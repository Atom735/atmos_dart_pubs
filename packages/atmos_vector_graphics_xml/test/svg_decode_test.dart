import 'package:atmos_vector_graphics_xml/atmos_vector_graphics_xml.dart';
import 'package:test/test.dart';

void main() {
  test('decodes a minimal SVG path', () {
    const svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
  <path d="M2 12 L12 2 L22 12 Z" fill="#000000"/>
</svg>
''';
    final vg = VgSvgDecoder.convertFromSvg(svg);
    expect(vg, isNotNull);
    expect(vg!.paths, isNotEmpty);
    expect(vg.frames, isNotEmpty);
    expect(vg.toBytes().sublist(0, 4), 'GVG3'.codeUnits);
  });
}
