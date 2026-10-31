/// BCP-47-ish locale id used for NLS / l10n file lookup.
///
/// ## ENG
/// Fallback chain: `ru-RU` → `ru` → default (empty / `package.nls.json`).
/// Special: [pseudo] applies vowel-doubling after lookup.
///
/// ## RU
/// Цепочка: `ru-RU` → `ru` → дефолт. [pseudo] — псевдолокаль для QA.
class VscLocale {
  /// Creates a locale from a language tag (`ru`, `zh-cn`, `pt-br`, `pseudo`).
  factory VscLocale(String tag) {
    final normalized = _normalize(tag);
    return VscLocale._(normalized);
  }

  const VscLocale._(this.tag);

  /// Default / source language (no locale suffix on files).
  static const VscLocale defaultLocale = VscLocale._('');

  /// Pseudo locale (`--locale=pseudo`): translate then pseudo-localize.
  static const VscLocale pseudo = VscLocale._('pseudo');

  /// Normalized tag (`zh-cn`), or empty for default.
  final String tag;

  /// Whether this is the default (English / source) locale.
  bool get isDefault => tag.isEmpty;

  /// Whether strings should be pseudo-localized after lookup.
  bool get isPseudo => tag == 'pseudo';

  /// Fallback chain from most specific to default (excluding self duplicates).
  List<VscLocale> get fallbackChain {
    if (isDefault) return const [defaultLocale];
    if (isPseudo) return const [pseudo, defaultLocale];
    final out = <VscLocale>[this];
    final parts = tag.split('-');
    if (parts.length > 1) {
      out.add(VscLocale(parts.first));
    }
    out.add(defaultLocale);
    return out;
  }

  /// `package.nls.json` or `package.nls.<tag>.json`.
  String packageNlsFileName({String baseName = 'package'}) {
    if (isDefault) return '$baseName.nls.json';
    return '$baseName.nls.$tag.json';
  }

  /// `bundle.l10n.json` or `bundle.l10n.<tag>.json`.
  String bundleL10nFileName({String baseName = 'bundle'}) {
    if (isDefault) return '$baseName.l10n.json';
    return '$baseName.l10n.$tag.json';
  }

  static String _normalize(String raw) {
    final t = raw.trim().toLowerCase().replaceAll('_', '-');
    if (t.isEmpty || t == 'en' || t == 'en-us') return '';
    if (t == 'pseudo') return 'pseudo';
    return t;
  }

  @override
  String toString() => isDefault ? 'default' : tag;

  @override
  bool operator ==(Object other) => other is VscLocale && other.tag == tag;

  @override
  int get hashCode => tag.hashCode;
}
