import 'locale.dart';

/// One language table: NLS key → message.
///
/// ## ENG
/// Contents of `package.nls.json` / `bundle.l10n.<locale>.json`
/// (string values; nested `{ message }` objects are accepted by the loader).
///
/// ## RU
/// Содержимое `package.nls.json` / `bundle.l10n.<locale>.json`.
class VscNlsTable {
  /// Creates a table.
  const VscNlsTable(this.messages, {this.locale = VscLocale.defaultLocale});

  /// Empty table.
  static const empty = VscNlsTable({});

  /// Key → message.
  final Map<String, String> messages;

  /// Locale this table was loaded for.
  final VscLocale locale;

  /// Lookup without fallback.
  String? operator [](String key) => messages[key];

  /// Whether [key] exists.
  bool containsKey(String key) => messages.containsKey(key);

  /// Number of entries.
  int get length => messages.length;

  /// Merges [other] over this (same [locale]; [other] wins on conflict).
  VscNlsTable merge(VscNlsTable other) {
    return VscNlsTable(
      {...messages, ...other.messages},
      locale: locale,
    );
  }
}

/// Multi-locale message store with VS Code-style fallback.
class VscNlsBundle {
  /// Creates a bundle from locale → table.
  VscNlsBundle({
    VscNlsTable? defaults,
    Map<VscLocale, VscNlsTable>? tables,
  }) : _tables = {
          if (defaults != null) VscLocale.defaultLocale: defaults,
          ...?tables,
        };

  final Map<VscLocale, VscNlsTable> _tables;

  /// Default / source strings (`package.nls.json`).
  VscNlsTable get defaults =>
      _tables[VscLocale.defaultLocale] ?? VscNlsTable.empty;

  /// All loaded tables.
  Map<VscLocale, VscNlsTable> get tables =>
      Map<VscLocale, VscNlsTable>.unmodifiable(_tables);

  /// Adds or replaces a locale table.
  void addTable(VscNlsTable table) {
    _tables[table.locale] = table;
  }

  /// Merges [other] into this (per-locale; other wins on key conflict).
  void merge(VscNlsBundle other) {
    for (final entry in other._tables.entries) {
      final existing = _tables[entry.key];
      _tables[entry.key] =
          existing == null ? entry.value : existing.merge(entry.value);
    }
  }

  /// Resolves [key] for [locale] with fallback chain.
  ///
  /// Returns `null` if missing everywhere.
  String? lookup(String key, {VscLocale locale = VscLocale.defaultLocale}) {
    for (final step in locale.fallbackChain) {
      final value = _tables[step]?[key];
      if (value != null) return value;
    }
    return null;
  }

  /// Like [lookup], but falls back to [fallback] / [key] when missing.
  String translate(
    String key, {
    VscLocale locale = VscLocale.defaultLocale,
    String? fallback,
  }) =>
      lookup(key, locale: locale) ?? fallback ?? key;

  /// Keys present in [defaults] but missing for [locale] (no fallback fill).
  List<String> missingKeys(VscLocale locale) {
    if (locale.isDefault) return const [];
    final table = _tables[locale];
    if (table == null) {
      return defaults.messages.keys.toList(growable: false);
    }
    return defaults.messages.keys
        .where((k) => !table.containsKey(k))
        .toList(growable: false);
  }
}
