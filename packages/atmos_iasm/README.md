# atmos_iasm

Русский: [README_RU.md](README_RU.md).

Pure-Dart x86 disassembler with a small Capstone-like API. Intel syntax, 32-bit and 64-bit mode. It is not a binding to Capstone: the decoder lives in this package.

This version decodes general-purpose integer instructions (moves, ALU, stack, branches, string ops, `lock` / `rep`) plus a few system opcodes such as `syscall`, `cpuid`, and `endbr64`. SSE, AVX, x87, and other architectures are rejected, and a linear sweep stops before the first rejected byte.

Immediates wider than 2^53 lose low bits on the web. The VM keeps the full integer.

## Install

```yaml
dependencies:
  atmos_iasm: ^0.1.0
```

## Quick start

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

`decode` throws `IasmDecodeException` when the bytes at that address are not an instruction this version knows. `disassemble` returns the instructions it could decode and stops.

A branch operand's `imm` is the target address, not the raw displacement. If bit 63 of a 64-bit target is set, `imm` is negative and `text` still prints the unsigned address.

## License

BSD 3-Clause — see [LICENSE](LICENSE).
