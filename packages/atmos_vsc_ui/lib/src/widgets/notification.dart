import 'package:atmos_vsc_codicon_flutter/atmos_vsc_codicon_flutter.dart';
import 'package:flutter/widgets.dart';

import '../theme/vsc_ui_theme.dart';
import 'pressable.dart';

/// Toast card, like a VS Code notification.
class VscNotification extends StatelessWidget {
  /// Creates a notification card.
  const VscNotification({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.onClose,
  });

  /// Notification title.
  final String title;

  /// Optional body.
  final String? message;

  /// Leading icon. Defaults to a bell.
  final Widget? icon;

  /// Close callback.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.widgetBackground,
        border: Border.all(color: theme.inputBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            icon ??
                VscCodicon(
                  VscCodicons.bell,
                  size: 16,
                  color: theme.focusBorder,
                ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.editorForeground,
                      fontSize: 13,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      message!,
                      style: TextStyle(
                        color: theme.editorForeground.withOpacity(0.75),
                        fontSize: 12,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onClose != null)
              VscPressable(
                onTap: onClose,
                child: VscCodicon(
                  VscCodicons.close,
                  size: 14,
                  color: theme.editorForeground,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
