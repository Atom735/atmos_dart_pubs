# atmos_vg_gen

Русский: [README_RU.md](README_RU.md).

Compile SVG into GVG3 (`atmos_vector_graphics_*`) and emit Dart / Flutter source, with an optional HTML preview gallery.

## Install

```yaml
dev_dependencies:
  atmos_vg_gen: ^0.1.0
```

## Quick start

```dart
import 'package:atmos_vg_gen/atmos_vg_gen.dart';

final result = generateVgLibrary(
  VgGenSpec(
    libraryName: 'app_icons',
    className: 'AppIcons',
    prefix: 'ic_',
    emitStyle: VgEmitStyle.flutter,
    assets: [
      VgAssetSpec(name: 'cross', svgSource: svgXml),
    ],
  ),
  withPreview: true,
);
```

### CLI

```bash
dart run atmos_vg_gen --input icons/ --out lib/gen/ \
  --library app_icons --class AppIcons --prefix ic_ --style flutter
```

Writes `app_icons.dart`, `*.g.dart` parts, and `preview.html`.

## License

BSD 3-Clause. See [LICENSE](LICENSE).
