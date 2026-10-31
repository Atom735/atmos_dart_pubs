import 'dart:io';
import 'dart:typed_data';

import 'package:atmos_jsonc/atmos_jsonc.dart';
import 'package:atmos_vsc_keybindings/atmos_vsc_keybindings.dart';
import 'package:atmos_vsc_l10n/atmos_vsc_l10n.dart';

import 'contributions.dart';

/// Parses VS Code / Cursor command and keybinding JSON (JSONC).
///
/// ## ENG
/// Use [parseKeybindings] for `keybindings.json` arrays (delegates to
/// [VscKeybindingsLoader]) and [parseContributions] for extension
/// `package.json` / `contributes` maps. Pass [VscNlsBundle] to resolve
/// `%nls.keys%` before parsing.
///
/// ## RU
/// [parseKeybindings] — массивы `keybindings.json`; [parseContributions] —
/// `package.json` / `contributes`. С [VscNlsBundle] резолвятся `%keys%`.
abstract final class VscCommandsLoader {
  /// Parses a `keybindings.json` array (JSONC allowed).
  static List<VscKeybinding> parseKeybindings(String source) =>
      VscKeybindingsLoader.parse(source);

  /// Parses UTF-8 `keybindings.json` bytes.
  static List<VscKeybinding> parseKeybindingsUtf8(List<int> bytes) =>
      VscKeybindingsLoader.parseUtf8(bytes);

  /// Loads keybindings from a file.
  static List<VscKeybinding> loadKeybindingsFile(File file) =>
      VscKeybindingsLoader.loadFile(file);

  /// Loads keybindings from [path].
  static List<VscKeybinding> loadKeybindingsPath(String path) =>
      VscKeybindingsLoader.loadPath(path);

  /// Parses command + keybinding contributions from JSONC.
  ///
  /// When [nls] is set, `%keys%` are resolved via [VscNls.resolveJson].
  static VscCommandContributions parseContributions(
    String source, {
    VscNlsBundle? nls,
    VscLocale locale = VscLocale.defaultLocale,
  }) =>
      _parseContributionsDecoded(
        jsoncDecode(source),
        nls: nls,
        locale: locale,
      );

  /// Parses contributions from UTF-8 JSONC bytes.
  static VscCommandContributions parseContributionsUtf8(
    List<int> bytes, {
    VscNlsBundle? nls,
    VscLocale locale = VscLocale.defaultLocale,
  }) =>
      _parseContributionsDecoded(
        jsoncDecodeUtf8(bytes is Uint8List ? bytes : Uint8List.fromList(bytes)),
        nls: nls,
        locale: locale,
      );

  /// Loads contributions from a `package.json` (or contributes-only) file.
  static VscCommandContributions loadContributionsFile(
    File file, {
    VscNlsBundle? nls,
    VscLocale locale = VscLocale.defaultLocale,
  }) =>
      parseContributions(
        file.readAsStringSync(),
        nls: nls,
        locale: locale,
      );

  /// Loads contributions from [path].
  static VscCommandContributions loadContributionsPath(
    String path, {
    VscNlsBundle? nls,
    VscLocale locale = VscLocale.defaultLocale,
  }) =>
      loadContributionsFile(File(path), nls: nls, locale: locale);

  static VscCommandContributions _parseContributionsDecoded(
    Object? decoded, {
    VscNlsBundle? nls,
    VscLocale locale = VscLocale.defaultLocale,
  }) {
    var root = decoded;
    if (nls != null) {
      root = VscNls.resolveJson(decoded, bundle: nls, locale: locale);
    }
    if (root is! Map) {
      throw const FormatException(
        'contributions root must be a JSON object',
      );
    }
    return VscCommandContributions.fromJson(root.cast<String, Object?>());
  }
}
