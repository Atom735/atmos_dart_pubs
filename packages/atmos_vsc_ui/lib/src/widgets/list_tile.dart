import 'package:flutter/widgets.dart';

import '../theme/vsc_ui_theme.dart';
import 'pressable.dart';

/// One row in a VS Code list (search results, SCM, quick pick).
class VscListTile extends StatelessWidget {
  /// Creates a list row.
  const VscListTile({
    super.key,
    required this.label,
    this.leading,
    this.trailing,
    this.selected = false,
    this.onTap,
    this.indent = 0,
  });

  /// Primary text.
  final String label;

  /// Leading icon or marker.
  final Widget? leading;

  /// Trailing widget (badge, shortcut).
  final Widget? trailing;

  /// Highlights the row as the active selection.
  final bool selected;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Extra left padding, in logical pixels.
  final double indent;

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    return VscPressable(
      onTap: onTap,
      backgroundColor:
          selected ? theme.listActiveSelectionBackground : null,
      hoverColor: theme.listHoverBackground,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8 + indent, 4, 8, 4),
        child: Row(
          children: [
            if (leading != null) ...[
              IconTheme(
                data: IconThemeData(color: theme.sideBarForeground, size: 16),
                child: leading!,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.sideBarForeground,
                  fontSize: 13,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
