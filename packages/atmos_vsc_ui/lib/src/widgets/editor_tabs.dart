import 'package:atmos_vsc_codicon_flutter/atmos_vsc_codicon_flutter.dart';
import 'package:flutter/widgets.dart';

import '../theme/vsc_ui_theme.dart';
import 'pressable.dart';

/// One editor tab descriptor.
class VscEditorTab {
  /// Creates a tab.
  const VscEditorTab({
    required this.id,
    required this.label,
    this.dirty = false,
    this.icon,
  });

  /// Stable id.
  final String id;

  /// Tab label (file name).
  final String label;

  /// Unsaved marker.
  final bool dirty;

  /// Optional leading icon.
  final Widget? icon;
}

/// Horizontal editor tab strip.
class VscEditorTabs extends StatelessWidget {
  /// Creates an editor tab strip.
  const VscEditorTabs({
    super.key,
    required this.tabs,
    this.selectedId,
    this.onSelected,
    this.onClose,
    this.height = 35,
  });

  /// Open tabs.
  final List<VscEditorTab> tabs;

  /// Active tab id.
  final String? selectedId;

  /// Tab selection.
  final ValueChanged<String>? onSelected;

  /// Tab close (optional).
  final ValueChanged<String>? onClose;

  /// Strip height.
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    return ColoredBox(
      color: theme.tabBorder,
      child: SizedBox(
        height: height,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: tabs.length,
          itemBuilder: (context, index) {
            final tab = tabs[index];
            final selected = tab.id == selectedId;
            return _TabChip(
              tab: tab,
              selected: selected,
              theme: theme,
              onTap: onSelected == null ? null : () => onSelected!(tab.id),
              onClose: onClose == null ? null : () => onClose!(tab.id),
            );
          },
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.tab,
    required this.selected,
    required this.theme,
    required this.onTap,
    required this.onClose,
  });

  final VscEditorTab tab;
  final bool selected;
  final VscUiTheme theme;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final bg =
        selected ? theme.tabActiveBackground : theme.tabInactiveBackground;
    final fg =
        selected ? theme.tabActiveForeground : theme.tabInactiveForeground;
    return VscPressable(
      onTap: onTap,
      backgroundColor: bg,
      hoverColor: theme.listHoverBackground,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: theme.tabBorder),
            top: selected
                ? BorderSide(color: theme.focusBorder)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tab.icon != null) ...[
              IconTheme(
                data: IconThemeData(color: fg, size: 14),
                child: tab.icon!,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              tab.dirty ? '● ${tab.label}' : tab.label,
              style: TextStyle(
                color: fg,
                fontSize: 12,
                decoration: TextDecoration.none,
              ),
            ),
            if (onClose != null) ...[
              const SizedBox(width: 8),
              VscPressable(
                onTap: onClose,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: VscCodicon(
                    VscCodicons.close,
                    size: 12,
                    color: fg.withOpacity(0.7),
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
