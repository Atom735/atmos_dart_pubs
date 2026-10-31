import 'package:flutter/widgets.dart';

import 'vsc_codicons.g.dart';

part 'vsc_codicon_catalog.g.dart';

/// One product-icon id and the glyph it selects.
class VscCodiconInfo {
  /// Creates a catalog entry.
  const VscCodiconInfo({
    required this.id,
    required this.dartName,
    required this.icon,
    required this.primary,
    this.category,
    this.description,
  });

  /// Kebab-case id used as `$(id)` in VS Code.
  ///
  /// Kebab-case id для `$(id)` в VS Code.
  final String id;

  /// CamelCase member on `VscCodicons` (`git-pull-request` → `gitPullRequest`).
  ///
  /// CamelCase-член `VscCodicons` (`git-pull-request` → `gitPullRequest`).
  final String dartName;

  /// Glyph. Aliases of the same shape share [codePoint].
  ///
  /// Глиф. Алиасы одной фигуры делят [codePoint].
  final IconData icon;

  /// True for the first name of this code point in `mapping.json`.
  ///
  /// Истина для первого имени кодпоинта в `mapping.json`.
  final bool primary;

  /// Upstream category, when this id has metadata.
  ///
  /// Категория upstream, если у id есть metadata.
  final String? category;

  /// Upstream description, when this id has metadata.
  ///
  /// Описание upstream, если у id есть metadata.
  final String? description;

  /// Unicode scalar stored in the Codicon font.
  ///
  /// Скаляр Unicode в шрифте Codicon.
  int get codePoint => icon.codePoint;
}

/// Full Codicon set: ids, code points, and `$(id)` lookup.
///
/// ## ENG
/// [all] follows `mapping.json` order. [resolve] accepts a bare id
/// (`git-pull-request`), a product-icon token (`$(git-pull-request)`),
/// a `codicon-` CSS class, or the camelCase Dart name.
///
/// ## RU
/// [all] идёт в порядке `mapping.json`. [resolve] принимает голый id
/// (`git-pull-request`), токен (`$(git-pull-request)`), CSS-класс
/// `codicon-…` или camelCase-имя Dart.
abstract final class VscCodiconCatalog {
  /// Font version string from upstream `package.json`.
  ///
  /// Версия шрифта из upstream `package.json`.
  static const String upstreamFontVersion = _upstreamFontVersion;

  /// Submodule commit the font and this catalog were generated from.
  ///
  /// Коммит сабмодуля, из которого собраны шрифт и этот каталог.
  static const String upstreamCommit = _upstreamCommit;

  /// Distinct Unicode scalars in the font mapping.
  ///
  /// Число различных скаляров Unicode в таблице.
  static const int codepointCount = _codepointCount;

  /// Icon ids, including aliases.
  ///
  /// Число id, включая алиасы.
  static const int iconCount = _iconCount;

  /// Every id, in upstream order.
  ///
  /// Все id в порядке upstream.
  static const List<VscCodiconInfo> all = _all;

  /// Kebab-case id → glyph.
  ///
  /// Kebab-case id → глиф.
  static const Map<String, IconData> byId = _byId;

  /// Sorted upstream categories (`action`, `debug`, …).
  ///
  /// Категории upstream по алфавиту (`action`, `debug`, …).
  static final List<String> categories = _collectCategories();

  /// Code point → category of its primary name.
  ///
  /// Кодпоинт → категория первичного имени.
  static final Map<int, String> categoryByCodePoint =
      _collectCategoryByCodePoint();

  /// Strips `$(...)` and a leading `codicon-`, then looks the id up.
  ///
  /// Снимает `$(...)` и префикс `codicon-`, затем ищет id.
  ///
  /// Returns null when [ref] is empty or unknown.
  ///
  /// Возвращает null, если [ref] пустой или неизвестен.
  static IconData? resolve(String ref) {
    final id = normalize(ref);
    if (id.isEmpty) return null;
    return byId[id] ?? _byDartName[id];
  }

  /// Catalog row for [ref], including aliases and the Dart member name.
  ///
  /// Строка каталога для [ref], включая алиасы и имя члена Dart.
  ///
  /// Same syntax as [resolve]. Returns null when [ref] is empty or unknown.
  ///
  /// Синтаксис как у [resolve]. Null, если [ref] пустой или неизвестен.
  static VscCodiconInfo? find(String ref) {
    final id = normalize(ref);
    if (id.isEmpty) return null;
    for (final info in all) {
      if (info.id == id || info.dartName == id) return info;
    }
    return null;
  }

  /// Every id that draws [codePoint], primary name first.
  ///
  /// Все id, которые рисуют [codePoint]. Первым идёт первичное имя.
  static List<VscCodiconInfo> namesFor(int codePoint) {
    return [
      for (final info in all)
        if (info.codePoint == codePoint) info,
    ];
  }

  /// Product-icon token or CSS class → bare id. Does not check existence.
  ///
  /// Токен или CSS-класс → голый id. Наличие в каталоге не проверяет.
  static String normalize(String ref) {
    var id = ref.trim();
    if (id.length >= 3 && id.startsWith(r'$(') && id.endsWith(')')) {
      id = id.substring(2, id.length - 1).trim();
    }
    const prefix = 'codicon-';
    if (id.startsWith(prefix)) {
      id = id.substring(prefix.length);
    }
    return id;
  }

  static List<String> _collectCategories() {
    final names = <String>{
      for (final info in all)
        if (info.category != null) info.category!,
    }.toList()
      ..sort();
    return List.unmodifiable(names);
  }

  static Map<int, String> _collectCategoryByCodePoint() {
    return Map.unmodifiable({
      for (final info in all)
        if (info.primary && info.category != null)
          info.codePoint: info.category,
    });
  }
}
