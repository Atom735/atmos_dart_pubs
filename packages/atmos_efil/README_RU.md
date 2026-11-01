# atmos_efil

English: [README.md](README.md).

Редактор исполняемых образов на чистом Dart. `elif` — это `file` наоборот: загрузить ELF или PE, сменить точку входа, заменить секцию байтами той же длины и записать образ обратно.

Mach-O в этой версии узнаётся, но не редактируется.

## Установка

```yaml
dependencies:
  atmos_efil: ^0.1.0
```

## Быстрый старт

```dart
import 'dart:typed_data';

import 'package:atmos_efil/atmos_efil.dart';

void edit(Uint8List bytes) {
  final image = openExecutable(bytes);
  print(identifyExecutable(bytes)); // ExecutableFormat.elf или .pe
  print(image.entryPoint);

  image.entryPoint += 1;
  final text = image.sectionByName('.text');
  if (text != null) {
    final patched = text.bytes;
    patched[0] = 0x90;
    text.writeBytes(patched);
  }

  final edited = image.toBytes();
}
```

`writeBytes` не принимает список другой длины. Смена размера секции сдвинула бы все последующие смещения в файле, эта версия так не переписывает образ.

Значения шире 2^53 теряют младшие биты в вебе. На VM целое сохраняется целиком.

Чтение и запись идут через `atmos_binary_buffer`.

## Лицензия

BSD 3-Clause — см. [LICENSE](LICENSE).
