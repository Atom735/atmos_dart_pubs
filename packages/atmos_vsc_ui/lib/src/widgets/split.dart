import 'package:flutter/widgets.dart';

import '../theme/vsc_ui_theme.dart';

/// Two panes separated by a draggable sash.
class VscSplit extends StatefulWidget {
  /// Creates a split view.
  const VscSplit({
    super.key,
    required this.first,
    required this.second,
    this.axis = Axis.horizontal,
    this.initialFraction = 0.5,
  });

  /// Leading pane (left or top).
  final Widget first;

  /// Trailing pane (right or bottom).
  final Widget second;

  /// Sash direction. Horizontal puts panes side by side.
  final Axis axis;

  /// Initial share of the leading pane, from 0 to 1.
  final double initialFraction;

  @override
  State<VscSplit> createState() => _VscSplitState();
}

class _VscSplitState extends State<VscSplit> {
  late double _fraction = widget.initialFraction.clamp(0.15, 0.85);

  void _drag(double delta, double total) {
    if (total <= 0) return;
    setState(() {
      _fraction = (_fraction + delta / total).clamp(0.15, 0.85);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = widget.axis == Axis.horizontal;
        final total = horizontal ? constraints.maxWidth : constraints.maxHeight;
        final leading = (total - 4) * _fraction;
        final sash = MouseRegion(
          cursor: horizontal
              ? SystemMouseCursors.resizeColumn
              : SystemMouseCursors.resizeRow,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: horizontal
                ? (d) => _drag(d.delta.dx, total)
                : null,
            onVerticalDragUpdate: horizontal
                ? null
                : (d) => _drag(d.delta.dy, total),
            child: SizedBox(
              width: horizontal ? 4 : double.infinity,
              height: horizontal ? double.infinity : 4,
              child: ColoredBox(color: theme.tabBorder),
            ),
          ),
        );
        if (horizontal) {
          return Row(
            children: [
              SizedBox(width: leading, child: widget.first),
              sash,
              Expanded(child: widget.second),
            ],
          );
        }
        return Column(
          children: [
            SizedBox(height: leading, child: widget.first),
            sash,
            Expanded(child: widget.second),
          ],
        );
      },
    );
  }
}
