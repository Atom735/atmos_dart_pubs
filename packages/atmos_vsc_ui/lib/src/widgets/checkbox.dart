import 'package:atmos_vsc_codicon_flutter/atmos_vsc_codicon_flutter.dart';
import 'package:flutter/widgets.dart';

import '../theme/vsc_ui_theme.dart';
import 'pressable.dart';

/// VS Code-like checkbox with an optional label.
class VscCheckbox extends StatelessWidget {
  /// Creates a checkbox.
  const VscCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  /// Whether the box is checked.
  final bool value;

  /// Called with the next value. Null disables the control.
  final ValueChanged<bool>? onChanged;

  /// Optional label to the right of the box.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    final fg = theme.editorForeground;
    return VscPressable(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: value ? theme.focusBorder : theme.inputBackground,
                border: Border.all(
                  color: value ? theme.focusBorder : theme.inputBorder,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
              child: SizedBox(
                width: 16,
                height: 16,
                child: value
                    ? const Center(
                        child: VscCodicon(
                          VscCodicons.check,
                          size: 12,
                          color: Color(0xFFFFFFFF),
                        ),
                      )
                    : null,
              ),
            ),
            if (label != null) ...[
              const SizedBox(width: 8),
              Text(
                label!,
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
