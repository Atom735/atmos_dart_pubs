import 'dart:typed_data';

import 'package:atmos_iasm/atmos_iasm.dart';
import 'package:test/test.dart';

IasmInsn one(
  List<int> bytes, {
  IasmMode mode = IasmMode.mode64,
  int address = 0,
}) {
  return Iasm(mode: mode).decode(
    Uint8List.fromList(bytes),
    address: address,
  );
}

void expectText(
  List<int> bytes,
  String text, {
  IasmMode mode = IasmMode.mode64,
  int address = 0,
}) {
  final insn = one(bytes, mode: mode, address: address);
  expect(insn.text, text);
  expect(insn.size, bytes.length);
  expect(insn.bytes, bytes);
}

void main() {
  test('prologue and relative call', () {
    final iasm = Iasm(mode: IasmMode.mode64);
    final code = Uint8List.fromList([
      0x55,
      0x48,
      0x89,
      0xE5,
      0x48,
      0x83,
      0xEC,
      0x20,
      0xE8,
      0x00,
      0x00,
      0x00,
      0x00,
      0xC3,
    ]);
    final insns = iasm.disassemble(code, address: 0x401000);
    expect(
      insns.map((insn) => insn.text).toList(),
      [
        'push rbp',
        'mov rbp, rsp',
        'sub rsp, 0x20',
        'call 0x40100d',
        'ret',
      ],
    );
    expect(insns[3].operands.single.imm, 0x40100d);
    expect(insns[3].address, 0x401008);
  });

  test('stops before an unknown byte and honors count', () {
    final iasm = Iasm(mode: IasmMode.mode64);
    final code = Uint8List.fromList([0x90, 0x06, 0xC3]);
    expect(iasm.disassemble(code), hasLength(1));
    expect(iasm.disassemble(code).single.text, 'nop');
    expect(
      iasm
          .disassemble(
            Uint8List.fromList([0x90, 0x90]),
            address: 0x1000,
            count: 1,
          )
          .single
          .address,
      0x1000,
    );
    expect(
      iasm
          .decode(
            Uint8List.fromList([0x90, 0xC3]),
            address: 0x10,
            offset: 1,
          )
          .text,
      'ret',
    );
  });

  test('decode reports a truncated or unknown opcode', () {
    final iasm = Iasm(mode: IasmMode.mode64);
    expect(
      () => iasm.decode(Uint8List.fromList([0xE8, 0x00])),
      throwsA(isA<IasmDecodeException>()),
    );
    expect(
      () => iasm.decode(Uint8List.fromList([0x06])),
      throwsA(
        isA<IasmDecodeException>().having(
          (error) => error.message,
          'message',
          contains('64-bit'),
        ),
      ),
    );
    expect(
      () => iasm.decode(Uint8List.fromList([0x0F, 0x28])),
      throwsA(isA<IasmDecodeException>()),
    );
    expect(
      () => iasm.disassemble(Uint8List(0), count: -1),
      throwsArgumentError,
    );
  });

  test('integer data motion', () {
    expectText([0x90], 'nop');
    expectText([0x48, 0x90], 'nop');
    expectText([0xF3, 0x90], 'pause');
    expectText([0x48, 0x91], 'xchg rax, rcx');
    expectText([0x41, 0x90], 'xchg eax, r8d');
    expectText([0x66, 0x91], 'xchg ax, cx');
    expectText([0x31, 0xC0], 'xor eax, eax');
    expectText([0x48, 0x31, 0xC0], 'xor rax, rax');
    expectText([0x88, 0xE0], 'mov al, ah');
    expectText([0x40, 0x88, 0xE0], 'mov al, spl');
    expectText(
      [0xB8, 0x78, 0x56, 0x34, 0x12],
      'mov eax, 0x12345678',
    );
    expectText(
      [0x48, 0xB8, 0x01, 0, 0, 0, 0, 0, 0, 0],
      'mov rax, 0x1',
    );
    expectText([0x8B, 0x04, 0x24], 'mov eax, dword ptr [rsp]');
    expectText(
      [0x8B, 0x44, 0x24, 0x08],
      'mov eax, dword ptr [rsp + 0x8]',
    );
    expectText(
      [0x8B, 0x04, 0x88],
      'mov eax, dword ptr [rax + rcx*4]',
    );
    expectText(
      [0x8B, 0x40, 0xFF],
      'mov eax, dword ptr [rax - 0x1]',
    );
    expectText(
      [0x48, 0x8B, 0x05, 0, 0, 0, 0],
      'mov rax, qword ptr [rip]',
    );
    expectText(
      [0x48, 0x8D, 0x05, 0x10, 0, 0, 0],
      'lea rax, [rip + 0x10]',
    );
    expectText(
      [0x48, 0x8B, 0x04, 0x25, 0x10, 0, 0, 0],
      'mov rax, qword ptr [0x10]',
    );
    expectText(
      [0x64, 0x48, 0x8B, 0x04, 0x25, 0, 0, 0, 0],
      'mov rax, qword ptr fs:[0x0]',
    );
    expectText(
      [0xC7, 0x00, 0x78, 0x56, 0x34, 0x12],
      'mov dword ptr [rax], 0x12345678',
    );
    expectText([0x0F, 0xB6, 0xC0], 'movzx eax, al');
    expectText([0x48, 0x63, 0xC0], 'movsxd rax, eax');
    expectText([0x0F, 0x1F, 0x00], 'nop dword ptr [rax]');
  });

  test('alu, stack, and branches', () {
    expectText([0x48, 0x83, 0xC4, 0xF8], 'add rsp, -0x8');
    expectText([0x83, 0xF8, 0x00], 'cmp eax, 0x0');
    expectText(
      [0x48, 0x3D, 0xFF, 0xFF, 0xFF, 0xFF],
      'cmp rax, -0x1',
    );
    expectText([0x6A, 0xF0], 'push -0x10');
    expectText([0xFF, 0xC0], 'inc eax');
    expectText([0x48, 0xFF, 0xC0], 'inc rax');
    expectText([0xFF, 0xD0], 'call rax');
    expectText([0xFF, 0x10], 'call qword ptr [rax]');
    expectText([0xFF, 0x18], 'call far ptr [rax]');
    expectText([0xFF, 0x30], 'push qword ptr [rax]');
    expectText([0x8F, 0x00], 'pop qword ptr [rax]');
    expectText([0xE8, 0, 0, 0, 0], 'call 0x5');
    expectText(
      [0xE8, 0xFB, 0xFF, 0xFF, 0xFF],
      'call 0x0',
    );
    expectText(
      [0xE9, 0xFA, 0xFF, 0xFF, 0xFF],
      'jmp 0xffffffffffffffff',
    );
    expectText([0x74, 0x00], 'je 0x2');
    expectText([0xEB, 0xFE], 'jmp 0x0');
    expectText([0x75, 0x00], 'jne 0x2');
    expectText([0x7C, 0x00], 'jl 0x2');
    expectText([0x0F, 0x84, 0, 0, 0, 0], 'je 0x6');
    expectText([0x0F, 0x94, 0xC0], 'sete al');
    expectText([0x0F, 0x44, 0xC0], 'cmove eax, eax');
    expectText([0x48, 0x6B, 0xC0, 0x02], 'imul rax, rax, 0x2');
    expectText([0xE3, 0x00], 'jrcxz 0x2');
    expectText([0x67, 0xE3, 0x00], 'jecxz 0x3');
  });

  test('system, string, and atomic forms', () {
    expectText([0xC3], 'ret');
    expectText([0xC2, 0x08, 0x00], 'ret 0x8');
    expectText([0xCC], 'int3');
    expectText([0xCD, 0x80], 'int 0x80');
    expectText([0x0F, 0x05], 'syscall');
    expectText([0x0F, 0x0B], 'ud2');
    expectText([0x0F, 0xA2], 'cpuid');
    expectText([0xF3, 0x0F, 0x1E, 0xFA], 'endbr64');
    expectText([0xF3, 0xA4], 'rep movsb');
    expectText([0xF3, 0x48, 0xA5], 'rep movsq');
    expectText([0x48, 0xF3, 0xA5], 'rep movsd');
    expectText([0x48, 0xA5], 'movsq');
    expectText(
      [0xF0, 0x48, 0x87, 0x04, 0x24],
      'lock xchg qword ptr [rsp], rax',
    );
    expectText([0xF6, 0xC0, 0x01], 'test al, 0x1');
    expectText([0x0F, 0xC8], 'bswap eax');
    expectText([0x48, 0x0F, 0xC8], 'bswap rax');
    expectText([0xF3, 0x0F, 0xB8, 0xC0], 'popcnt eax, eax');
    expectText([0x0F, 0xA4, 0xC8, 0x04], 'shld eax, ecx, 0x4');
    expectText([0x0F, 0xBA, 0xE0, 0x03], 'bt eax, 0x3');
    expectText([0xC9], 'leave');
    expectText([0xF4], 'hlt');
  });

  test('32-bit mode uses 32-bit names', () {
    expectText([0x55], 'push ebp', mode: IasmMode.mode32);
    expectText([0x89, 0xE5], 'mov ebp, esp', mode: IasmMode.mode32);
    expectText(
      [0x83, 0xEC, 0x10],
      'sub esp, 0x10',
      mode: IasmMode.mode32,
    );
    expectText([0x06], 'push es', mode: IasmMode.mode32);
    expectText([0x60], 'pushad', mode: IasmMode.mode32);
    expectText([0xFF, 0xD0], 'call eax', mode: IasmMode.mode32);
    expectText(
      [0x67, 0x8B, 0x00],
      'mov eax, dword ptr [bx + si]',
      mode: IasmMode.mode32,
    );
    expectText([0x63, 0xC0], 'arpl ax, ax', mode: IasmMode.mode32);
    expectText(
      [0xF3, 0x0F, 0x1E, 0xFB],
      'endbr32',
      mode: IasmMode.mode32,
    );
    expectText([0xE3, 0x00], 'jecxz 0x2', mode: IasmMode.mode32);
  });

  test('rip-relative operand keeps the displacement', () {
    final insn = one([0x48, 0x8D, 0x05, 0x10, 0, 0, 0]);
    final mem = insn.operands[1].mem;
    expect(mem, isNotNull);
    expect(mem!.ripRelative, isTrue);
    expect(mem.disp, 0x10);
    expect(insn.operands[0].reg!.name, 'rax');
  });
}
