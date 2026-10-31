import 'package:flutter/widgets.dart';

import '../theme/vsc_ui_theme.dart';

/// Side bar panel (Explorer tree host, etc.).
class VscSideBar extends StatelessWidget {
  /// Creates a side bar.
  const VscSideBar({
    super.key,
    required this.title,
    required this.child,
    this.width = 260,
    this.actions = const [],
  });

  /// Section title (e.g. `EXPLORER`).
  final String title;

  /// Panel body.
  final Widget child;

  /// Panel width.
  final double width;

  /// Optional header actions.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    return ColoredBox(
      color: theme.sideBarBackground,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 35,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title.toUpperCase(),
                        style: TextStyle(
                          color: theme.sideBarForeground.withOpacity(0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    ...actions,
                  ],
                ),
              ),
            ),
            Expanded(
              child: DefaultTextStyle(
                style: TextStyle(
                  color: theme.sideBarForeground,
                  fontSize: 13,
                  decoration: TextDecoration.none,
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
