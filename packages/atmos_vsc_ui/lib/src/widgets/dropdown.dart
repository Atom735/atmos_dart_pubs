import 'package:atmos_vsc_codicon_flutter/atmos_vsc_codicon_flutter.dart';
import 'package:flutter/widgets.dart';

import '../theme/vsc_ui_theme.dart';
import 'pressable.dart';

/// One option in a [VscDropdown].
class VscDropdownItem<T> {
  /// Creates an option.
  const VscDropdownItem({required this.value, required this.label});

  /// Value reported to [VscDropdown.onChanged].
  final T value;

  /// Visible label.
  final String label;
}

/// VS Code-like select that expands its option list in place.
class VscDropdown<T> extends StatefulWidget {
  /// Creates a dropdown.
  const VscDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  /// Currently selected value.
  final T value;

  /// Options.
  final List<VscDropdownItem<T>> items;

  /// Called when an option is chosen.
  final ValueChanged<T> onChanged;

  @override
  State<VscDropdown<T>> createState() => _VscDropdownState<T>();
}

class _VscDropdownState<T> extends State<VscDropdown<T>> {
  bool _open = false;

  String get _label {
    for (final item in widget.items) {
      if (item.value == widget.value) return item.label;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        VscPressable(
          onTap: () => setState(() => _open = !_open),
          backgroundColor: theme.inputBackground,
          hoverColor: theme.listHoverBackground,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _label,
                    style: TextStyle(
                      color: theme.inputForeground,
                      fontSize: 13,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                VscCodicon(
                  _open ? VscCodicons.chevronUp : VscCodicons.chevronDown,
                  size: 14,
                  color: theme.inputForeground,
                ),
              ],
            ),
          ),
        ),
        if (_open)
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.widgetBackground,
              border: Border.all(color: theme.inputBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final item in widget.items)
                  VscPressable(
                    onTap: () {
                      setState(() => _open = false);
                      widget.onChanged(item.value);
                    },
                    backgroundColor: item.value == widget.value
                        ? theme.listActiveSelectionBackground
                        : null,
                    hoverColor: theme.listHoverBackground,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: theme.editorForeground,
                          fontSize: 13,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
