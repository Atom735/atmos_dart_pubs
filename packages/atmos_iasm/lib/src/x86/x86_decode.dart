part of 'x86.dart';

const _r64 = <String>[
  'rax',
  'rcx',
  'rdx',
  'rbx',
  'rsp',
  'rbp',
  'rsi',
  'rdi',
  'r8',
  'r9',
  'r10',
  'r11',
  'r12',
  'r13',
  'r14',
  'r15',
];

const _r32 = <String>[
  'eax',
  'ecx',
  'edx',
  'ebx',
  'esp',
  'ebp',
  'esi',
  'edi',
  'r8d',
  'r9d',
  'r10d',
  'r11d',
  'r12d',
  'r13d',
  'r14d',
  'r15d',
];

const _r16 = <String>[
  'ax',
  'cx',
  'dx',
  'bx',
  'sp',
  'bp',
  'si',
  'di',
  'r8w',
  'r9w',
  'r10w',
  'r11w',
  'r12w',
  'r13w',
  'r14w',
  'r15w',
];

const _r8 = <String>[
  'al',
  'cl',
  'dl',
  'bl',
  'ah',
  'ch',
  'dh',
  'bh',
];

const _r8x = <String>[
  'al',
  'cl',
  'dl',
  'bl',
  'spl',
  'bpl',
  'sil',
  'dil',
  'r8b',
  'r9b',
  'r10b',
  'r11b',
  'r12b',
  'r13b',
  'r14b',
  'r15b',
];

const _cc = <String>[
  'o',
  'no',
  'b',
  'ae',
  'e',
  'ne',
  'be',
  'a',
  's',
  'ns',
  'p',
  'np',
  'l',
  'ge',
  'le',
  'g',
];

const _alu = <String>[
  'add',
  'or',
  'adc',
  'sbb',
  'and',
  'sub',
  'xor',
  'cmp',
];

const _shifts = <String>[
  'rol',
  'ror',
  'rcl',
  'rcr',
  'shl',
  'shr',
  'sal',
  'sar',
];

enum _Count { one, cl, imm }

class _Mod {
  bool isReg = false;
  int reg = 0;
  int regLow = 0;
  int rm = 0;
  IasmReg? base;
  IasmReg? index;
  int scale = 1;
  int disp = 0;
  bool rip = false;
}

class _X86Decoder {
  _X86Decoder({
    required this.code,
    required int offset,
    required this.address,
    required this.is64,
  })  : start = offset,
        _offset = offset,
        _data = ByteData.sublistView(code);

  final Uint8List code;
  final ByteData _data;
  final int start;
  final int address;
  final bool is64;

  int _offset;
  int _rex = 0;
  int _segment = 0;
  bool _lock = false;
  bool _rep = false;
  bool _repne = false;
  bool _os66 = false;
  bool _as67 = false;
  bool _ready = false;
  late String _mnemonic;
  late List<IasmOperand> _ops;
  late _Mod _mod;

  bool get _rexW => (_rex & 0x8) != 0;
  bool get _rexR => (_rex & 0x4) != 0;
  bool get _rexX => (_rex & 0x2) != 0;
  bool get _rexB => (_rex & 0x1) != 0;

  int get _operandBits {
    if (_rexW) return 64;
    if (_os66) return 16;
    return 32;
  }

  int get _stackBits {
    if (_os66) return 16;
    if (is64) return 64;
    return 32;
  }

  int get _nearBits => is64 ? 64 : _operandBits;

  int get _addrBits {
    if (is64) return _as67 ? 32 : 64;
    return _as67 ? 16 : 32;
  }

  IasmInsn run() {
    _prefixes();
    _opcode();
    if (!_ready) _fail('Incomplete decode.');
    return IasmInsn(
      address: address,
      size: _offset - start,
      bytes: code.sublist(start, _offset),
      mnemonic: _mnemonic,
      operands: _ops,
    );
  }

  Never _fail(String message) {
    throw IasmDecodeException(
      offset: start,
      address: address,
      message: message,
    );
  }

  void _prefixes() {
    while (_offset < code.length) {
      final b = code[_offset];
      if (_legacy(b)) {
        _takeLegacy(b);
        _offset += 1;
        _rex = 0;
        continue;
      }
      if (is64 && b >= 0x40 && b <= 0x4F) {
        _rex = b;
        _offset += 1;
        continue;
      }
      break;
    }
  }

  bool _legacy(int b) {
    switch (b) {
      case 0xF0:
      case 0xF2:
      case 0xF3:
      case 0x66:
      case 0x67:
      case 0x26:
      case 0x2E:
      case 0x36:
      case 0x3E:
      case 0x64:
      case 0x65:
        return true;
      default:
        return false;
    }
  }

