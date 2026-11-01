/// CPU family understood by `Iasm`.
enum IasmArch {
  /// Intel / AMD x86.
  x86,
}

/// Instruction-set mode for [IasmArch.x86].
enum IasmMode {
  /// 32-bit protected mode. An address-size override (`67`) selects
  /// 16-bit addressing.
  mode32,

  /// Long mode. Operand size defaults to 32 bits; `REX.W` selects 64.
  mode64,
}
