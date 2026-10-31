import 'package:atmos_vsc_codicon_flutter/atmos_vsc_codicon_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Dark gallery of every bundled Codicon.
class CodiconGalleryApp extends StatelessWidget {
  /// Creates the gallery app.
  const CodiconGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Codicons',
      color: const Color(0xFF007ACC),
      debugShowCheckedModeBanner: false,
      pageRouteBuilder: <T>(settings, builder) {
        return PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) {
            return builder(context);
          },
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            return child;
          },
        );
      },
      home: const CodiconGallery(),
    );
  }
}

/// Searchable grid plus a detail pane for the selected glyph.
class CodiconGallery extends StatefulWidget {
  /// Creates the gallery body.
  const CodiconGallery({super.key});

  @override
  State<CodiconGallery> createState() => _CodiconGalleryState();
}

class _CodiconGalleryState extends State<CodiconGallery> {
  final TextEditingController _query = TextEditingController();
  final FocusNode _queryFocus = FocusNode();
  String _selectedId = 'search';
  String? _category;
  bool _aliases = false;
  String? _copied;

  @override
  void dispose() {
    _query.dispose();
    _queryFocus.dispose();
    super.dispose();
  }

  List<VscCodiconInfo> get _visible {
    final q = _query.text.trim().toLowerCase();
    return [
      for (final info in VscCodiconCatalog.all)
        if (_matches(info, q)) info,
    ];
  }

  bool _matches(VscCodiconInfo info, String q) {
    final category = _category;
    if (category != null &&
        VscCodiconCatalog.categoryByCodePoint[info.codePoint] != category) {
      return false;
    }
    if (!_aliases && q.isEmpty && !info.primary) return false;
    if (q.isEmpty) return true;
    if (info.id.contains(q)) return true;
    if (info.codePoint.toRadixString(16).contains(q)) return true;
    final description = info.description?.toLowerCase();
    if (description != null && description.contains(q)) return true;
    final infoCategory = info.category?.toLowerCase();
    return infoCategory != null && infoCategory.contains(q);
  }