  void _takeLegacy(int b) {
    switch (b) {
      case 0xF0:
        _lock = true;
      case 0xF2:
        _repne = true;
        _rep = false;
      case 0xF3:
        _rep = true;
        _repne = false;
      case 0x66:
        _os66 = true;
      case 0x67:
        _as67 = true;
      case 0x26:
      case 0x2E:
      case 0x36:
      case 0x3E:
      case 0x64:
      case 0x65:
        _segment = b;
      default:
        break;
    }
  }

  void _finish(
    String name,
    List<IasmOperand> ops, {
    bool repPrefix = true,
  }) {
    final text = StringBuffer();
    if (_lock) text.write('lock ');
    if (repPrefix && _rep) text.write('rep ');
    if (repPrefix && _repne) text.write('repne ');
    text.write(name);
    _mnemonic = text.toString();
    _ops = ops;
    _ready = true;
  }

  int _u8() {
    if (_offset >= code.length) _fail('Truncated instruction.');
    final value = code[_offset];
    _offset += 1;
    return value;
  }

  void _need(int n) {
    if (_offset + n > code.length) _fail('Truncated instruction.');
  }

  int _u16() {
    _need(2);
    final value = _data.getUint16(_offset, Endian.little);
    _offset += 2;
    return value;
  }

  int _u32() {
    _need(4);
    final value = _data.getUint32(_offset, Endian.little);
    _offset += 4;
    return value;
  }

  int _u64() {
    _need(8);
    final value = _data.getUint64(_offset, Endian.little);
    _offset += 8;
    return value;
  }

  int _i8() {
    final value = _u8();
    if (value >= 0x80) return value - 0x100;
    return value;
  }

  int _i16() {
    final value = _u16();
    if (value >= 0x8000) return value - 0x10000;
    return value;
  }

  int _i32() {
    final value = _u32();
    if (value >= 0x80000000) return value - 0x100000000;
    return value;
  }

  int _immSe() {
    final bits = _operandBits;
    if (bits == 16) return _u16();
    if (bits == 64) return _i32();
    return _u32();
  }

  int _relNear() {
    if (!is64 && _os66) return _i16();
    return _i32();
  }

  int _target(int disp) {
    final next = address + (_offset - start);
    final raw = next + disp;
    if (!is64) return raw & 0xFFFFFFFF;
    return raw;
  }

  IasmOperand _branch(int disp) {
    return IasmOperand.imm(
      _target(disp),
      unsignedBits: is64 ? 64 : 32,
    );
  }

  int _addrImm() {
    switch (_addrBits) {
      case 16:
        return _u16();
      case 32:
        return _u32();
      default:
        return _u64();
    }
  }

  String _regName(int index, int bits) {
    if (index < 0 || index > 15) {
      return _fail('Bad register index.');
    }
    final rex = _rex != 0;
    switch (bits) {
      case 8:
        if (!rex && index < 8) return _r8[index];
        return _r8x[index];
      case 16:
        return _r16[index];
      case 32:
        return _r32[index];
      case 64:
        return _r64[index];
      default:
        return _fail('Bad register width.');
    }
  }

  IasmReg _named(int index, int bits) {
    return IasmReg(_regName(index, bits), index, bits);
  }

  IasmOperand _regOp(int index, int bits) {
    return IasmOperand.reg(_named(index, bits));
  }

  IasmOperand _immOp(int value) => IasmOperand.imm(value);

  IasmOperand _sreg(int index) {
    const names = ['es', 'cs', 'ss', 'ds', 'fs', 'gs'];
    if (index < 0 || index > 5) {
      _fail('Invalid segment register.');
    }
    return IasmOperand.reg(IasmReg(names[index], index, 16));
  }

  String? get _segName {
    switch (_segment) {
      case 0x26:
        return 'es';
      case 0x2E:
        return 'cs';
      case 0x36:
        return 'ss';
      case 0x3E:
        return 'ds';
      case 0x64:
        return 'fs';
      case 0x65:
        return 'gs';
      default:
        return null;
    }
  }

  String _sizeWord(int bits) {
    switch (bits) {
      case 8:
        return 'byte';
      case 16:
        return 'word';
      case 32:
        return 'dword';
      case 64:
        return 'qword';
      default:
        return _fail('Bad operand size.');
    }
  }

  String _hex(int value) => '0x${value.toRadixString(16)}';

  String _formatMem({
    required int sizeBits,
    required bool showSize,
  }) {
    final chunks = <String>[];
    if (_mod.rip) {
      chunks.add('rip');
    } else {
      final base = _mod.base;
      final index = _mod.index;
      if (base != null) chunks.add(base.name);
      if (index != null) {
        if (_mod.scale == 1) {
          chunks.add(index.name);
        } else {
          chunks.add('${index.name}*${_mod.scale}');
        }
      }
    }
    final disp = _mod.disp;
    var body = chunks.join(' + ');
    if (disp != 0 || chunks.isEmpty) {
      if (chunks.isEmpty) {
        body = _hex(disp);
      } else if (disp < 0) {
        body = '$body - ${_hex(-disp)}';
      } else {
        body = '$body + ${_hex(disp)}';
      }
    }
    final seg = _segName;
    final bracket = seg == null ? '[$body]' : '$seg:[$body]';
    if (!showSize) return bracket;
    return '${_sizeWord(sizeBits)} ptr $bracket';
  }

