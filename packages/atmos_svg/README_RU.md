# atmos_svg

English: [README.md](README.md).

Pure-Dart модель SVG-документа: разбор XML, поиск и правка элементов и path data, сериализация обратно. Без зависимости от Flutter.

## Установка

```yaml
dependencies:
  atmos_svg: ^0.1.0
```

## Быстрый старт

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

## Возможности

- Изменяемый DOM: `SvgDocument`, `SvgElement`, текстовые узлы
- Поиск: `getElementById`, `getElementsByTagName`, `querySelector` / `querySelectorAll`
- Path `d`: `SvgPath` с absolute/relative командами и аффинными хелперами
- `SvgViewBox.parse` / `.toString` для `viewBox`

Разбор XML через [`xml`](https://pub.dev/packages/xml); публичный API ориентирован на SVG и не зависит от Flutter.

## Лицензия

BSD 3-Clause — см. [LICENSE](LICENSE).
