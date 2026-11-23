# atmos_vector_graphics_core

Русский: [README_RU.md](README_RU.md).

Pure-Dart GVG3 vector graphics container (paths, paints, frames) with binary codec — by Atom735.

## Install

```yaml
dependencies:
  atmos_vector_graphics_core: ^0.1.0
```

## Quick start

```dart
import 'package:atmos_vector_graphics_core/atmos_vector_graphics_core.dart';

void main() {
  final container = VgContainer.fromBase64(base64);
  final bytes = container.toBytes();
}
```

## License

BSD 3-Clause. See [LICENSE](LICENSE).