  IasmOperand _rm(int bits, {bool bare = false}) {
    if (_mod.isReg) return _regOp(_mod.rm, bits);
    return IasmOperand.mem(
      IasmMem(
        text: _formatMem(sizeBits: bits, showSize: !bare),
        sizeBits: bare ? 0 : bits,
        base: _mod.base,
        index: _mod.index,
        scale: _mod.scale,
        disp: _mod.disp,
        segment: _segName,
        ripRelative: _mod.rip,
      ),
    );
  }

  IasmOperand _farMem() {
    final inner = _formatMem(sizeBits: 32, showSize: false);
    return IasmOperand.mem(
      IasmMem(
        text: 'far ptr $inner',
        sizeBits: 0,
        base: _mod.base,
        index: _mod.index,
        scale: _mod.scale,
        disp: _mod.disp,
        segment: _segName,
        ripRelative: _mod.rip,
      ),
    );
  }

  IasmOperand _absolute(int bits, int addr) {
    final seg = _segName;
    final at = _hex(addr);
    final bracket = seg == null ? '[$at]' : '$seg:[$at]';
    return IasmOperand.mem(
      IasmMem(
        text: '${_sizeWord(bits)} ptr $bracket',
        sizeBits: bits,
        disp: addr,
        segment: seg,
      ),
    );
  }

  void _readModrm() {
    final b = _u8();
    _mod = _Mod();
    _mod.regLow = (b >> 3) & 7;
    _mod.reg = _mod.regLow | (_rexR ? 8 : 0);
    final mod = b >> 6;
    final rmLow = b & 7;
    if (_addrBits == 16) {
      _read16(mod, rmLow);
      return;
    }
    if (mod == 3) {
      _mod.isReg = true;
      _mod.rm = rmLow | (_rexB ? 8 : 0);
      return;
    }
    if (rmLow == 4) {
      _readSib(mod);
      return;
    }
    if (mod == 0 && rmLow == 5) {
      _readAbsOrRip();
      return;
    }
    _mod.base = _named(rmLow | (_rexB ? 8 : 0), _addrBits);
    if (mod == 1) _mod.disp = _i8();
    if (mod == 2) _mod.disp = _i32();
  }

  void _readAbsOrRip() {
    final raw = _u32();
    if (is64 && _addrBits == 64) {
      _mod.rip = true;
      _mod.disp = raw >= 0x80000000 ? raw - 0x100000000 : raw;
      return;
    }
    _mod.disp = raw;
  }

  void _readSib(int mod) {
    final sib = _u8();
    _mod.scale = 1 << (sib >> 6);
    final indexLow = (sib >> 3) & 7;
    final baseLow = sib & 7;
    if (!(indexLow == 4 && !_rexX)) {
      final index = indexLow | (_rexX ? 8 : 0);
      _mod.index = _named(index, _addrBits);
    }
    if (baseLow == 5 && mod == 0) {
      _mod.disp = _u32();
      return;
    }
    final base = baseLow | (_rexB ? 8 : 0);
    _mod.base = _named(base, _addrBits);
    if (mod == 1) _mod.disp = _i8();
    if (mod == 2) _mod.disp = _i32();
  }

  void _read16(int mod, int rm) {
    if (mod == 3) {
      _mod.isReg = true;
      _mod.rm = rm;
      return;
    }
    if (mod == 0 && rm == 6) {
      _mod.disp = _u16();
      return;
    }
    switch (rm) {
      case 0:
        _mod.base = _named(3, 16);
        _mod.index = _named(6, 16);
      case 1:
        _mod.base = _named(3, 16);
        _mod.index = _named(7, 16);
      case 2:
        _mod.base = _named(5, 16);
        _mod.index = _named(6, 16);
      case 3:
        _mod.base = _named(5, 16);
        _mod.index = _named(7, 16);
      case 4:
        _mod.base = _named(6, 16);
      case 5:
        _mod.base = _named(7, 16);
      case 6:
        _mod.base = _named(5, 16);
      case 7:
        _mod.base = _named(3, 16);
      default:
        _fail('Bad 16-bit addressing.');
    }
    if (mod == 1) _mod.disp = _i8();
    if (mod == 2) _mod.disp = _i16();
  }

