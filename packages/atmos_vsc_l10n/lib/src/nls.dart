import 'bundle.dart';
import 'format.dart';
import 'locale.dart';
import 'localized_string.dart';

final _nlsKey = RegExp(r'^%([^%]+)%$');

/// Result of [VscNls.resolveJson] with diagnostics.
class VscNlsResolveResult {
  /// Creates a resolve result.
  const VscNlsResolveResult({
    required this.json,
    this.unresolvedKeys = const [],
  });

  /// Resolved JSON tree.
  final Object? json;

  /// `%keys%` that had no entry in the bundle (left as key text / still
  /// substituted with the key id as last resort).
  final List<String> unresolvedKeys;
}

/// Helpers for `package.nls` keys (`%command.title%`).
abstract final class VscNls {
  /// Whether [raw] is a `%key%` placeholder.
  static bool isKey(String raw) => _nlsKey.hasMatch(raw.trim());

  /// Extracts the inner key from `%key%`, or `null` if not a key.
  static String? unwrapKey(String raw) {
    final match = _nlsKey.firstMatch(raw.trim());
    return match?.group(1);
  }

  /// Wraps [key] as `%key%`.
  static String wrapKey(String key) => '%$key%';

  /// Resolves a contribution string field against [bundle].
  ///
  /// - `%key%` → translated [VscLocalizedString] (`value` + `original`)
  /// - plain string → unchanged
  /// - `{ value, original }` → parsed as-is
  static VscLocalizedString resolveString(
    Object? json, {
    required VscNlsBundle bundle,
    VscLocale locale = VscLocale.defaultLocale,
    List<String>? unresolvedOut,
  }) {
    if (json is String) {
      final key = unwrapKey(json);
      if (key == null) {
        return VscLocalizedString(json);
      }
      final original = bundle.lookup(key) ?? key;
      final found = bundle.lookup(key, locale: locale);
      if (found == null) {
        unresolvedOut?.add(key);
      }
      var value = found ?? original;
      if (locale.isPseudo) {
        value = vscPseudoLocalize(value);
      }
      if (locale.isDefault || locale.isPseudo || value == original) {
        return VscLocalizedString(value);
      }
      return VscLocalizedString(value, original: original);
    }
    return VscLocalizedString.fromJson(json);
  }

  /// Deep-walks JSON and replaces `%key%` strings.
  ///
  /// When [split] is true, locale hits become `{value, original}`.
  static Object? resolveJson(
    Object? json, {
    required VscNlsBundle bundle,
    VscLocale locale = VscLocale.defaultLocale,
    bool split = true,
    List<String>? unresolvedOut,
  }) {
    return resolveJsonDetailed(
      json,
      bundle: bundle,
      locale: locale,
      split: split,
      unresolvedOut: unresolvedOut,
    ).json;
  }

  /// Like [resolveJson], but also returns [VscNlsResolveResult.unresolvedKeys].
  static VscNlsResolveResult resolveJsonDetailed(
    Object? json, {
    required VscNlsBundle bundle,
    VscLocale locale = VscLocale.defaultLocale,
    bool split = true,
    List<String>? unresolvedOut,
  }) {
    final unresolved = unresolvedOut ?? <String>[];
    final resolved = _resolveJson(
      json,
      bundle: bundle,
      locale: locale,
      split: split,
      unresolvedOut: unresolved,
    );
    return VscNlsResolveResult(
      json: resolved,
      unresolvedKeys: List<String>.unmodifiable(unresolved),
    );
  }

  static Object? _resolveJson(
    Object? json, {
    required VscNlsBundle bundle,
    required VscLocale locale,
    required bool split,
    required List<String> unresolvedOut,
  }) {
    if (json is String) {
      final key = unwrapKey(json);
      if (key == null) return json;
      final localized = resolveString(
        json,
        bundle: bundle,
        locale: locale,
        unresolvedOut: unresolvedOut,
      );
      if (!split || localized.original == null) {
        return localized.text;
      }
      return localized.toJson();
    }
    if (json is List) {
      return json
          .map(
            (e) => _resolveJson(
              e,
              bundle: bundle,
              locale: locale,
              split: split,
              unresolvedOut: unresolvedOut,
            ),
          )
          .toList(growable: false);
    }
    if (json is Map) {
      return <String, Object?>{
        for (final e in json.entries)
          e.key.toString(): _resolveJson(
            e.value,
            bundle: bundle,
            locale: locale,
            split: split,
            unresolvedOut: unresolvedOut,
          ),
      };
    }
    return json;
  }
}
