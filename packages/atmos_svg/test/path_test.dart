import 'package:atmos_svg/atmos_svg.dart';
import 'package:test/test.dart';

void main() {
  test('parses and round-trips path d', () {
    const d = 'M2 12L12 2L22 12Z';
    final path = SvgPath.parse(d);
    expect(path.commands, hasLength(4));
    expect(path.commands[0].letter, 'M');
    expect(path.commands[3].letter, 'Z');
    final again = SvgPath.parse(path.toString());
    expect(again.commands.length, path.commands.length);
  });

  test('translate and scale absolute path', () {
    final path = SvgPath.parse('M0 0 L10 0 L10 10 Z');
    final moved = path.translate(5, 5);
    expect(moved.commands[0].args, [5, 5]);
    expect(moved.commands[1].args, [15, 5]);

    final scaled = path.scale(2);
    expect(scaled.commands[1].args, [20, 0]);
  });

  test('toAbsolute converts relative commands', () {
    final path = SvgPath.parse('M10 10 l5 0 l0 5 z');
    final abs = path.toAbsolute();
    expect(abs.commands[0].letter, 'M');
    expect(abs.commands[1].letter, 'L');
    expect(abs.commands[1].args, [15, 10]);
    expect(abs.commands[2].args, [15, 15]);
    expect(abs.commands[3].letter, 'Z');
  });

  test('implicit linesto after M', () {
    final path = SvgPath.parse('M0 0 10 0 10 10');
    expect(path.commands.map((c) => c.letter).toList(), ['M', 'L', 'L']);
  });

  test('document path edit pipeline', () {
    final doc = parseSvg('''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path id="p" d="M2 12 L12 2 L22 12 Z"/>
</svg>
''');
    final el = doc.getElementById('p')!;
    final d = SvgPath.parse(el.getAttribute('d')!).translate(1, 1);
    el.setAttribute('d', d.toString());
    final parsed = SvgPath.parse(el.getAttribute('d')!);
    expect(parsed.commands.first.args, [3, 13]);
  });
}
