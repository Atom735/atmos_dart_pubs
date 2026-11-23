# atmos_vector_graphics_xml

Русский: [README_RU.md](README_RU.md).

Decode SVG / Android Vector Drawable XML into \`atmos_vector_graphics_core\` (GVG3) containers — by Atom735.

## Install

```yaml
dependencies:
  atmos_vector_graphics_xml: ^0.1.0
```

## Quick start

```dart
import 'package:atmos_vector_graphics_xml/atmos_vector_graphics_xml.dart';

void main() {
  final vg = VgSvgDecoder.convertFromSvg(svgSource);
}
```

## License

BSD 3-Clause. See [LICENSE](LICENSE).
