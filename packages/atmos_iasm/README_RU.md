# atmos_iasm

English: [README.md](README.md).

Дизассемблер x86 на чистом Dart с небольшим API в духе Capstone. Intel-синтаксис, 32- и 64-битный режим. Это не обёртка над Capstone: декодер живёт в этом пакете.

Эта версия разбирает целочисленные инструкции общего назначения (пересылки, АЛУ, стек, переходы, строковые операции, `lock` / `rep`) и несколько системных опкодов вроде `syscall`, `cpuid` и `endbr64`. SSE, AVX, x87 и другие архитектуры отвергаются, а линейный проход останавливается перед первым таким байтом.

Непосредственные значения шире 2^53 теряют младшие биты в вебе. На VM целое сохраняется целиком.

## Установка

```yaml
dependencies:
  atmos_iasm: ^0.1.0
```

## Быстрый старт

```dart
import 'dart:typed_data';

import 'package:atmos_iasm/atmos_iasm.dart';

void main() {
  final iasm = Iasm(mode: IasmMode.mode64);
  final code = Uint8List.fromList([
    0x55,
    0x48, 0x89, 0xE5,
    0xC3,
  ]);
  for (final insn in iasm.disassemble(code, address: 0x401000)) {
    print(insn);
  }
}
```

```text
0x401000: push rbp
0x401001: mov rbp, rsp
0x401004: ret
```

`decode` бросает `IasmDecodeException`, если по этому адресу байты, которые эта версия не знает. `disassemble` возвращает разобранные инструкции и останавливается.

У операнда перехода `imm` — это адрес цели, а не сырое смещение. Если в 64-битном адресе установлен бит 63, `imm` отрицательный, а `text` всё равно печатает беззнаковый адрес.

## Лицензия

BSD 3-Clause — см. [LICENSE](LICENSE).
