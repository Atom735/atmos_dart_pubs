import 'dart:async';
import 'dart:ui' show Brightness;

import 'package:atmos_local_fonts/atmos_local_fonts.dart';
import 'package:atmos_local_fonts_flutter/atmos_local_fonts_flutter.dart';
import 'package:atmos_local_fonts_web/atmos_local_fonts_web.dart';
import 'package:flutter/widgets.dart';

import 'sample_texts.dart';

const Color _bg = Color(0xFF1E1E1E);
const Color _side = Color(0xFF252526);
const Color _line = Color(0xFF3C3C3C);
const Color _fg = Color(0xFFD4D4D4);
const Color _muted = Color(0xFF858585);
const Color _accent = Color(0xFF007ACC);
const Color _input = Color(0xFF3C3C3C);
const Color _selectedRow = Color(0xFF094771);
const Color _errorFg = Color(0xFFF48771);

const List<int> _sizes = <int>[18, 28, 48, 72];

/// Font list on the left, sample text on the right.
///
/// Слева список шрифтов, справа образец текста.
class FontPreviewApp extends StatefulWidget {
  /// Creates the preview.
  ///
  /// [source] defaults to the browser local-font source.
  /// [loadFiles] defaults to Flutter's font loader.
  ///
  /// Создаёт просмотр.
  /// [source] по умолчанию — браузерный источник.
  /// [loadFiles] по умолчанию — загрузчик Flutter.
  const FontPreviewApp({
    super.key,
    this.source,
    this.loadFiles,
  });

  /// Where the face list comes from.
  ///
  /// Откуда берётся список начертаний.
  final LocalFontSource? source;

  /// Registers face bytes. Tests pass a fake.
  ///
  /// Регистрирует байты. Тесты подставляют заглушку.
  final LocalFontFileLoader? loadFiles;

  @override
  State<FontPreviewApp> createState() => _FontPreviewAppState();
}

class _FontPreviewAppState extends State<FontPreviewApp> {
  late final FlutterLocalFonts _fonts;
  late final TextEditingController _filter;
  late final TextEditingController _text;
  late final FocusNode _filterFocus;
  late final FocusNode _textFocus;
  late final ScrollController _listScroll;
  late final ScrollController _previewScroll;

  String? _selected;
  String? _sampleId = defaultPreviewSample.id;
  int _size = 48;
  bool _bold = false;
  bool _italic = false;
  String? _error;
  var _applyingSample = false;

  @override
  void initState() {
    super.initState();
    _fonts = FlutterLocalFonts(
      widget.source ?? const WebLocalFontSource(),
      loadFiles: widget.loadFiles,
    );
    _fonts.addListener(_onFonts);
    _filter = TextEditingController();
    _filter.addListener(_onFilter);
    _text = TextEditingController(text: defaultPreviewSample.text);
    _text.addListener(_onText);
    _filterFocus = FocusNode();
    _textFocus = FocusNode();
    _listScroll = ScrollController();
    _previewScroll = ScrollController();
  }

  @override
  void dispose() {
    _fonts.removeListener(_onFonts);
    _fonts.dispose();
    _filter
      ..removeListener(_onFilter)
      ..dispose();
    _text
      ..removeListener(_onText)
      ..dispose();
    _filterFocus.dispose();
    _textFocus.dispose();
    _listScroll.dispose();
    _previewScroll.dispose();
    super.dispose();
  }

  void _onFonts() {
    if (mounted) setState(() {});
  }

  void _onFilter() {
    if (mounted) setState(() {});
  }

  void _onText() {
    if (_applyingSample || !mounted) return;
    PreviewSample? match;
    for (final sample in previewSamples) {
      if (sample.text == _text.text) {
        match = sample;
        break;
      }
    }
    setState(() => _sampleId = match?.id);
  }

  Future<void> _reload() async {
    setState(() => _error = null);
    try {
      await _fonts.query();
      if (!mounted) return;
      final selected = _selected;
      if (selected != null && !_fonts.families.contains(selected)) {
        setState(() => _selected = null);
      }
    } on LocalFontsNotAllowedException {
      _showError(
        'Доступ к шрифтам отклонён. Разрешите его в браузере и повторите.',
      );
    } on LocalFontsUnsupportedException {
      _showError('Список системных шрифтов доступен в Chrome и Edge.');
    } on Object catch (error) {
      _showError('$error');
    }
  }

  Future<void> _selectFamily(String family) async {
    setState(() {
      _selected = family;
      _error = null;
    });
    try {
      await _fonts.loadFamily(family);
    } on Object catch (error) {
      _showError('$error');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => _error = message);
  }

  void _applySample(PreviewSample sample) {
    _applyingSample = true;
    _text.value = TextEditingValue(
      text: sample.text,
      selection: TextSelection.collapsed(offset: sample.text.length),
    );
    _applyingSample = false;
    setState(() => _sampleId = sample.id);
  }

