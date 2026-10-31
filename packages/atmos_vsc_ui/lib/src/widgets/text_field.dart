import 'package:flutter/widgets.dart';

import '../theme/vsc_ui_theme.dart';

/// Single-line VS Code-like input.
class VscTextField extends StatefulWidget {
  /// Creates a text field.
  const VscTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder = '',
    this.onChanged,
  });

  /// Text controller. Created internally when omitted.
  final TextEditingController? controller;

  /// Focus node. Created internally when omitted.
  final FocusNode? focusNode;

  /// Hint shown while the field is empty.
  final String placeholder;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  @override
  State<VscTextField> createState() => _VscTextFieldState();
}

class _VscTextFieldState extends State<VscTextField> {
  TextEditingController? _ownedController;
  FocusNode? _ownedFocus;
  bool _focused = false;

  TextEditingController get _controller =>
      widget.controller ?? _ownedController!;

  FocusNode get _focus => widget.focusNode ?? _ownedFocus!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownedController = TextEditingController();
    }
    if (widget.focusNode == null) {
      _ownedFocus = FocusNode();
    }
    _controller.addListener(_onText);
    _focus.addListener(_onFocus);
  }

  @override
  void dispose() {
    _controller.removeListener(_onText);
    _focus.removeListener(_onFocus);
    _ownedController?.dispose();
    _ownedFocus?.dispose();
    super.dispose();
  }

  void _onText() {
    setState(() {});
    widget.onChanged?.call(_controller.text);
  }

  void _onFocus() => setState(() => _focused = _focus.hasFocus);

  @override
  Widget build(BuildContext context) {
    final theme = VscUiTheme.of(context);
    final empty = _controller.text.isEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.inputBackground,
        border: Border.all(
          color: _focused ? theme.focusBorder : theme.inputBorder,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            if (empty && widget.placeholder.isNotEmpty)
              IgnorePointer(
                child: Text(
                  widget.placeholder,
                  style: TextStyle(
                    color: theme.inputForeground.withOpacity(0.45),
                    fontSize: 13,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            EditableText(
              controller: _controller,
              focusNode: _focus,
              style: TextStyle(
                color: theme.inputForeground,
                fontSize: 13,
                decoration: TextDecoration.none,
              ),
              cursorColor: theme.focusBorder,
              backgroundCursorColor: theme.focusBorder,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
