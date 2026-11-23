# atmos_vector_graphics_flutter

Русский: [README_RU.md](README_RU.md).

Flutter Canvas renderer for \`atmos_vector_graphics_core\` (GVG3) containers — by Atom735. No Material dependency.

## Install

```yaml
dependencies:
  atmos_vector_graphics_flutter: ^0.1.0
```

## Quick start

```dart
import 'package:atmos_vector_graphics_flutter/atmos_vector_graphics_flutter.dart';
import 'package:flutter/widgets.dart';

Widget buildIcon(VgContainer vg) => CustomPaint(
  painter: VgFlutterCustomPainter(vcg: vg),
);
```

## License

BSD 3-Clause. See [LICENSE](LICENSE).
