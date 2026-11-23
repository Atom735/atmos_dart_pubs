part of 'vector_graphics_xml.dart';

extension VgXmlElementXPathComs on XmlElement {
  /// Получение списка команд контура из аттрибута [name].
  List<VgPathCommand>? getPathCommands(String name) {
    final input = attr(name) ?? '';
    if (input.isEmpty) {
      addError('Path command element `$name` has no text');
      return null;
    }
    return const VgPathCommandStringDecoder().convert(input);
  }
}

class VgPathCommandStringDecoder with Converter<String, List<VgPathCommand>> {
  const VgPathCommandStringDecoder();

  /// Число: знак?, целая часть или .дробная, опционально [eE][+-]?цифры
  static final _reNum = RegExp(
    r'[\s,]*([+-]?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?)[\s,]*',
  );
  static final _coms = {for (var i in VgPathC.values) i.str: i};

  static bool _isCommandChar(String s) {
    if (s.isEmpty) return false;
    final c = s.codeUnitAt(0);
    return (c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A);
  }

  void _skipWhitespaceAndComma(String input, List<int> i) {
    while (i[0] < input.length) {
      final ch = input[i[0]];
      if (ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r' || ch == ',') {
        i[0]++;
      } else {
        break;
      }
    }
  }

  /// Читает одно число, сдвигает i, возвращает null при ошибке.
  double? _takeNumber(String input, List<int> i) {
    final m = _reNum.matchAsPrefix(input, i[0]);
    if (m == null) return null;
    i[0] = m.end;
    return double.tryParse(m.group(1)!);
  }

  @override
  List<VgPathCommand> convert(String input) {
    final idx = [0];
    final c = <VgPathCommand>[];
    VgPathC? repeatedCommand;
    bool implicitLineAfterMove = false;
    bool implicitLineRelative = false;

    while (true) {
      _skipWhitespaceAndComma(input, idx);
      if (idx[0] >= input.length) break;

      final ch = input[idx[0]];
      VgPathC? cmd;
      bool relative = false;

      if (_isCommandChar(ch)) {
        final s = ch.toUpperCase();
        final entry = _coms[s];
        if (entry == null) {
          idx[0]++;
          continue;
        }
        cmd = entry;
        relative = ch != s;
        idx[0]++;
        if (cmd == VgPathC.m) {
          implicitLineAfterMove = true;
          implicitLineRelative = relative;
        } else {
          implicitLineAfterMove = false;
        }
        repeatedCommand = null;
      } else if (implicitLineAfterMove) {
        cmd = VgPathC.l;
        relative = implicitLineRelative;
      } else if (repeatedCommand != null) {
        cmd = repeatedCommand;
        relative = c.isNotEmpty && c.last.r;
      } else {
        break;
      }

      final cmdDef = cmd;
      final count = cmdDef.count;

      if (count == 0) {
        // Z
        c.add(VgPathCommand(cmdDef, false, const []));
        repeatedCommand = null;
        continue;
      }

      final v = <double>[];
      for (var k = 0; k < count; k++) {
        final n = _takeNumber(input, idx);
        if (n == null || n.isNaN) break;
        v.add(n);
      }

      if (v.length != count) break;

      c.add(VgPathCommand(cmdDef, relative, v));

      switch (cmdDef) {
        case VgPathC.m:
          implicitLineAfterMove = true;
          repeatedCommand = VgPathC.l;
          break;
        case VgPathC.l:
        case VgPathC.h:
        case VgPathC.v:
        case VgPathC.c:
        case VgPathC.s:
        case VgPathC.q:
        case VgPathC.t:
        case VgPathC.a:
          repeatedCommand = cmdDef;
          break;
        default:
          repeatedCommand = null;
      }
    }

    return c;
  }
}
