import 'dart:typed_data';

import 'arch.dart';
import 'insn.dart';
import 'x86/x86.dart';

/// Linear disassembler.
///
/// Intel syntax. [disassemble] stops before the first byte sequence it
/// cannot decode. [decode] throws [IasmDecodeException] for that sequence.
class Iasm {
  /// [mode] selects the instruction width. Only [IasmArch.x86] exists
  /// in this version.
  Iasm({
    required this.mode,
    this.arch = IasmArch.x86,
  });

  /// CPU family. Only [IasmArch.x86].
  final IasmArch arch;

  /// 32-bit or 64-bit mode.
  final IasmMode mode;

  /// One instruction at [offset].
  ///
  /// [address] is the virtual address of `code[offset]`.
  IasmInsn decode(
    Uint8List code, {
    int address = 0,
    int offset = 0,
  }) {
    _check(code, address, offset, null);
    return decodeX86(
      code: code,
      offset: offset,
      address: address,
      is64: mode == IasmMode.mode64,
    );
  }

  /// Instructions from [offset] until the buffer ends, [count] is
  /// reached, or a byte sequence cannot be decoded.
  ///
  /// [address] is the virtual address of `code[offset]`. An empty list
  /// means nothing at that position decoded.
  List<IasmInsn> disassemble(
    Uint8List code, {
    int address = 0,
    int offset = 0,
    int? count,
  }) {
    _check(code, address, offset, count);
    if (count == 0) return const <IasmInsn>[];
    final out = <IasmInsn>[];
    var cursor = offset;
    var ip = address;
    while (cursor < code.length) {
      if (count != null && out.length >= count) break;
      try {
        final insn = decodeX86(
          code: code,
          offset: cursor,
          address: ip,
          is64: mode == IasmMode.mode64,
        );
        out.add(insn);
        cursor += insn.size;
        ip += insn.size;
      } on IasmDecodeException {
        break;
      }
    }
    return out;
  }

  void _check(Uint8List code, int address, int offset, int? count) {
    if (offset < 0 || offset > code.length) {
      throw ArgumentError.value(offset, 'offset');
    }
    if (address < 0) {
      throw ArgumentError.value(address, 'address');
    }
    if (count != null && count < 0) {
      throw ArgumentError.value(count, 'count');
    }
  }
}
