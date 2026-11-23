import 'package:atmos_svg/atmos_svg.dart';
import 'package:test/test.dart';

void main() {
  const sample = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24">
  <g id="icons">
    <path id="star" d="M12 2 L15 9 L22 9 L17 14 L19 21 L12 17 L5 21 L7 14 L2 9 L9 9 Z"
          fill="none" stroke="black"/>
    <rect x="1" y="1" width="4" height="4"/>
  </g>
</svg>
''';

  test('parses and queries elements', () {
    final doc = parseSvg(sample);
    expect(doc.root.name, 'svg');
    expect(
      doc.viewBox,
      const SvgViewBox(minX: 0, minY: 0, width: 24, height: 24),
    );
    expect(doc.getElementById('star')?.name, 'path');
    expect(doc.querySelector('#star')?.getAttribute('stroke'), 'black');
    expect(doc.querySelectorAll('path'), hasLength(1));
    expect(doc.querySelectorAll('g rect'), hasLength(1));
    expect(doc.getElementsByTagName('rect'), hasLength(1));
  });

  test('edits attributes and children then serializes', () {
    final doc = parseSvg(sample);
    final path = doc.getElementById('star')!;
    path.setAttribute('stroke', '#333');
    path.removeAttribute('fill');

    final circle = SvgElement(
      'circle',
      attributes: {'cx': '12', 'cy': '12', 'r': '2'},
    );
    doc.getElementById('icons')!.appendChild(circle);

    final xml = doc.toXmlString();
    expect(xml, contains('stroke="#333"'));
    expect(xml, isNot(contains('fill="none"')));
    expect(xml, contains('<circle'));

    final again = parseSvg(xml);
    expect(again.querySelectorAll('circle'), hasLength(1));
    expect(again.getElementById('star')?.getAttribute('stroke'), '#333');
  });

  test('createSvg builds a root document', () {
    final doc = createSvg(viewBox: '0 0 10 10', width: '10', height: '10');
    doc.root.appendChild(
      SvgElement('path', attributes: {'d': 'M0 0H10V10H0Z'}),
    );
    expect(doc.toXmlString(), contains('viewBox="0 0 10 10"'));
    expect(doc.querySelector('path'), isNotNull);
  });

  test('clone and remove', () {
    final doc = parseSvg(sample);
    final star = doc.getElementById('star')!;
    final copy = star.clone();
    copy.id = 'star2';
    star.parent!.appendChild(copy);
    expect(doc.querySelectorAll('path'), hasLength(2));
    copy.remove();
    expect(doc.getElementById('star2'), isNull);
  });
}
