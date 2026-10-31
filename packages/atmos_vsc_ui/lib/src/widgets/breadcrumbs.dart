import 'package:atmos_vsc_codicon_flutter/atmos_vsc_codicon_flutter.dart';
import 'package:flutter/widgets.dart';

import '../theme/vsc_ui_theme.dart';
import 'pressable.dart';

/// One segment of a [VscBreadcrumbs] trail.
class VscBreadcrumb {
  /// Creates a segment.
  const VscBreadcrumb({required this.label, this.icon});

  /// Segment text.
  final String label;

  /// Optional leading icon.
  final Widget? icon;
}

/// Editor breadcrumb trail (`src > widgets > workbench.dart`).
class VscBreadcrumbs extends StatelessWidget {
  /// Creates a breadcrumb bar.
  const VscBreadcrumbs({
    super.key,
    required this.items,
    this.onTap,
    this.height = 22,
  });

  /// Segments from root to leaf.
  final List<VscBreadcrumb> items;

  /// Called with the tapped segment index.
  final ValueChanged<int>? onTap;

  /// Bar height.
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    final fg = theme.editorForeground.withOpacity(0.75);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.editorBackground,
        border: Border(bottom: BorderSide(color: theme.tabBorder)),
      ),
      child: SizedBox(
        height: height,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: VscCodicon(
                    VscCodicons.chevronRight,
                    size: 12,
                    color: fg,
                  ),
                ),
              VscPressable(
                onTap: onTap == null ? null : () => onTap!(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      if (items[i].icon != null) ...[
                        IconTheme(
                          data: IconThemeData(color: fg, size: 14),
                          child: items[i].icon!,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        items[i].label,
                        style: TextStyle(
                          color: fg,
                          fontSize: 12,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
