import 'package:atmos_vsc_keybindings/atmos_vsc_keybindings.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'key_bridge.dart';

/// Callback when the engine resolves a command.
typedef VscKeyCommandCallback = void Function(VscKeyMatch match);

/// Optional gate before the host feeds a key into the engine.
typedef VscKeyCanHandle = bool Function(KeyEvent event, VscKeyStroke stroke);

/// Focusable host that feeds key downs into a [VscKeybindingEngine].
///
/// ## ENG
/// Uses `Focus` + `onKeyEvent` (Flutter 3.16). Supports VS Code chords via
/// the engine. Does not use Material. Key repeats are ignored
/// (`KeyDownEvent` only).
///
/// Place above a workbench shell, not as the sole focus of an
/// [EditableText] — use [skipPrintableWhenTextInput] so typing still works.
///
/// ## RU
/// `Focus` + `onKeyEvent`. Аккорды — через движок. Без Material.
/// Повторы клавиш игнорируются. Для редактора включите
/// [skipPrintableWhenTextInput].
class VscKeybindingsHost extends StatefulWidget {
  /// Creates a keybindings host.
  const VscKeybindingsHost({
    super.key,
    required this.engine,
    required this.child,
    this.onCommand,
    this.autofocus = true,
    this.skipPrintableWhenTextInput = true,
    this.canHandle,
  });

  /// Hotkey engine (mutable [VscKeybindingEngine.context] OK).
  final VscKeybindingEngine engine;

  /// Subtree.
  final Widget child;

  /// Invoked when a binding matches.
  final VscKeyCommandCallback? onCommand;

  /// Whether the focus node requests focus on mount.
  final bool autofocus;

  /// When an [EditableText] owns focus, ignore printable keys without
  /// ctrl/meta (alt alone still routes). Chord continuation always routes.
  final bool skipPrintableWhenTextInput;

  /// Extra gate; return `false` to ignore the event.
  final VscKeyCanHandle? canHandle;

  @override
  State<VscKeybindingsHost> createState() => _VscKeybindingsHostState();
}

class _VscKeybindingsHostState extends State<VscKeybindingsHost> {
  late final FocusNode _focus = FocusNode(debugLabel: 'VscKeybindingsHost');

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    // KeyRepeatEvent is a sibling of KeyDownEvent — ignore repeats.
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final stroke = VscFlutterKeyBridge.fromKeyEvent(
      logicalKey: event.logicalKey,
      pressed: HardwareKeyboard.instance.logicalKeysPressed,
    );
    if (stroke == null) return KeyEventResult.ignored;

    if (widget.canHandle != null && !widget.canHandle!(event, stroke)) {
      return KeyEventResult.ignored;
    }

    if (widget.skipPrintableWhenTextInput &&
        !_shouldHandleWithTextInput(stroke)) {
      return KeyEventResult.ignored;
    }

    final match = widget.engine.handleKey(stroke);
    if (match == null) {
      return widget.engine.inChord
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }
    widget.onCommand?.call(match);
    return KeyEventResult.handled;
  }

  bool _shouldHandleWithTextInput(VscKeyStroke stroke) {
    if (widget.engine.inChord) return true;
    if (!_editableTextOwnsFocus()) return true;
    // Shortcuts with ctrl/meta still win over typing.
    if (stroke.control || stroke.meta) return true;
    return false;
  }

  bool _editableTextOwnsFocus() {
    final primary = FocusManager.instance.primaryFocus;
    if (primary == null || identical(primary, _focus)) return false;
    final ctx = primary.context;
    if (ctx == null) return false;
    if (ctx.widget is EditableText) return true;
    return ctx.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focus,
      autofocus: widget.autofocus,
      onKeyEvent: _onKey,
      child: widget.child,
    );
  }
}