  void _opcode() {
    final op = _u8();
    if (op == 0x0F) {
      _twobyte();
      return;
    }
    if (op <= 0x3F) {
      _low(op);
      return;
    }
    if (op <= 0x4F) {
      _incDec(op);
      return;
    }
    if (op <= 0x5F) {
      _pushPopReg(op);
      return;
    }
    if (op <= 0x6F) {
      _sixty(op);
      return;
    }
    if (op <= 0x7F) {
      _finish('j${_cc[op & 0xF]}', [_branch(_i8())]);
      return;
    }
    if (op <= 0x8F) {
      _eighty(op);
      return;
    }
    if (op <= 0x9F) {
      _ninety(op);
      return;
    }
    if (op <= 0xAF) {
      _a0(op);
      return;
    }
    if (op <= 0xBF) {
      _movImmReg(op);
      return;
    }
    if (op <= 0xCF) {
      _c0(op);
      return;
    }
    if (op <= 0xDF) {
      _d0(op);
      return;
    }
    if (op <= 0xEF) {
      _e0(op);
      return;
    }
    _f0(op);
  }

  void _low(int op) {
    switch (op) {
      case 0x06:
      case 0x07:
      case 0x0E:
      case 0x16:
      case 0x17:
      case 0x1E:
      case 0x1F:
        if (is64) {
          _fail('Segment push or pop is invalid in 64-bit mode.');
        }
        _legacySeg(op);
      case 0x27:
      case 0x2F:
      case 0x37:
      case 0x3F:
        if (is64) {
          _fail('Decimal adjust is invalid in 64-bit mode.');
        }
        _adjust(op);
      default:
        _aluOp(op);
    }
  }

  void _legacySeg(int op) {
    switch (op) {
      case 0x06:
        _finish('push', [_sreg(0)]);
      case 0x07:
        _finish('pop', [_sreg(0)]);
      case 0x0E:
        _finish('push', [_sreg(1)]);
      case 0x16:
        _finish('push', [_sreg(2)]);
      case 0x17:
        _finish('pop', [_sreg(2)]);
      case 0x1E:
        _finish('push', [_sreg(3)]);
      case 0x1F:
        _finish('pop', [_sreg(3)]);
      default:
        _fail('Bad segment opcode.');
    }
  }

  void _adjust(int op) {
    switch (op) {
      case 0x27:
        _finish('daa', []);
      case 0x2F:
        _finish('das', []);
      case 0x37:
        _finish('aaa', []);
      case 0x3F:
        _finish('aas', []);
      default:
        _fail('Bad decimal opcode.');
    }
  }

  void _aluOp(int op) {
    final name = _alu[op >> 3];
    final form = op & 7;
    if (form == 4) {
      _finish(name, [_regOp(0, 8), _immOp(_u8())]);
      return;
    }
    if (form == 5) {
      final bits = _operandBits;
      _finish(name, [_regOp(0, bits), _immOp(_immSe())]);
      return;
    }
    _readModrm();
    final bits = (form == 0 || form == 2) ? 8 : _operandBits;
    final rm = _rm(bits);
    final reg = _regOp(_mod.reg, bits);
    if (form <= 1) {
      _finish(name, [rm, reg]);
    } else {
      _finish(name, [reg, rm]);
    }
  }

  void _incDec(int op) {
    if (is64) {
      _fail('INC and DEC via 0x40 are REX prefixes in 64-bit mode.');
    }
    final name = op < 0x48 ? 'inc' : 'dec';
    _finish(name, [_regOp(op & 7, _operandBits)]);
  }

  void _pushPopReg(int op) {
    final name = op < 0x58 ? 'push' : 'pop';
    final index = (op & 7) | (_rexB ? 8 : 0);
    _finish(name, [_regOp(index, _stackBits)]);
  }

  void _sixty(int op) {
    switch (op) {
      case 0x60:
        _pusha(false);
      case 0x61:
        _pusha(true);
      case 0x62:
        _fail('VEX, EVEX, and LES/LDS/BOUND are not supported.');
      case 0x63:
        _movsxdOrArpl();
      case 0x68:
        _finish('push', [_immOp(_pushImm())]);
      case 0x69:
        _imulImm(false);
      case 0x6A:
        _finish('push', [_immOp(_i8())]);
      case 0x6B:
        _imulImm(true);
      case 0x6C:
        _finish('insb', []);
      case 0x6D:
        _finish(_ioStem('ins'), []);
      case 0x6E:
        _finish('outsb', []);
      case 0x6F:
        _finish(_ioStem('outs'), []);
      default:
        _fail('Unknown opcode 0x${op.toRadixString(16)}.');
    }
  }

  int _pushImm() {
    if (_os66) return _i16();
    if (is64) return _i32();
    return _u32();
  }

  void _pusha(bool pop) {
    if (is64) {
      final name = pop ? 'popa' : 'pusha';
      _fail('$name is invalid in 64-bit mode.');
    }
    if (_os66) {
      _finish(pop ? 'popa' : 'pusha', []);
    } else {
      _finish(pop ? 'popad' : 'pushad', []);
    }
  }

  void _movsxdOrArpl() {
    _readModrm();
    if (!is64) {
      _finish('arpl', [_rm(16), _regOp(_mod.reg, 16)]);
      return;
    }
    final dest = _rexW ? 64 : _operandBits;
    _finish('movsxd', [_regOp(_mod.reg, dest), _rm(32)]);
  }

