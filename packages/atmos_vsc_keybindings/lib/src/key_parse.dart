import 'key_stroke.dart';

/// Parses VS Code / Cursor key strings (`ctrl+k ctrl+c`) into [VscKeyStroke]s.
///
/// ## ENG
/// Pure Dart (no Flutter). Unknown tokens throw [FormatException].
///
/// ## RU
/// Pure Dart (без Flutter). Неизвестные токены — [FormatException].
abstract final class VscKeyStrokeParser {
  /// Parses a full key string into chord steps.
  static List<VscKeyStroke> parse(String key) {
    final parts = key
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      throw const FormatException('Empty key string');
    }
    return parts.map(parsePart).toList(growable: false);
  }

  /// Parses a single chord part (`ctrl+shift+p`).
  static VscKeyStroke parsePart(String part) {
    final tokens = part
        .toLowerCase()
        .split('+')
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isEmpty) {
      throw FormatException('Empty key part: "$part"');
    }

    var control = false;
    var shift = false;
    var alt = false;
    var meta = false;
    String? trigger;

    for (final token in tokens) {
      if (_isControl(token)) {
        control = true;
      } else if (token == 'shift') {
        shift = true;
      } else if (token == 'alt' || token == 'option') {
        alt = true;
      } else if (_isMeta(token)) {
        meta = true;
      } else {
        if (trigger != null) {
          throw FormatException('Multiple trigger keys in "$part"');
        }
        trigger = _normalizeKey(token);
      }
    }

    if (trigger == null) {
      throw FormatException('Missing trigger key in "$part"');
    }

    return VscKeyStroke(
      key: trigger,
      control: control,
      shift: shift,
      alt: alt,
      meta: meta,
    );
  }

  /// Whether [key] is a multi-step chord.
  static bool hasChord(String key) => parse(key).length > 1;

  static bool _isControl(String token) =>
      token == 'ctrl' || token == 'control';

  static bool _isMeta(String token) =>
      token == 'meta' ||
      token == 'cmd' ||
      token == 'command' ||
      token == 'win' ||
      token == 'windows' ||
      token == 'super';

  static String _normalizeKey(String token) {
    if (_aliases.containsKey(token)) return _aliases[token]!;
    if (_known.contains(token)) return token;
    if (token.length == 1) {
      final c = token.codeUnitAt(0);
      if ((c >= 0x61 && c <= 0x7a) || (c >= 0x30 && c <= 0x39)) {
        return token;
      }
    }
    if (token.startsWith('f') && token.length <= 3) {
      final n = int.tryParse(token.substring(1));
      if (n != null && n >= 1 && n <= 24) return token;
    }
    if (token.startsWith('numpad')) return token;
    throw FormatException('Unknown key token: "$token"');
  }

  static const Map<String, String> _aliases = {
    'esc': 'escape',
    'return': 'enter',
    'del': 'delete',
    'ins': 'insert',
    'down': 'down',
    'up': 'up',
    'left': 'left',
    'right': 'right',
    'pageup': 'pageup',
    'pagedown': 'pagedown',
  };

  static const Set<String> _known = {
    'escape',
    'tab',
    'enter',
    'space',
    'backspace',
    'delete',
    'insert',
    'home',
    'end',
    'pageup',
    'pagedown',
    'up',
    'down',
    'left',
    'right',
    'capslock',
    'numlock',
    'scrolllock',
    'pause',
    'printscreen',
    'contextmenu',
    'comma',
    'period',
    'slash',
    'backslash',
    'semicolon',
    'quote',
    'backquote',
    'bracketleft',
    'bracketright',
    'minus',
    'equal',
    'numpad_add',
    'numpad_subtract',
    'numpad_multiply',
    'numpad_divide',
    'numpad_decimal',
    'numpad_enter',
  };
}
