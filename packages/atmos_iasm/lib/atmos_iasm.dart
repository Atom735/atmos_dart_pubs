/// x86 disassembler with a small Capstone-like API.
///
/// ## ENG
/// Decodes 32-bit and 64-bit Intel syntax: general-purpose integer
/// instructions, branches, and a few system opcodes (`syscall`,
/// `endbr64`). SSE, AVX, x87, and other CPU families are not decoded.
///
/// ## RU
/// Разбирает 32- и 64-битный Intel-синтаксис: целочисленные инструкции
/// общего назначения, переходы и несколько системных опкодов
/// (`syscall`, `endbr64`). SSE, AVX, x87 и другие семейства CPU не
/// разбираются.
library atmos_iasm;

export 'src/arch.dart';
export 'src/engine.dart';
export 'src/insn.dart';