  void _imulImm(bool small) {
    _readModrm();
    final imm = small ? _i8() : _immSe();
    _finish('imul', [
      _regOp(_mod.reg, _operandBits),
      _rm(_operandBits),
      _immOp(imm),
    ]);
  }

  String _ioStem(String stem) {
    if (_os66) return '${stem}w';
    return '${stem}d';
  }

  String _sized(String stem) {
    switch (_operandBits) {
      case 16:
        return '${stem}w';
      case 64:
        return '${stem}q';
      default:
        return '${stem}d';
    }
  }

  String _flagOp(String stem) {
    if (_os66) return '${stem}w';
    if (is64) return '${stem}q';
    return '${stem}d';
  }

  void _eighty(int op) {
    switch (op) {
      case 0x80:
        _group1(0);
      case 0x81:
        _group1(1);
      case 0x82:
        if (is64) _fail('Opcode 0x82 is invalid in 64-bit mode.');
        _group1(0);
      case 0x83:
        _group1(3);
      case 0x84:
        _rr('test', byte: true, rmFirst: true);
      case 0x85:
        _rr('test', byte: false, rmFirst: true);
      case 0x86:
        _rr('xchg', byte: true, rmFirst: true);
      case 0x87:
        _rr('xchg', byte: false, rmFirst: true);
      case 0x88:
        _rr('mov', byte: true, rmFirst: true);
      case 0x89:
        _rr('mov', byte: false, rmFirst: true);
      case 0x8A:
        _rr('mov', byte: true, rmFirst: false);
      case 0x8B:
        _rr('mov', byte: false, rmFirst: false);
      case 0x8C:
        _movSreg(false);
      case 0x8D:
        _lea();
      case 0x8E:
        _movSreg(true);
      case 0x8F:
        _popRm();
      default:
        _fail('Unknown opcode 0x${op.toRadixString(16)}.');
    }
  }

  void _group1(int kind) {
    _readModrm();
    final name = _alu[_mod.regLow];
    final byte = kind == 0;
    final bits = byte ? 8 : _operandBits;
    final imm = kind == 3
        ? _i8()
        : byte
            ? _u8()
            : _immSe();
    _finish(name, [_rm(bits), _immOp(imm)]);
  }

  void _rr(String name, {required bool byte, required bool rmFirst}) {
    _readModrm();
    final bits = byte ? 8 : _operandBits;
    final rm = _rm(bits);
    final reg = _regOp(_mod.reg, bits);
    if (rmFirst) {
      _finish(name, [rm, reg]);
    } else {
      _finish(name, [reg, rm]);
    }
  }

  void _movSreg(bool toSreg) {
    _readModrm();
    final seg = _sreg(_mod.regLow);
    if (toSreg) {
      _finish('mov', [seg, _rm(16)]);
    } else {
      _finish('mov', [_rm(_operandBits), seg]);
    }
  }

  void _lea() {
    _readModrm();
    if (_mod.isReg) _fail('lea requires a memory operand.');
    _finish('lea', [
      _regOp(_mod.reg, _operandBits),
      _rm(_operandBits, bare: true),
    ]);
  }

  void _popRm() {
    _readModrm();
    if (_mod.regLow != 0) {
      _fail('Invalid opcode extension ${_mod.regLow}.');
    }
    _finish('pop', [_rm(_stackBits)]);
  }

  void _ninety(int op) {
    if (op <= 0x97) {
      _xchgAx((op & 7) | (_rexB ? 8 : 0));
      return;
    }
    switch (op) {
      case 0x98:
        _finish(_extend(false), []);
      case 0x99:
        _finish(_extend(true), []);
      case 0x9A:
      case 0xEA:
        _fail('Absolute far branch is not supported.');
      case 0x9B:
        _finish('wait', []);
      case 0x9C:
        _finish(_flagOp('pushf'), []);
      case 0x9D:
        _finish(_flagOp('popf'), []);
      case 0x9E:
        _finish('sahf', []);
      case 0x9F:
        _finish('lahf', []);
      default:
        _fail('Unknown opcode 0x${op.toRadixString(16)}.');
    }
  }

  void _xchgAx(int index) {
    final bits = _operandBits;
    if (index == 0 && _rep && !_repne) {
      _finish('pause', [], repPrefix: false);
      return;
    }
    if (index == 0) {
      _finish('nop', []);
      return;
    }
    _finish('xchg', [_regOp(0, bits), _regOp(index, bits)]);
  }

  String _extend(bool high) {
    if (_rexW) return high ? 'cqo' : 'cdqe';
    if (_os66) return high ? 'cwd' : 'cbw';
    return high ? 'cdq' : 'cwde';
  }

