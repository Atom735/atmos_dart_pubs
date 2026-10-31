import 'package:flutter/widgets.dart';

import '../theme/vsc_ui_theme.dart';
import 'pressable.dart';

/// One activity bar icon entry.
class VscActivityBarItem {
  /// Creates an activity bar item.
  const VscActivityBarItem({
    required this.id,
    required this.icon,
    this.tooltip,
  });

  /// Stable id for selection.
  final String id;

  /// Icon widget (e.g. `VscCodicon(VscCodicons.files, size: 24)`).
  final Widget icon;

  /// Optional tooltip.
  final String? tooltip;
}

/// Vertical icon strip (Explorer, Search, …).
class VscActivityBar extends StatelessWidget {
  /// Creates an activity bar.
  const VscActivityBar({
    super.key,
    required this.items,
    this.selectedId,
    this.onSelected,
    this.width = 48,
  });

  /// Top-to-bottom items.
  final List<VscActivityBarItem> items;

  /// Currently selected item id.
  final String? selectedId;

  /// Selection callback.
  final ValueChanged<String>? onSelected;

  /// Bar width.
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    return ColoredBox(
      color: theme.activityBarBackground,
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            for (final item in items)
              _ActivityIcon(
                item: item,
                selected: item.id == selectedId,
                activeColor: theme.activityBarForeground,
                inactiveColor: theme.activityBarInactiveForeground,
                indicatorColor: theme.focusBorder,
                hoverColor: theme.listHoverBackground,
                onTap: onSelected == null ? null : () => onSelected!(item.id),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActivityIcon extends StatelessWidget {
  const _ActivityIcon({
    required this.item,
    required this.selected,
    required this.activeColor,
    required this.inactiveColor,
    required this.indicatorColor,
    required this.hoverColor,
    required this.onTap,
  });

  final VscActivityBarItem item;
  final bool selected;
  final Color activeColor;
  final Color inactiveColor;
  final Color indicatorColor;
  final Color hoverColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : inactiveColor;
    return VscPressable(
      onTap: onTap,
      hoverColor: hoverColor.withOpacity(0.35),
      tooltip: item.tooltip,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (selected)
              Align(
                alignment: Alignment.centerLeft,
                child: ColoredBox(
                  color: indicatorColor,
                  child: const SizedBox(width: 2, height: 24),
                ),
              ),
            // Tint so glyphs follow the selected / idle activity color.
            ColorFiltered(
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              child: IconTheme(
                data: IconThemeData(color: color, size: 24),
                child: item.icon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
