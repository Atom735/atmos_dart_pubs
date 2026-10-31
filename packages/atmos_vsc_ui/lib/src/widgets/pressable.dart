import 'package:flutter/widgets.dart';

/// Tap target with optional hover background (no Material ink).
class VscPressable extends StatefulWidget {
  /// Creates a pressable region.
  const VscPressable({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.hoverColor,
    this.tooltip,
  });

  /// Child content.
  final Widget child;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Resting background.
  final Color? backgroundColor;

  /// Background while hovered.
  final Color? hoverColor;

  /// Optional hover tooltip text.
  final String? tooltip;

  @override
  State<VscPressable> createState() => _VscPressableState();
}

class _VscPressableState extends State<VscPressable> {
  bool _hover = false;
  OverlayEntry? _tip;

  @override
  void dispose() {
    _removeTip();
    super.dispose();
  }

  void _removeTip() {
    _tip?.remove();
    _tip = null;
  }

  void _showTip(BuildContext context) {
    final text = widget.tooltip;
    if (text == null || text.isEmpty) return;
    _removeTip();
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final offset = box.localToGlobal(Offset(box.size.width + 8, 0));
    _tip = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + 8,
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              border: Border.all(color: const Color(0xFF454545)),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xFFCCCCCC),
                  fontSize: 12,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_tip!);
  }

  @override
  Widget build(BuildContext context) {
    final bg = _hover
        ? (widget.hoverColor ?? widget.backgroundColor)
        : widget.backgroundColor;

    final child = MouseRegion(
      onEnter: (_) {
        setState(() => _hover = true);
        _showTip(context);
      },
      onExit: (_) {
        setState(() => _hover = false);
        _removeTip();
      },
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: ColoredBox(
          color: bg ?? const Color(0x00000000),
          child: widget.child,
        ),
      ),
    );

    return child;
  }
}
