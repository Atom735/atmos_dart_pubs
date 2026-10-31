import 'package:flutter/widgets.dart';

import '../theme/vsc_ui_theme.dart';

/// Simple title / menu bar strip.
class VscTitleBar extends StatelessWidget {
  /// Creates a title bar.
  const VscTitleBar({
    super.key,
    required this.title,
    this.leading,
    this.actions = const [],
    this.height = 30,
  });

  /// Window / workspace title.
  final String title;

  /// Optional leading (menu / app icon).
  final Widget? leading;

  /// Trailing actions.
  final List<Widget> actions;

  /// Bar height.
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    return ColoredBox(
      color: theme.titleBarBackground,
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.titleBarForeground,
                  fontSize: 12,
                  decoration: TextDecoration.none,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ...actions,
          ],
        ),
      ),
    );
  }
}