  void _a0(int op) {
    switch (op) {
      case 0xA0:
        _moffs(toMem: false, byte: true);
      case 0xA1:
        _moffs(toMem: false, byte: false);
      case 0xA2:
        _moffs(toMem: true, byte: true);
      case 0xA3:
        _moffs(toMem: true, byte: false);
      case 0xA4:
        _finish('movsb', []);
      case 0xA5:
        _finish(_sized('movs'), []);
      case 0xA6:
        _finish('cmpsb', []);
      case 0xA7:
        _finish(_sized('cmps'), []);
      case 0xA8:
        _finish('test', [_regOp(0, 8), _immOp(_u8())]);
      case 0xA9:
        _finish('test', [_regOp(0, _operandBits), _immOp(_immSe())]);
      case 0xAA:
        _finish('stosb', []);
      case 0xAB:
        _finish(_sized('stos'), []);
      case 0xAC:
        _finish('lodsb', []);
      case 0xAD:
        _finish(_sized('lods'), []);
      case 0xAE:
        _finish('scasb', []);
      case 0xAF:
        _finish(_sized('scas'), []);
      default:
        _fail('Unknown opcode 0x${op.toRadixString(16)}.');
    }
  }

  void _moffs({required bool toMem, required bool byte}) {
    final bits = byte ? 8 : _operandBits;
    final mem = _absolute(bits, _addrImm());
    final reg = _regOp(0, bits);
    if (toMem) {
      _finish('mov', [mem, reg]);
    } else {
      _finish('mov', [reg, mem]);
    }
  }

  void _movImmReg(int op) {
    final index = (op & 7) | (_rexB ? 8 : 0);
    if (op <= 0xB7) {
      _finish('mov', [_regOp(index, 8), _immOp(_u8())]);
      return;
    }
    final bits = _operandBits;
    final imm = bits == 64 ? _u64() : _immSe();
    _finish('mov', [_regOp(index, bits), _immOp(imm)]);
  }

  void _c0(int op) {
    switch (op) {
      case 0xC0:
        _shift(true, _Count.imm);
      case 0xC1:
        _shift(false, _Count.imm);
      case 0xC2:
        _finish('ret', [_immOp(_u16())]);
      case 0xC3:
        _finish('ret', []);
      case 0xC4:
      case 0xC5:
        _fail('VEX, EVEX, and LES/LDS/BOUND are not supported.');
      case 0xC6:
        _movImm(true);
      case 0xC7:
        _movImm(false);
      case 0xC8:
        final alloc = _u16();
        final level = _u8();
        _finish('enter', [_immOp(alloc), _immOp(level)]);
      case 0xC9:
        _finish('leave', []);
      case 0xCA:
        _finish('retf', [_immOp(_u16())]);
      case 0xCB:
        _finish('retf', []);
      case 0xCC:
        _finish('int3', []);
      case 0xCD:
        _finish('int', [_immOp(_u8())]);
      case 0xCE:
        if (is64) _fail('into is invalid in 64-bit mode.');
        _finish('into', []);
      case 0xCF:
        _finish(_flagOp('iret'), []);
      default:
        _fail('Unknown opcode 0x${op.toRadixString(16)}.');
    }
  }

  void _movImm(bool byte) {
    _readModrm();
    if (_mod.regLow != 0) {
      _fail('Invalid opcode extension ${_mod.regLow}.');
    }
    final bits = byte ? 8 : _operandBits;
    final imm = byte ? _u8() : _immSe();
    _finish('mov', [_rm(bits), _immOp(imm)]);
  }

  void _shift(bool byte, _Count count) {
    _readModrm();
    final bits = byte ? 8 : _operandBits;
    final ops = <IasmOperand>[_rm(bits)];
    switch (count) {
      case _Count.one:
        ops.add(_immOp(1));
      case _Count.cl:
        ops.add(_regOp(1, 8));
      case _Count.imm:
        ops.add(_immOp(_u8()));
    }
    _finish(_shifts[_mod.regLow], ops);
  }

  void _d0(int op) {
    switch (op) {
      case 0xD0:
        _shift(true, _Count.one);
      case 0xD1:
        _shift(false, _Count.one);
      case 0xD2:
        _shift(true, _Count.cl);
      case 0xD3:
        _shift(false, _Count.cl);
      case 0xD4:
        if (is64) _fail('aam is invalid in 64-bit mode.');
        _finish('aam', [_immOp(_u8())]);
      case 0xD5:
        if (is64) _fail('aad is invalid in 64-bit mode.');
        _finish('aad', [_immOp(_u8())]);
      case 0xD6:
        _fail('Unknown opcode 0xd6.');
      case 0xD7:
        _finish('xlatb', []);
      default:
        _fail('x87 instructions are not supported.');
    }
  }