  VscCodiconInfo? get _selected {
    for (final info in VscCodiconCatalog.all) {
      if (info.id == _selectedId) return info;
    }
    return null;
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    setState(() => _copied = text);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final selected = _selected;
    return ColoredBox(
      color: const Color(0xFF1E1E1E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            query: _query,
            queryFocus: _queryFocus,
            aliases: _aliases,
            category: _category,
            shown: visible.length,
            onQuery: () => setState(() {}),
            onAliases: (value) => setState(() => _aliases = value),
            onCategory: (value) => setState(() => _category = value),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final grid = _Grid(
                  items: visible,
                  selectedId: _selectedId,
                  onSelect: (id) => setState(() => _selectedId = id),
                );
                final detail = _Detail(
                  info: selected,
                  copied: _copied,
                  onCopy: _copy,
                );
                if (constraints.maxWidth < 640) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: grid),
                      _SelectedBar(info: selected),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: grid),
                    SizedBox(width: 300, child: detail),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.query,
    required this.queryFocus,
    required this.aliases,
    required this.category,
    required this.shown,
    required this.onQuery,
    required this.onAliases,
    required this.onCategory,
  });

  final TextEditingController query;
  final FocusNode queryFocus;
  final bool aliases;
  final String? category;
  final int shown;
  final VoidCallback onQuery;
  final ValueChanged<bool> onAliases;
  final ValueChanged<String?> onCategory;

  @override
  Widget build(BuildContext context) {
    const version = VscCodiconCatalog.upstreamFontVersion;
    const points = VscCodiconCatalog.codepointCount;
    const icons = VscCodiconCatalog.iconCount;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF252526),
        border: Border(
          bottom: BorderSide(color: Color(0xFF3C3C3C)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Codicons',
              style: TextStyle(
                color: Color(0xFFCCCCCC),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'font $version · $points code points · '
              '$icons ids · showing $shown',
              style: const TextStyle(
                color: Color(0xFF858585),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _SearchBox(
                    controller: query,
                    focusNode: queryFocus,
                    onChanged: onQuery,
                  ),
                ),
                const SizedBox(width: 12),
                _AliasToggle(
                  aliases: aliases,
                  onChanged: onAliases,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _CategoryBar(
              selected: category,
              onSelected: onCategory,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.selected,
    required this.onSelected,
  });

  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final categories = VscCodiconCatalog.categories;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _ToggleLabel(
          label: 'All',
          selected: selected == null,
          onTap: () => onSelected(null),
        ),
        for (final name in categories)
          _ToggleLabel(
            label: name,
            selected: selected == name,
            onTap: () => onSelected(name),
          ),
      ],
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF3C3C3C),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          height: 28,
          child: Row(
            children: [
              const VscCodicon(
                VscCodicons.search,
                color: Color(0xFF858585),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    if (controller.text.isEmpty)
                      const IgnorePointer(
                        child: Text(
                          'id, code point, description',
                          style: TextStyle(
                            color: Color(0xFF858585),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    EditableText(
                      controller: controller,
                      focusNode: focusNode,
                      style: const TextStyle(
                        color: Color(0xFFCCCCCC),
                        fontSize: 13,
                      ),
                      cursorColor: const Color(0xFFAEAFAD),
                      backgroundCursorColor: const Color(0xFF3C3C3C),
                      selectionColor: const Color(0xFF264F78),
                      keyboardAppearance: Brightness.dark,
                      onChanged: (_) => onChanged(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AliasToggle extends StatelessWidget {
  const _AliasToggle({
    required this.aliases,
    required this.onChanged,
  });

  final bool aliases;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ToggleLabel(
          label: 'Primary',
          selected: !aliases,
          onTap: () => onChanged(false),
        ),
        const SizedBox(width: 8),
        _ToggleLabel(
          label: 'All',
          selected: aliases,
          onTap: () => onChanged(true),
        ),
      ],
    );
  }
}

class _ToggleLabel extends StatelessWidget {
  const _ToggleLabel({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF094771) : const Color(0xFF3C3C3C),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFCCCCCC),
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.items,
    required this.selectedId,
    required this.onSelect,
  });

  final List<VscCodiconInfo> items;
  final String selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No icons',
          style: TextStyle(color: Color(0xFF858585)),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 112,
        mainAxisExtent: 84,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final info = items[index];
        final selected = info.id == selectedId;
        return GestureDetector(
          onTap: () => onSelect(info.id),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color:
                  selected ? const Color(0xFF094771) : const Color(0xFF252526),
              border: Border.all(
                color: selected
                    ? const Color(0xFF007ACC)
                    : const Color(0xFF3C3C3C),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
              child: Column(
                children: [
                  VscCodicon(
                    info.icon,
                    size: 22,
                    color: const Color(0xFFCCCCCC),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    info.id,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFCCCCCC),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({
    required this.info,
    required this.copied,
    required this.onCopy,
  });

  final VscCodiconInfo? info;
  final String? copied;
  final Future<void> Function(String text) onCopy;

  @override
  Widget build(BuildContext context) {
    final item = info;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF252526),
        border: Border(
          left: BorderSide(color: Color(0xFF3C3C3C)),
        ),
      ),
      child: item == null
          ? const Center(
              child: Text(
                'Nothing selected',
                style: TextStyle(color: Color(0xFF858585)),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: VscCodicon(
                    item.icon,
                    size: 48,
                    color: const Color(0xFFCCCCCC),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.id,
                  style: const TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _CopyRow(
                  label: 'VscCodicons.${item.dartName}',
                  copied: copied,
                  onCopy: () => onCopy('VscCodicons.${item.dartName}'),
                ),
                const SizedBox(height: 6),
                _CopyRow(
                  label: '\$(${item.id})',
                  copied: copied,
                  onCopy: () => onCopy('\$(${item.id})'),
                ),
                const SizedBox(height: 6),
                _CopyRow(
                  label: _hex(item.codePoint),
                  copied: copied,
                  onCopy: () => onCopy(_hex(item.codePoint)),
                ),
                if (item.category != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    item.category!,
                    style: const TextStyle(
                      color: Color(0xFF858585),
                      fontSize: 12,
                    ),
                  ),
                ],
                if (item.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.description!,
                    style: const TextStyle(
                      color: Color(0xFFCCCCCC),
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                const Text(
                  'Same code point',
                  style: TextStyle(
                    color: Color(0xFF858585),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                for (final alias in VscCodiconCatalog.all)
                  if (alias.codePoint == item.codePoint)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        alias.id,
                        style: const TextStyle(
                          color: Color(0xFFCCCCCC),
                          fontSize: 12,
                        ),
                      ),
                    ),
              ],
            ),
    );
  }

  static String _hex(int codePoint) {
    return 'U+${codePoint.toRadixString(16).toUpperCase()}';
  }
}

class _SelectedBar extends StatelessWidget {
  const _SelectedBar({required this.info});

  final VscCodiconInfo? info;

  @override
  Widget build(BuildContext context) {
    final item = info;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF252526),
        border: Border(
          top: BorderSide(color: Color(0xFF3C3C3C)),
        ),
      ),
      child: SizedBox(
        height: 40,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: item == null
              ? const SizedBox.shrink()
              : Row(
                  children: [
                    VscCodicon(
                      item.icon,
                      size: 16,
                      color: const Color(0xFFCCCCCC),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.id,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFCCCCCC),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      'U+${item.codePoint.toRadixString(16).toUpperCase()}',
                      style: const TextStyle(
                        color: Color(0xFF4FC1FF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _CopyRow extends StatelessWidget {
  const _CopyRow({
    required this.label,
    required this.copied,
    required this.onCopy,
  });

  final String label;
  final String? copied;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final done = copied == label;
    return GestureDetector(
      onTap: onCopy,
      child: Text(
        done ? '$label  copied' : label,
        style: TextStyle(
          color: done ? const Color(0xFF89D185) : const Color(0xFF4FC1FF),
          fontSize: 13,
        ),
      ),
    );
  }
}
