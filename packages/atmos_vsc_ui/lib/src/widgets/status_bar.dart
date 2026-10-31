import 'package:flutter/widgets.dart';

import '../theme/vsc_ui_theme.dart';

/// Bottom status bar.
class VscStatusBar extends StatelessWidget {
  /// Creates a status bar.
  const VscStatusBar({
    super.key,
    this.leading = const [],
    this.trailing = const [],
    this.height = 22,
  });

  /// Left-aligned items.
  final List<Widget> leading;

  /// Right-aligned items.
  final List<Widget> trailing;

  /// Bar height.
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    final style = TextStyle(
      color: theme.statusBarForeground,
      fontSize: 12,
      decoration: TextDecoration.none,
    );
    return ColoredBox(
      color: theme.statusBarBackground,
      child: SizedBox(
        height: height,
        child: DefaultTextStyle(
          style: style,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                for (final w in leading) ...[
                  w,
                  const SizedBox(width: 12),
                ],
                const Spacer(),
                for (final w in trailing) ...[
                  const SizedBox(width: 12),
                  w,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
