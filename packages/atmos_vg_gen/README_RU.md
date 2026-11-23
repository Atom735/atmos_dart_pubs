# atmos_vg_gen

English: [README.md](README.md).

Компилирует SVG в GVG3 (`atmos_vector_graphics_*`) и генерирует Dart / Flutter исходники, плюс опциональную HTML-галерею превью.

## Установка

```yaml
dev_dependencies:
  atmos_vg_gen: ^0.1.0
```

## Быстрый старт

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

Пишет `app_icons.dart`, `*.g.dart` parts и `preview.html`.

## Лицензия

BSD 3-Clause. См. [LICENSE](LICENSE).
