import 'package:atmos_vsc_keybindings/atmos_vsc_keybindings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Maps between Flutter keys and [VscKeyStroke].
abstract final class VscFlutterKeyBridge {
  /// [VscKeyPlatform] for the current [defaultTargetPlatform].
  static VscKeyPlatform get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return VscKeyPlatform.macos;
      case TargetPlatform.windows:
        return VscKeyPlatform.windows;
      case TargetPlatform.linux:
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return VscKeyPlatform.linux;
    }
  }

  /// Converts a Flutter [KeyEvent] / [RawKeyEvent] style snapshot to a stroke.
  ///
  /// Returns `null` for pure modifier presses (no trigger key).
  static VscKeyStroke? fromKeyEvent({
    required LogicalKeyboardKey logicalKey,
    required Set<LogicalKeyboardKey> pressed,
  }) {
    if (_isModifier(logicalKey)) return null;

    final token = _tokenFor(logicalKey);
    if (token == null) return null;

    return VscKeyStroke(
      key: token,
      control: pressed.contains(LogicalKeyboardKey.controlLeft) ||
          pressed.contains(LogicalKeyboardKey.controlRight) ||
          pressed.contains(LogicalKeyboardKey.control),
      shift: pressed.contains(LogicalKeyboardKey.shiftLeft) ||
          pressed.contains(LogicalKeyboardKey.shiftRight) ||
          pressed.contains(LogicalKeyboardKey.shift),
      alt: pressed.contains(LogicalKeyboardKey.altLeft) ||
          pressed.contains(LogicalKeyboardKey.altRight) ||
          pressed.contains(LogicalKeyboardKey.alt),
      meta: pressed.contains(LogicalKeyboardKey.metaLeft) ||
          pressed.contains(LogicalKeyboardKey.metaRight) ||
          pressed.contains(LogicalKeyboardKey.meta),
    );
  }

  /// [SingleActivator] for a single-step stroke, or `null` if unknown.
  static SingleActivator? toSingleActivator(VscKeyStroke stroke) {
    final logical = _logicalFor(stroke.key);
    if (logical == null) return null;
    return SingleActivator(
      logical,
      control: stroke.control,
      shift: stroke.shift,
      alt: stroke.alt,
      meta: stroke.meta,
    );
  }

  static bool _isModifier(LogicalKeyboardKey key) =>
      key == LogicalKeyboardKey.control ||
      key == LogicalKeyboardKey.controlLeft ||
      key == LogicalKeyboardKey.controlRight ||
      key == LogicalKeyboardKey.shift ||
      key == LogicalKeyboardKey.shiftLeft ||
      key == LogicalKeyboardKey.shiftRight ||
      key == LogicalKeyboardKey.alt ||
      key == LogicalKeyboardKey.altLeft ||
      key == LogicalKeyboardKey.altRight ||
      key == LogicalKeyboardKey.meta ||
      key == LogicalKeyboardKey.metaLeft ||
      key == LogicalKeyboardKey.metaRight;

  static String? _tokenFor(LogicalKeyboardKey key) {
    final direct = _logicalToToken[key];
    if (direct != null) return direct;

    final label = key.keyLabel;
    if (label.length == 1) {
      final lower = label.toLowerCase();
      final c = lower.codeUnitAt(0);
      if ((c >= 0x61 && c <= 0x7a) || (c >= 0x30 && c <= 0x39)) {
        return lower;
      }
    }
    return null;
  }

  static LogicalKeyboardKey? _logicalFor(String token) {
    final named = _tokenToLogical[token];
    if (named != null) return named;
    if (token.length == 1) {
      final c = token.codeUnitAt(0);
      if (c >= 0x61 && c <= 0x7a) {
        return _letters[token];
      }
      if (c >= 0x30 && c <= 0x39) {
        return _digits[token];
      }
    }
    if (token.startsWith('f')) {
      final n = int.tryParse(token.substring(1));
      if (n != null) return _functionKeys[n];
    }
    return null;
  }

  static const Map<String, LogicalKeyboardKey> _letters = {
    'a': LogicalKeyboardKey.keyA,
    'b': LogicalKeyboardKey.keyB,
    'c': LogicalKeyboardKey.keyC,
    'd': LogicalKeyboardKey.keyD,
    'e': LogicalKeyboardKey.keyE,
    'f': LogicalKeyboardKey.keyF,
    'g': LogicalKeyboardKey.keyG,
    'h': LogicalKeyboardKey.keyH,
    'i': LogicalKeyboardKey.keyI,
    'j': LogicalKeyboardKey.keyJ,
    'k': LogicalKeyboardKey.keyK,
    'l': LogicalKeyboardKey.keyL,
    'm': LogicalKeyboardKey.keyM,
    'n': LogicalKeyboardKey.keyN,
    'o': LogicalKeyboardKey.keyO,
    'p': LogicalKeyboardKey.keyP,
    'q': LogicalKeyboardKey.keyQ,
    'r': LogicalKeyboardKey.keyR,
    's': LogicalKeyboardKey.keyS,
    't': LogicalKeyboardKey.keyT,
    'u': LogicalKeyboardKey.keyU,
    'v': LogicalKeyboardKey.keyV,
    'w': LogicalKeyboardKey.keyW,
    'x': LogicalKeyboardKey.keyX,
    'y': LogicalKeyboardKey.keyY,
    'z': LogicalKeyboardKey.keyZ,
  };

  static const Map<String, LogicalKeyboardKey> _digits = {
    '0': LogicalKeyboardKey.digit0,
    '1': LogicalKeyboardKey.digit1,
    '2': LogicalKeyboardKey.digit2,
    '3': LogicalKeyboardKey.digit3,
    '4': LogicalKeyboardKey.digit4,
    '5': LogicalKeyboardKey.digit5,
    '6': LogicalKeyboardKey.digit6,
    '7': LogicalKeyboardKey.digit7,
    '8': LogicalKeyboardKey.digit8,
    '9': LogicalKeyboardKey.digit9,
  };

  static const Map<int, LogicalKeyboardKey> _functionKeys = {
    1: LogicalKeyboardKey.f1,
    2: LogicalKeyboardKey.f2,
    3: LogicalKeyboardKey.f3,
    4: LogicalKeyboardKey.f4,
    5: LogicalKeyboardKey.f5,
    6: LogicalKeyboardKey.f6,
    7: LogicalKeyboardKey.f7,
    8: LogicalKeyboardKey.f8,
    9: LogicalKeyboardKey.f9,
    10: LogicalKeyboardKey.f10,
    11: LogicalKeyboardKey.f11,
    12: LogicalKeyboardKey.f12,
  };

  static final Map<LogicalKeyboardKey, String> _logicalToToken = {
    for (final e in _letters.entries) e.value: e.key,
    for (final e in _digits.entries) e.value: e.key,
    for (final e in _functionKeys.entries) e.value: 'f${e.key}',
    LogicalKeyboardKey.escape: 'escape',
    LogicalKeyboardKey.tab: 'tab',
    LogicalKeyboardKey.enter: 'enter',
    LogicalKeyboardKey.space: 'space',
    LogicalKeyboardKey.backspace: 'backspace',
    LogicalKeyboardKey.delete: 'delete',
    LogicalKeyboardKey.insert: 'insert',
    LogicalKeyboardKey.home: 'home',
    LogicalKeyboardKey.end: 'end',
    LogicalKeyboardKey.pageUp: 'pageup',
    LogicalKeyboardKey.pageDown: 'pagedown',
    LogicalKeyboardKey.arrowUp: 'up',
    LogicalKeyboardKey.arrowDown: 'down',
    LogicalKeyboardKey.arrowLeft: 'left',
    LogicalKeyboardKey.arrowRight: 'right',
    LogicalKeyboardKey.comma: 'comma',
    LogicalKeyboardKey.period: 'period',
    LogicalKeyboardKey.slash: 'slash',
    LogicalKeyboardKey.backslash: 'backslash',
    LogicalKeyboardKey.semicolon: 'semicolon',
    LogicalKeyboardKey.quote: 'quote',
    LogicalKeyboardKey.backquote: 'backquote',
    LogicalKeyboardKey.bracketLeft: 'bracketleft',
    LogicalKeyboardKey.bracketRight: 'bracketright',
    LogicalKeyboardKey.minus: 'minus',
    LogicalKeyboardKey.equal: 'equal',
  };

  static final Map<String, LogicalKeyboardKey> _tokenToLogical = {
    for (final e in _logicalToToken.entries) e.value: e.key,
  };
}
