import 'package:atmos_vsc_keybindings/atmos_vsc_keybindings.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'key_bridge.dart';

/// Callback when the engine resolves a command.
typedef VscKeyCommandCallback = void Function(VscKeyMatch match);

/// Focusable host that feeds key downs into a [VscKeybindingEngine].
///
/// ## ENG
/// Uses `Focus` + `onKeyEvent` (Flutter 3.16). Supports VS Code chords via
/// the engine. Does not use Material.
///
/// ## RU
/// `Focus` + `onKeyEvent`. Аккорды — через движок. Без Material.
class VscKeybindingsHost extends StatefulWidget {
  /// Creates a keybindings host.
  const VscKeybindingsHost({
    super.key,
    required this.engine,
    required this.child,
    this.onCommand,
    this.autofocus = true,
  });

  /// Hotkey engine (mutable [VscKeybindingEngine.context] OK).
  final VscKeybindingEngine engine;

  /// Subtree.
  final Widget child;

  /// Invoked when a binding matches.
  final VscKeyCommandCallback? onCommand;

  /// Whether the focus node requests focus on mount.
  final bool autofocus;

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
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final stroke = VscFlutterKeyBridge.fromKeyEvent(
      logicalKey: event.logicalKey,
      pressed: HardwareKeyboard.instance.logicalKeysPressed,
    );
    if (stroke == null) return KeyEventResult.ignored;

    final match = widget.engine.handleKey(stroke);
    if (match == null) {
      return widget.engine.inChord
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }
    widget.onCommand?.call(match);
    return KeyEventResult.handled;
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
