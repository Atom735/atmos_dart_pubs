import 'dart:typed_data';

import 'package:atmos_jsonc/atmos_jsonc.dart';

import 'bundle.dart';
import 'locale.dart';

/// Parses VS Code `package.nls` / `bundle.l10n` JSONC tables (no `dart:io`).
///
/// ## ENG
/// File helpers live in `package:atmos_vsc_l10n/atmos_vsc_l10n_io.dart`.
///
/// ## RU
/// Файловые хелперы — в `atmos_vsc_l10n_io.dart`.
abstract final class VscNlsLoader {
  /// Parses a flat string map (ignores non-string values unless `{message}`).
  static VscNlsTable parseTable(
    String source, {
    VscLocale locale = VscLocale.defaultLocale,
  }) =>
      parseTableDecoded(jsoncDecode(source), locale: locale);

  /// Parses UTF-8 table bytes.
  static VscNlsTable parseTableUtf8(
    List<int> bytes, {
    VscLocale locale = VscLocale.defaultLocale,
  }) =>
      parseTableDecoded(
        jsoncDecodeUtf8(bytes is Uint8List ? bytes : Uint8List.fromList(bytes)),
        locale: locale,
      );

  /// Parses an already-decoded JSON object.
  static VscNlsTable parseTableDecoded(
    Object? decoded, {
    VscLocale locale = VscLocale.defaultLocale,
  }) {
    if (decoded is! Map) {
      throw const FormatException('nls / l10n root must be a JSON object');
    }
    final messages = <String, String>{};
    for (final entry in decoded.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      if (value is String) {
        messages[key] = value;
      } else if (value is Map) {
        // bundle.l10n: { "message": "...", "comment": [...] }
        final message = value['message'];
        if (message is String) {
          messages[key] = message;
        }
      }
    }
    return VscNlsTable(
      Map<String, String>.unmodifiable(messages),
      locale: locale,
    );
  }
}