  void _e0(int op) {
    switch (op) {
      case 0xE0:
        _finish('loopne', [_branch(_i8())]);
      case 0xE1:
        _finish('loope', [_branch(_i8())]);
      case 0xE2:
        _finish('loop', [_branch(_i8())]);
      case 0xE3:
        _finish(_jcxzName, [_branch(_i8())]);
      case 0xE4:
        _io(toPort: false, byte: true, dx: false);
      case 0xE5:
        _io(toPort: false, byte: false, dx: false);
      case 0xE6:
        _io(toPort: true, byte: true, dx: false);
      case 0xE7:
        _io(toPort: true, byte: false, dx: false);
      case 0xE8:
        _finish('call', [_branch(_relNear())]);
      case 0xE9:
        _finish('jmp', [_branch(_relNear())]);
      case 0xEA:
        _fail('Absolute far branch is not supported.');
      case 0xEB:
        _finish('jmp', [_branch(_i8())]);
      case 0xEC:
        _io(toPort: false, byte: true, dx: true);
      case 0xED:
        _io(toPort: false, byte: false, dx: true);
      case 0xEE:
        _io(toPort: true, byte: true, dx: true);
      case 0xEF:
        _io(toPort: true, byte: false, dx: true);
      default:
        _fail('Unknown opcode 0x${op.toRadixString(16)}.');
    }
  }

  String get _jcxzName {
    switch (_addrBits) {
      case 16:
        return 'jcxz';
      case 32:
        return 'jecxz';
      default:
        return 'jrcxz';
    }
  }

  void _io({
    required bool toPort,
    required bool byte,
    required bool dx,
  }) {
    final bits = byte ? 8 : _operandBits;
    final acc = _regOp(0, bits);
    final port = dx ? _regOp(2, 16) : _immOp(_u8());
    if (toPort) {
      _finish('out', [port, acc]);
    } else {
      _finish('in', [acc, port]);
    }
  }

  void _f0(int op) {
    switch (op) {
      case 0xF1:
        _finish('int1', []);
      case 0xF4:
        _finish('hlt', []);
      case 0xF5:
        _finish('cmc', []);
      case 0xF6:
        _group3(true);
      case 0xF7:
        _group3(false);
      case 0xF8:
        _finish('clc', []);
      case 0xF9:
        _finish('stc', []);
      case 0xFA:
        _finish('cli', []);
      case 0xFB:
        _finish('sti', []);
      case 0xFC:
        _finish('cld', []);
      case 0xFD:
        _finish('std', []);
      case 0xFE:
        _groupFe();
      case 0xFF:
        _groupFf();
      default:
        _fail('Unknown opcode 0x${op.toRadixString(16)}.');
    }
  }

  void _group3(bool byte) {
    _readModrm();
    final bits = byte ? 8 : _operandBits;
    switch (_mod.regLow) {
      case 0:
      case 1:
        final imm = byte ? _u8() : _immSe();
        _finish('test', [_rm(bits), _immOp(imm)]);
      case 2:
        _finish('not', [_rm(bits)]);
      case 3:
        _finish('neg', [_rm(bits)]);
      case 4:
        _finish('mul', [_rm(bits)]);
      case 5:
        _finish('imul', [_rm(bits)]);
      case 6:
        _finish('div', [_rm(bits)]);
      case 7:
        _finish('idiv', [_rm(bits)]);
      default:
        _fail('Invalid opcode extension ${_mod.regLow}.');
    }
  }

  void _groupFe() {
    _readModrm();
    switch (_mod.regLow) {
      case 0:
        _finish('inc', [_rm(8)]);
      case 1:
        _finish('dec', [_rm(8)]);
      default:
        _fail('Invalid opcode extension ${_mod.regLow}.');
    }
  }

  void _groupFf() {
    _readModrm();
    switch (_mod.regLow) {
      case 0:
        _finish('inc', [_rm(_operandBits)]);
      case 1:
        _finish('dec', [_rm(_operandBits)]);
      case 2:
        _finish('call', [_rm(_nearBits)]);
      case 3:
        if (_mod.isReg) _fail('call far needs a memory operand.');
        _finish('call', [_farMem()]);
      case 4:
        _finish('jmp', [_rm(_nearBits)]);
      case 5:
        if (_mod.isReg) _fail('jmp far needs a memory operand.');
        _finish('jmp', [_farMem()]);
      case 6:
        _finish('push', [_rm(_stackBits)]);
      default:
        _fail('Invalid opcode extension ${_mod.regLow}.');
    }
  }

