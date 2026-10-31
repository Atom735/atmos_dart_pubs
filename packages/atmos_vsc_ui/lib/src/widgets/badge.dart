import 'package:flutter/widgets.dart';

import '../theme/vsc_ui_theme.dart';

/// Small count or status pill, like an activity-bar badge.
class VscBadge extends StatelessWidget {
  /// Creates a badge.
  const VscBadge({
    super.key,
    required this.label,
    this.color,
    this.foreground,
  });

  /// Short text, usually a count.
  final String label;

  /// Background. Defaults to the focus accent.
  final Color? color;

  /// Label color. Defaults to white.
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? theme.focusBorder,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        child: Text(
          label,
          style: TextStyle(
            color: foreground ?? const Color(0xFFFFFFFF),
            fontSize: 11,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
