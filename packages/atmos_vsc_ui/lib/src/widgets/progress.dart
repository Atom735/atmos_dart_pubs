import 'package:flutter/widgets.dart';

import '../theme/vsc_ui_theme.dart';

/// Thin progress bar. Null [value] draws an indeterminate stripe.
class VscProgressBar extends StatelessWidget {
  /// Creates a progress bar.
  const VscProgressBar({
    super.key,
    this.value,
    this.height = 3,
  });

  /// Progress from 0 to 1. Null means indeterminate.
  final double? value;

  /// Bar thickness.
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    final fraction = value == null ? 0.35 : value!.clamp(0.0, 1.0);
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(color: theme.sideBarBorder),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: fraction,
          child: DecoratedBox(
            decoration: BoxDecoration(color: theme.focusBorder),
          ),
        ),
      ),
    );
  }
}
