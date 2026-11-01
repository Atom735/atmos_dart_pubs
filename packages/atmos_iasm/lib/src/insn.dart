import 'dart:typed_data';

/// Failure while decoding a single instruction.
class IasmDecodeException implements Exception {
  /// [offset] is the index of the instruction's first byte.
  /// [address] is the virtual address of that byte.
  IasmDecodeException({
    required this.offset,
    required this.address,
    required this.message,
  });

  /// Index into the buffer passed to the decoder.
  final int offset;

  /// Virtual address of [offset].
  final int address;

  /// English reason, suitable for logs.
  final String message;

  @override
  String toString() {
    final hex = address.toRadixString(16);
    return 'IasmDecodeException at 0x$hex: $message';
  }
}

/// Kind of one instruction operand.
enum IasmOpType {
  /// A register, including segment registers.
  reg,

  /// An immediate or a resolved branch target.
  imm,

  /// A memory operand.
  mem,
}

/// Register named in an operand.
class IasmReg {
  /// [index] is the encoding number, 0 through 15.
  /// For an 8-bit register without a REX prefix, 4 is `ah`, not `spl`.
  const IasmReg(this.name, this.index, this.bits);

  /// Intel name, lowercase (`rax`, `ah`, `fs`).
  final String name;

  /// Encoding index.
  final int index;

  /// Width in bits. Segment registers use 16.
  final int bits;

  @override
  String toString() => name;
}

/// Memory operand. [sizeBits] is 0 when the mnemonic does not size it
/// (`lea`, a far pointer).
class IasmMem {
  /// [text] is the Intel rendering, including `dword ptr` when sized.
  const IasmMem({
    required this.text,
    required this.sizeBits,
    this.base,
    this.index,
    this.scale = 1,
    this.disp = 0,
    this.segment,
    this.ripRelative = false,
  });

  /// Full operand text.
  final String text;

  /// Access size. Zero means the instruction does not size the memory.
  final int sizeBits;

  /// Base register, if any.
  final IasmReg? base;

  /// Index register, if any.
  final IasmReg? index;

  /// Scale applied to [index]. 1, 2, 4, or 8.
  final int scale;

  /// Displacement. RIP-relative values are signed.
  final int disp;

  /// Segment override (`fs`, `gs`, …), if the encoding had one.
  final String? segment;

  /// True when the base is `rip` (64-bit, mod 0 rm 5).
  final bool ripRelative;

  @override
  String toString() => text;
}

/// One operand of an [IasmInsn].
class IasmOperand {
  /// Register operand. [text] is [reg]'s name.
  const IasmOperand.reg(this.reg)
      : type = IasmOpType.reg,
        imm = null,
        mem = null,
        unsignedBits = null;

  /// Immediate. Negative values render as `-0x…`.
  ///
  /// [unsignedBits] prints [imm] as an unsigned address of that width.
  /// Branch targets use it so a high bit does not show up as a minus.
  const IasmOperand.imm(this.imm, {this.unsignedBits})
      : type = IasmOpType.imm,
        reg = null,
        mem = null;

  /// Memory operand. [text] comes from [mem].
  const IasmOperand.mem(this.mem)
      : type = IasmOpType.mem,
        reg = null,
        imm = null,
        unsignedBits = null;

  /// Operand kind.
  final IasmOpType type;

  /// Set when [type] is [IasmOpType.reg].
  final IasmReg? reg;

  /// Set when [type] is [IasmOpType.imm].
  ///
  /// Branch instructions store the target address, not the displacement.
  /// A 64-bit target with the high bit set is negative; [text] prints
  /// the unsigned address.
  final int? imm;

  /// When set, [text] is the unsigned hex form of the low [unsignedBits].
  final int? unsignedBits;

  /// Set when [type] is [IasmOpType.mem].
  final IasmMem? mem;

  /// Intel rendering of this operand.
  String get text {
    switch (type) {
      case IasmOpType.reg:
        return reg!.name;
      case IasmOpType.imm:
        return _formatImm(imm!, unsignedBits);
      case IasmOpType.mem:
        return mem!.text;
    }
  }

  @override
  String toString() => text;
}

/// One decoded instruction.
class IasmInsn {
  /// [bytes] is a copy of the encoded instruction.
  IasmInsn({
    required this.address,
    required this.size,
    required this.bytes,
    required this.mnemonic,
    required List<IasmOperand> operands,
  }) : operands = List<IasmOperand>.unmodifiable(operands);

  /// Virtual address of the first byte.
  final int address;

  /// Encoded length in bytes.
  final int size;

  /// Copy of the encoded bytes.
  final Uint8List bytes;

  /// Mnemonic, with `lock` / `rep` / `repne` already included.
  final String mnemonic;

  /// Operands in Intel order.
  final List<IasmOperand> operands;

  /// Operands joined by `, `.
  String get opStr => operands.map((op) => op.text).join(', ');

  /// `mnemonic` plus [opStr] when the instruction has operands.
  String get text {
    if (opStr.isEmpty) return mnemonic;
    return '$mnemonic $opStr';
  }

  @override
  String toString() {
    final hex = address.toRadixString(16);
    return '0x$hex: $text';
  }
}

String _formatImm(int value, int? unsignedBits) {
  if (unsignedBits != null) {
    final mask = (BigInt.one << unsignedBits) - BigInt.one;
    final bits = BigInt.from(value) & mask;
    return '0x${bits.toRadixString(16)}';
  }
  if (value < 0) {
    return '-0x${(-value).toRadixString(16)}';
  }
  return '0x${value.toRadixString(16)}';
}
