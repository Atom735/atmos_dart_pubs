import 'package:atmos_svg/atmos_svg.dart';

void main() {
  final doc = createSvg(viewBox: '0 0 24 24', width: '24', height: '24');
  doc.root.appendChild(
    SvgElement(
      'path',
      attributes: {
        'id': 'arrow',
        'd': 'M4 12 L12 4 L20 12',
        'fill': 'none',
        'stroke': 'black',
        'stroke-width': '2',
      },
    ),
  );

  final pathEl = doc.getElementById('arrow')!;
  final path = SvgPath.parse(pathEl.getAttribute('d')!);
  pathEl.setAttribute('d', path.translate(0, 2).toString());
  pathEl.setAttribute('stroke', '#1a1a1a');

  // ignore: avoid_print
  print(doc.toXmlString(pretty: true));
}
