import 'package:atmos_vsc_codicon_flutter/atmos_vsc_codicon_flutter.dart';
import 'package:flutter/widgets.dart';

import 'list_tile.dart';

/// One node in a [VscTree].
class VscTreeNode {
  /// Creates a tree node.
  const VscTreeNode({
    required this.id,
    required this.label,
    this.icon,
    this.children = const [],
  });

  /// Stable id for selection and expansion.
  final String id;

  /// Row label.
  final String label;

  /// Optional leading icon.
  final Widget? icon;

  /// Child nodes. Empty means a leaf.
  final List<VscTreeNode> children;

  /// Whether this node can expand.
  bool get isBranch => children.isNotEmpty;
}

/// Indenting tree, like the Explorer.
class VscTree extends StatefulWidget {
  /// Creates a tree.
  const VscTree({
    super.key,
    required this.nodes,
    this.selectedId,
    this.onSelected,
    this.expandAll = false,
  });

  /// Top-level nodes.
  final List<VscTreeNode> nodes;

  /// Selected node id.
  final String? selectedId;

  /// Called with the tapped node id.
  final ValueChanged<String>? onSelected;

  /// Expands every branch on first build.
  final bool expandAll;

  @override
  State<VscTree> createState() => _VscTreeState();
}

class _VscTreeState extends State<VscTree> {
  final _expanded = <String>{};

  @override
  void initState() {
    super.initState();
    if (widget.expandAll) _expand(widget.nodes);
  }

  void _expand(List<VscTreeNode> nodes) {
    for (final node in nodes) {
      if (node.isBranch) {
        _expanded.add(node.id);
        _expand(node.children);
      }
    }
  }

  void _toggle(VscTreeNode node) {
    setState(() {
      if (!_expanded.add(node.id)) _expanded.remove(node.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final node in widget.nodes) ..._rows(node, 0),
      ],
    );
  }

  List<Widget> _rows(VscTreeNode node, int depth) {
    final open = _expanded.contains(node.id);
    final rows = <Widget>[
      VscListTile(
        label: node.label,
        indent: depth * 12,
        selected: node.id == widget.selectedId,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (node.isBranch)
              VscCodicon(
                open ? VscCodicons.chevronDown : VscCodicons.chevronRight,
                size: 14,
              )
            else
              const SizedBox(width: 14),
            if (node.icon != null) ...[
              const SizedBox(width: 4),
              node.icon!,
            ],
          ],
        ),
        onTap: () {
          if (node.isBranch) _toggle(node);
          widget.onSelected?.call(node.id);
        },
      ),
    ];
    if (node.isBranch && open) {
      for (final child in node.children) {
        rows.addAll(_rows(child, depth + 1));
      }
    }
    return rows;
  }
}
