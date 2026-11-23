# atmos_vector_graphics_flutter

English: [README.md](README.md).

Рендерер Flutter Canvas для контейнеров \`atmos_vector_graphics_core\` (GVG3) — by Atom735. Без зависимости от Material.

## Установка

```yaml
dependencies:
  atmos_vector_graphics_flutter: ^0.1.0
```

## Быстрый старт

```dart
import 'package:atmos_vector_graphics_flutter/atmos_vector_graphics_flutter.dart';
import 'package:flutter/widgets.dart';

Widget buildIcon(VgContainer vg) => CustomPaint(
  painter: VgFlutterCustomPainter(vcg: vg),
);
```

## Лицензия

BSD 3-Clause. См. [LICENSE](LICENSE).
