# atmos_svg

Русский: [README_RU.md](README_RU.md).

Pure-Dart SVG document model: parse XML, query and edit elements and path data, serialize back. No Flutter dependency.

## Install

```yaml
dependencies:
  atmos_svg: ^0.1.0
```

## Quick start

```dart
import 'package:atmos_svg/atmos_svg.dart';

void main() {
  final doc = parseSvg('''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path id="a" d="M2 12 L12 2 L22 12 Z" fill="none" stroke="black"/>
</svg>
''');

  final path = doc.getElementById('a')!;
  final d = SvgPath.parse(path.getAttribute('d')!);
  path.setAttribute('d', d.translate(1, 1).scale(0.9).toString());
  path.setAttribute('stroke', '#333');

  doc.root.setAttribute('width', '48');
  print(doc.toXmlString());
}
```

## Features

- Mutable DOM: `SvgDocument`, `SvgElement`, text nodes
- Query: `getElementById`, `getElementsByTagName`, `querySelector` / `querySelectorAll`
- Path `d`: `SvgPath` with absolute/relative commands and affine helpers
- `SvgViewBox.parse` / `.toString` for `viewBox`

Parsing uses the [`xml`](https://pub.dev/packages/xml) package under the hood; the public API is SVG-oriented and independent of Flutter.

## License

BSD 3-Clause — see [LICENSE](LICENSE).