  void _twobyte() {
    final op = _u8();
    if (op == 0x1E && _rep) {
      _endbr();
      return;
    }
    if (op >= 0x40 && op <= 0x4F) {
      _cmov(op & 0xF);
      return;
    }
    if (op >= 0x80 && op <= 0x8F) {
      _finish('j${_cc[op & 0xF]}', [_branch(_relNear())]);
      return;
    }
    if (op >= 0x90 && op <= 0x9F) {
      _setcc(op & 0xF);
      return;
    }
    if (op >= 0xC8 && op <= 0xCF) {
      final index = (op & 7) | (_rexB ? 8 : 0);
      _finish('bswap', [_regOp(index, _operandBits)]);
      return;
    }
    switch (op) {
      case 0x05:
        _finish('syscall', []);
      case 0x07:
        _finish('sysret', []);
      case 0x0B:
        _finish('ud2', []);
      case 0x1F:
        _nopMulti();
      case 0x31:
        _finish('rdtsc', []);
      case 0x34:
        _finish('sysenter', []);
      case 0x35:
        _finish('sysexit', []);
      case 0xA0:
        _finish('push', [_sreg(4)]);
      case 0xA1:
        _finish('pop', [_sreg(4)]);
      case 0xA2:
        _finish('cpuid', []);
      case 0xA3:
        _bit('bt');
      case 0xA4:
        _shxd('shld', true);
      case 0xA5:
        _shxd('shld', false);
      case 0xA8:
        _finish('push', [_sreg(5)]);
      case 0xA9:
        _finish('pop', [_sreg(5)]);
      case 0xAB:
        _bit('bts');
      case 0xAC:
        _shxd('shrd', true);
      case 0xAD:
        _shxd('shrd', false);
      case 0xAF:
        _imulReg();
      case 0xB0:
        _rr('cmpxchg', byte: true, rmFirst: true);
      case 0xB1:
        _rr('cmpxchg', byte: false, rmFirst: true);
      case 0xB3:
        _bit('btr');
      case 0xB6:
        _movx('movzx', 8);
      case 0xB7:
        _movx('movzx', 16);
      case 0xB8:
        if (!_rep) _fail('Unknown opcode 0x0f 0xb8.');
        _popcnt();
      case 0xBA:
        _bitImm();
      case 0xBB:
        _bit('btc');
      case 0xBC:
        _bs(_rep ? 'tzcnt' : 'bsf', prefixed: _rep);
      case 0xBD:
        _bs(_rep ? 'lzcnt' : 'bsr', prefixed: _rep);
      case 0xBE:
        _movx('movsx', 8);
      case 0xBF:
        _movx('movsx', 16);
      case 0xC0:
        _rr('xadd', byte: true, rmFirst: true);
      case 0xC1:
        _rr('xadd', byte: false, rmFirst: true);
      default:
        _fail('Unknown opcode 0x0f 0x${op.toRadixString(16)}.');
    }
  }

  void _endbr() {
    final mark = _u8();
    if (mark == 0xFA && is64) {
      _finish('endbr64', [], repPrefix: false);
      return;
    }
    if (mark == 0xFB && !is64) {
      _finish('endbr32', [], repPrefix: false);
      return;
    }
    _fail('Unknown opcode 0x0f 0x1e.');
  }

  void _nopMulti() {
    _readModrm();
    if (_mod.regLow != 0) _fail('Unknown opcode 0x0f 0x1f.');
    _finish('nop', [_rm(_operandBits)]);
  }

  void _cmov(int cc) {
    _readModrm();
    _finish('cmov${_cc[cc]}', [
      _regOp(_mod.reg, _operandBits),
      _rm(_operandBits),
    ]);
  }

  void _setcc(int cc) {
    _readModrm();
    _finish('set${_cc[cc]}', [_rm(8)]);
  }

  void _movx(String name, int srcBits) {
    _readModrm();
    _finish(name, [
      _regOp(_mod.reg, _operandBits),
      _rm(srcBits),
    ]);
  }

  void _imulReg() {
    _readModrm();
    _finish('imul', [
      _regOp(_mod.reg, _operandBits),
      _rm(_operandBits),
    ]);
  }

  void _popcnt() {
    _readModrm();
    _finish(
      'popcnt',
      [_regOp(_mod.reg, _operandBits), _rm(_operandBits)],
      repPrefix: false,
    );
  }

  void _bs(String name, {required bool prefixed}) {
    _readModrm();
    _finish(
      name,
      [_regOp(_mod.reg, _operandBits), _rm(_operandBits)],
      repPrefix: !prefixed,
    );
  }

  void _bit(String name) {
    _readModrm();
    _finish(name, [
      _rm(_operandBits),
      _regOp(_mod.reg, _operandBits),
    ]);
  }

  String _bitImmName(int ext) {
    switch (ext) {
      case 4:
        return 'bt';
      case 5:
        return 'bts';
      case 6:
        return 'btr';
      case 7:
        return 'btc';
      default:
        return _fail('Invalid opcode extension $ext.');
    }
  }

  void _bitImm() {
    _readModrm();
    final name = _bitImmName(_mod.regLow);
    _finish(name, [_rm(_operandBits), _immOp(_u8())]);
  }

  void _shxd(String name, bool imm) {
    _readModrm();
    final count = imm ? _immOp(_u8()) : _regOp(1, 8);
    _finish(name, [
      _rm(_operandBits),
      _regOp(_mod.reg, _operandBits),
      count,
    ]);
  }
}
