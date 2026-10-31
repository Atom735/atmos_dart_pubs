import 'package:flutter/widgets.dart';

import '../theme/vsc_ui_theme.dart';
import 'pressable.dart';

/// Icon button for a [VscToolbar].
class VscToolbarButton extends StatelessWidget {
  /// Creates a toolbar button.
  const VscToolbarButton({
    super.key,
    required this.icon,
    this.tooltip,
    this.onPressed,
  });

  /// Icon, usually a `VscCodicon`.
  final Widget icon;

  /// Hover tooltip.
  final String? tooltip;

  /// Tap callback.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    return VscPressable(
      onTap: onPressed,
      tooltip: tooltip,
      hoverColor: theme.listHoverBackground,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: IconTheme(
          data: IconThemeData(color: theme.editorForeground, size: 16),
          child: icon,
        ),
      ),
    );
  }
}

/// Horizontal icon strip, like an editor or view toolbar.
class VscToolbar extends StatelessWidget {
  /// Creates a toolbar.
  const VscToolbar({super.key, required this.children});

  /// Buttons and other compact widgets.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.tabBorder)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(children: children),
      ),
    );
  }
}
