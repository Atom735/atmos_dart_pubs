import 'package:flutter/widgets.dart';

import '../theme/vsc_ui_theme.dart';
import 'pressable.dart';

/// VS Code-like button (primary blue or secondary input).
class VscButton extends StatelessWidget {
  /// Creates a button.
  const VscButton({
    super.key,
    required this.label,
    this.onPressed,
    this.primary = false,
    this.icon,
  });

  /// Button label.
  final String label;

  /// Tap callback. Null disables the button.
  final VoidCallback? onPressed;

  /// Filled accent button when true.
  final bool primary;

  /// Optional leading icon.
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    final enabled = onPressed != null;
    final bg = primary ? theme.focusBorder : theme.inputBackground;
    final fg = primary ? const Color(0xFFFFFFFF) : theme.inputForeground;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: VscPressable(
        onTap: onPressed,
        backgroundColor: bg,
        hoverColor: primary
            ? theme.focusBorder.withOpacity(0.85)
            : theme.listHoverBackground,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                IconTheme(
                  data: IconThemeData(color: fg, size: 16),
                  child: icon!,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
