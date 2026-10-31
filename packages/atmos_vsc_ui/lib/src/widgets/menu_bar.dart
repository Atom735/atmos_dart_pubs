import 'package:flutter/widgets.dart';

import '../theme/vsc_ui_theme.dart';
import 'pressable.dart';

/// One item inside a [VscMenuEntry].
class VscMenuItem {
  /// Creates a menu item.
  const VscMenuItem({
    required this.label,
    this.shortcut,
    this.onSelected,
  });

  /// Item label.
  final String label;

  /// Optional shortcut hint, drawn on the right.
  final String? shortcut;

  /// Called when the item is chosen. Null draws the item muted.
  final VoidCallback? onSelected;
}

/// A top-level menu (File, Edit, View, …).
class VscMenuEntry {
  /// Creates a menu.
  const VscMenuEntry({required this.label, required this.items});

  /// Menu title in the bar.
  final String label;

  /// Items shown when the menu is open.
  final List<VscMenuItem> items;
}

/// Horizontal menu bar. Opens one menu at a time in an overlay.
class VscMenuBar extends StatefulWidget {
  /// Creates a menu bar.
  const VscMenuBar({super.key, required this.entries});

  /// Menus from left to right.
  final List<VscMenuEntry> entries;

  @override
  State<VscMenuBar> createState() => _VscMenuBarState();
}

class _VscMenuBarState extends State<VscMenuBar> {
  OverlayEntry? _menu;
  int? _open;

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  void _close() {
    _menu?.remove();
    _menu = null;
    _open = null;
  }

  void _openMenu(int index, BuildContext anchor) {
    _close();
    final box = anchor.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final origin = box.localToGlobal(Offset(0, box.size.height));
    final entry = widget.entries[index];
    _open = index;
    _menu = OverlayEntry(
      builder: (context) {
        final theme = VscUiTheme.of(context);
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _close();
                  setState(() {});
                },
              ),
            ),
            Positioned(
              left: origin.dx,
              top: origin.dy,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.widgetBackground,
                  border: Border.all(color: theme.inputBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 260,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final item in entry.items)
                        VscPressable(
                          onTap: item.onSelected == null
                              ? null
                              : () {
                                  _close();
                                  setState(() {});
                                  item.onSelected!();
                                },
                          hoverColor: theme.listHoverBackground,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.label,
                                    style: TextStyle(
                                      color: item.onSelected == null
                                          ? theme.editorForeground
                                              .withOpacity(0.4)
                                          : theme.editorForeground,
                                      fontSize: 13,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                                if (item.shortcut != null)
                                  Text(
                                    item.shortcut!,
                                    style: TextStyle(
                                      color: theme.editorForeground
                                          .withOpacity(0.55),
                                      fontSize: 12,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(anchor).insert(_menu!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.entries.length; i++)
          Builder(
            builder: (anchor) {
              return VscPressable(
                onTap: () => _openMenu(i, anchor),
                backgroundColor:
                    _open == i ? theme.listHoverBackground : null,
                hoverColor: theme.listHoverBackground,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    widget.entries[i].label,
                    style: TextStyle(
                      color: theme.titleBarForeground,
                      fontSize: 12,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
