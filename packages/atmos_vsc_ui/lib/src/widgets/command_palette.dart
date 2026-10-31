import 'package:atmos_vsc_codicon_flutter/atmos_vsc_codicon_flutter.dart';
import 'package:atmos_vsc_commands/atmos_vsc_commands.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/vsc_ui_theme.dart';
import 'pressable.dart';

/// Modal command palette over the workbench.
class VscCommandPalette extends StatefulWidget {
  /// Creates a command palette.
  const VscCommandPalette({
    super.key,
    required this.commands,
    required this.onCommand,
    this.onDismiss,
    this.placeholder = 'Type a command…',
  });

  /// Available commands.
  final List<VscCommand> commands;

  /// Invoked when a command is chosen.
  final ValueChanged<VscCommand> onCommand;

  /// Dismiss without selection (Escape / barrier).
  final VoidCallback? onDismiss;

  /// Search field hint.
  final String placeholder;

  /// Shows the palette as a translucent route (no Material).
  static Future<VscCommand?> show(
    BuildContext context, {
    required List<VscCommand> commands,
  }) {
    return Navigator.of(context, rootNavigator: true).push<VscCommand>(
      PageRouteBuilder<VscCommand>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: const Color(0x88000000),
        barrierLabel: 'Dismiss',
        pageBuilder: (context, animation, secondaryAnimation) {
          return Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 48),
              child: VscCommandPalette(
                commands: commands,
                onCommand: (cmd) => Navigator.of(context).pop(cmd),
                onDismiss: () => Navigator.of(context).pop(),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  State<VscCommandPalette> createState() => _VscCommandPaletteState();
}

class _VscCommandPaletteState extends State<VscCommandPalette> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  int _highlight = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() => _highlight = 0));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  List<VscCommand> get _filtered {
    final q = _controller.text.trim().toLowerCase();
    if (q.isEmpty) return widget.commands;
    return widget.commands
        .where((c) {
          final hay = '${c.paletteLabel} ${c.command}'.toLowerCase();
          return hay.contains(q);
        })
        .toList(growable: false);
  }

  void _activate(VscCommand command) => widget.onCommand(command);

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final items = _filtered;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onDismiss?.call();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (items.isEmpty) return KeyEventResult.handled;
      setState(() => _highlight = (_highlight + 1) % items.length);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (items.isEmpty) return KeyEventResult.handled;
      setState(
        () => _highlight = (_highlight - 1 + items.length) % items.length,
      );
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (items.isNotEmpty) {
        _activate(items[_highlight.clamp(0, items.length - 1)]);
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  int _clampedHighlight(int length) {
    if (length == 0) return 0;
    if (_highlight >= length) return length - 1;
    if (_highlight < 0) return 0;
    return _highlight;
  }

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    final items = _filtered;
    final highlight = _clampedHighlight(items.length);

    return Focus(
      onKeyEvent: _onKey,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 420),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.widgetBackground,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: theme.inputBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.inputBackground,
                    border: Border.all(color: theme.focusBorder),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: EditableText(
                      controller: _controller,
                      focusNode: _focus,
                      style: TextStyle(
                        color: theme.inputForeground,
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                      cursorColor: theme.focusBorder,
                      backgroundCursorColor: theme.focusBorder,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final cmd = items[index];
                    final selected = index == highlight;
                    return VscPressable(
                      onTap: () => _activate(cmd),
                      backgroundColor: selected
                          ? theme.listActiveSelectionBackground
                          : null,
                      hoverColor: theme.listHoverBackground,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: _CommandLabel(command: cmd),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommandLabel extends StatelessWidget {
  const _CommandLabel({required this.command});

  final VscCommand command;

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    final color = theme.editorForeground;
    final icon = command.icon;
    return Row(
      children: [
        if (icon is VscCommandProductIcon) ...[
          VscCodicon.fromRef(icon.id, size: 16, color: color),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            command.paletteLabel,
            style: TextStyle(
              color: color,
              fontSize: 13,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}
