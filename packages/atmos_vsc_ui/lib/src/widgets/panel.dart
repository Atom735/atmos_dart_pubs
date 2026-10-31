import 'package:atmos_vsc_codicon_flutter/atmos_vsc_codicon_flutter.dart';
import 'package:flutter/widgets.dart';

import '../theme/vsc_ui_theme.dart';
import 'pressable.dart';

/// One tab in the bottom [VscPanel].
class VscPanelTab {
  /// Creates a panel tab.
  const VscPanelTab({
    required this.id,
    required this.label,
    this.icon,
  });

  /// Stable id.
  final String id;

  /// Tab label.
  final String label;

  /// Optional leading icon.
  final Widget? icon;
}

/// Bottom panel (Terminal, Problems, Output).
class VscPanel extends StatelessWidget {
  /// Creates a panel.
  const VscPanel({
    super.key,
    required this.tabs,
    required this.selectedId,
    required this.child,
    this.onSelected,
    this.onClose,
  });

  /// Panel tabs.
  final List<VscPanelTab> tabs;

  /// Active tab id.
  final String? selectedId;

  /// Body of the active tab.
  final Widget child;

  /// Tab selection callback.
  final ValueChanged<String>? onSelected;

  /// Close / hide callback.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.editorBackground,
        border: Border(top: BorderSide(color: theme.tabBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 28,
            child: Row(
              children: [
                for (final tab in tabs)
                  VscPressable(
                    onTap: onSelected == null
                        ? null
                        : () => onSelected!(tab.id),
                    backgroundColor: tab.id == selectedId
                        ? theme.tabActiveBackground
                        : null,
                    hoverColor: theme.listHoverBackground,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          if (tab.icon != null) ...[
                            IconTheme(
                              data: IconThemeData(
                                color: theme.tabActiveForeground,
                                size: 14,
                              ),
                              child: tab.icon!,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            tab.label,
                            style: TextStyle(
                              color: tab.id == selectedId
                                  ? theme.tabActiveForeground
                                  : theme.tabInactiveForeground,
                              fontSize: 11,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const Spacer(),
                if (onClose != null)
                  VscPressable(
                    onTap: onClose,
                    tooltip: 'Hide panel',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: VscCodicon(
                        VscCodicons.chevronDown,
                        size: 14,
                        color: theme.tabInactiveForeground,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: DefaultTextStyle(
              style: TextStyle(
                color: theme.editorForeground,
                fontSize: 13,
                decoration: TextDecoration.none,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
