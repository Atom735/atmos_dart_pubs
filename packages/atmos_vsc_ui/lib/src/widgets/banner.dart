import 'package:atmos_vsc_codicon_flutter/atmos_vsc_codicon_flutter.dart';
import 'package:flutter/widgets.dart';

import '../theme/vsc_ui_theme.dart';
import 'pressable.dart';

/// Full-width info strip, like a workbench banner.
class VscBanner extends StatelessWidget {
  /// Creates a banner.
  const VscBanner({
    super.key,
    required this.message,
    this.icon,
    this.onClose,
  });

  /// Banner text.
  final String message;

  /// Leading icon. Defaults to an info glyph.
  final Widget? icon;

  /// Close callback. Hides the close button when null.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.widgetBackground,
        border: Border(bottom: BorderSide(color: theme.tabBorder)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            icon ??
                VscCodicon(
                  VscCodicons.info,
                  size: 16,
                  color: theme.focusBorder,
                ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: theme.editorForeground,
                  fontSize: 13,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            if (onClose != null)
              VscPressable(
                onTap: onClose,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: VscCodicon(
                    VscCodicons.close,
                    size: 14,
                    color: theme.editorForeground,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