  List<String> get _visibleFamilies {
    final query = _filter.text.trim().toLowerCase();
    final names = _fonts.families.toList()
      ..sort(
        (String a, String b) => a.toLowerCase().compareTo(b.toLowerCase()),
      );
    if (query.isEmpty) return names;
    return <String>[
      for (final name in names)
        if (name.toLowerCase().contains(query)) name,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Системные шрифты',
      color: _accent,
      debugShowCheckedModeBanner: false,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        return PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return builder(context);
          },
        );
      },
      textStyle: const TextStyle(
        color: _fg,
        fontSize: 13,
        decoration: TextDecoration.none,
      ),
      home: ColoredBox(
        color: _bg,
        child: Column(
          children: <Widget>[
            _header(),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(width: 300, child: _sidebar()),
                  const ColoredBox(
                    color: _line,
                    child: SizedBox(width: 1),
                  ),
                  Expanded(child: _preview()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    final count = _fonts.families.length;
    final status = _fonts.isLoading
        ? 'Загрузка…'
        : count == 0
            ? 'Список ещё не прочитан'
            : '$count семейств';
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _side,
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                'Системные шрифты',
                style: TextStyle(
                  color: _fg,
                  fontSize: 14,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            Text(
              status,
              style: const TextStyle(
                color: _muted,
                fontSize: 12,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebar() {
    return ColoredBox(
      color: _side,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _field(
              controller: _filter,
              focusNode: _filterFocus,
              hint: 'Фильтр',
              fieldKey: const Key('font-filter'),
              maxLines: 1,
            ),
            const SizedBox(height: 8),
            if (_fonts.isSupported)
              _Chip(
                key: const Key('load-fonts'),
                label: _fonts.families.isEmpty
                    ? 'Загрузить список'
                    : 'Обновить список',
                selected: true,
                onTap: _fonts.isLoading ? null : () => unawaited(_reload()),
              )
            else
              const Text(
                'Нужен Chrome или Edge.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                  decoration: TextDecoration.none,
                ),
              ),
            if (_error != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(
                  color: _errorFg,
                  fontSize: 12,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Expanded(child: _familyList()),
          ],
        ),
      ),
    );
  }

  Widget _familyList() {
    if (_fonts.isLoading && _fonts.families.isEmpty) {
      return const Center(
        child: Text(
          'Читаем шрифты…',
          style: TextStyle(
            color: _muted,
            decoration: TextDecoration.none,
          ),
        ),
      );
    }
    final families = _visibleFamilies;
    if (families.isEmpty) {
      final hint = _fonts.families.isEmpty
          ? 'Нажмите «Загрузить список».'
          : 'Нет совпадений.';
      return Center(
        child: Text(
          hint,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _muted,
            decoration: TextDecoration.none,
          ),
        ),
      );
    }
    return RawScrollbar(
      controller: _listScroll,
      thumbVisibility: true,
      child: ListView.builder(
        controller: _listScroll,
        primary: false,
        itemCount: families.length,
        itemBuilder: (BuildContext context, int index) {
          final family = families[index];
          final selected = family == _selected;
          return GestureDetector(
            key: Key('family-$family'),
            behavior: HitTestBehavior.opaque,
            onTap: () => unawaited(_selectFamily(family)),
            child: ColoredBox(
              color: selected ? _selectedRow : const Color(0x00000000),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 7,
                ),
                child: Text(
                  family,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _fg,
                    fontSize: 13,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _preview() {
    final family = _selected;
    final loaded = family != null && _fonts.isFamilyLoaded(family);
    final raw = _text.text;
    final shown = raw.isEmpty ? 'Введите текст…' : raw;
    return ColoredBox(
      color: _bg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                for (final sample in previewSamples)
                  _Chip(
                    label: sample.label,
                    selected: sample.id == _sampleId,
                    onTap: () => _applySample(sample),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                for (final size in _sizes)
                  _Chip(
                    label: '$size',
                    selected: size == _size,
                    onTap: () => setState(() => _size = size),
                  ),
                _Chip(
                  label: 'Жирный',
                  selected: _bold,
                  onTap: () => setState(() => _bold = !_bold),
                ),
                _Chip(
                  label: 'Курсив',
                  selected: _italic,
                  onTap: () => setState(() => _italic = !_italic),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _field(
              controller: _text,
              focusNode: _textFocus,
              hint: 'Свой текст',
              fieldKey: const Key('preview-input'),
              maxLines: 4,
            ),
            const SizedBox(height: 8),
            Text(
              _caption(family, loaded),
              style: const TextStyle(
                color: _muted,
                fontSize: 12,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _side,
                  border: Border.all(color: _line),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: RawScrollbar(
                  controller: _previewScroll,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _previewScroll,
                    primary: false,
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      shown,
                      key: const Key('font-preview'),
                      style: TextStyle(
                        color: raw.isEmpty ? _muted : _fg,
                        fontFamily: loaded ? family : null,
                        fontSize: _size.toDouble(),
                        height: 1.35,
                        fontWeight: _bold ? FontWeight.w700 : FontWeight.w400,
                        fontStyle:
                            _italic ? FontStyle.italic : FontStyle.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _caption(String? family, bool loaded) {
    if (family == null) return 'Выберите шрифт слева';
    if (!loaded) {
      return _fonts.isLoading ? 'Загрузка $family…' : family;
    }
    final styles = _fonts
        .facesOf(family)
        .map((LocalFontFace face) => face.style)
        .join(', ');
    return '$family · $styles';
  }

  Widget _field({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required Key fieldKey,
    required int maxLines,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _input,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Stack(
          children: <Widget>[
            if (controller.text.isEmpty)
              IgnorePointer(
                child: Text(
                  hint,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            EditableText(
              key: fieldKey,
              controller: controller,
              focusNode: focusNode,
              maxLines: maxLines,
              style: const TextStyle(
                color: _fg,
                fontSize: 13,
                decoration: TextDecoration.none,
              ),
              cursorColor: _accent,
              backgroundCursorColor: _muted,
              selectionColor: const Color(0x66007ACC),
              keyboardAppearance: Brightness.dark,
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: MouseRegion(
        cursor:
            onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? _accent : _input,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              label,
              style: TextStyle(
                color: onTap == null ? _muted : _fg,
                fontSize: 12,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
