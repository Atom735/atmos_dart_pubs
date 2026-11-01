# atmos_efil

Русский: [README_RU.md](README_RU.md).

Pure-Dart editor for executable images. `elif` is `file` backwards: load an ELF or PE file, change the entry point, replace a section with bytes of the same length, and write the image back.

Mach-O is recognized and not edited in this version.

## Install

```yaml
dependencies:
  atmos_efil: ^0.1.0
```

## Quick start

```dart
import 'dart:typed_data';

import 'package:atmos_efil/atmos_efil.dart';

void edit(Uint8List bytes) {
  final image = openExecutable(bytes);
  print(identifyExecutable(bytes)); // ExecutableFormat.elf or .pe
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

`writeBytes` refuses a list whose length differs from the section. Resizing a section would move every later file offset, and this version does not do that rewrite.

Values above 2^53 lose low bits on the web. The VM keeps the full integer.

Reads and writes go through `atmos_binary_buffer`.

## License

BSD 3-Clause — see [LICENSE](LICENSE).
