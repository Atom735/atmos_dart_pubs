import 'dart:typed_data';

import '../insn.dart';

part 'x86_decode.dart';

/// Decodes one x86 instruction at [offset].
///
/// [address] is the virtual address of `code[offset]`.
/// [is64] selects long mode; otherwise the decoder uses 32-bit mode.
IasmInsn decodeX86({
  required Uint8List code,
  required int offset,
  required int address,
  required bool is64,
}) {
  return _X86Decoder(
    code: code,
    offset: offset,
    address: address,
    is64: is64,
  ).run();
}
