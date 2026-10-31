import 'package:atmos_vsc_codicon_flutter/atmos_vsc_codicon_flutter.dart';
import 'package:flutter/widgets.dart';

import '../theme/vsc_ui_theme.dart';
import 'pressable.dart';

/// Collapsible settings / view section.
class VscSection extends StatefulWidget {
  /// Creates a section.
  const VscSection({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = true,
  });

  /// Header label.
  final String title;

  /// Body shown while expanded.
  final Widget child;

  /// Whether the body starts visible.
  final bool initiallyExpanded;

  @override
  State<VscSection> createState() => _VscSectionState();
}

class _VscSectionState extends State<VscSection> {
  late bool _open = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VscPressable(
          onTap: () => setState(() => _open = !_open),
          hoverColor: theme.listHoverBackground,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                VscCodicon(
                  _open ? VscCodicons.chevronDown : VscCodicons.chevronRight,
                  size: 14,
                  color: theme.editorForeground,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: theme.editorForeground,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 8, 8),
            child: widget.child,
          ),
      ],
    );
  }
}
