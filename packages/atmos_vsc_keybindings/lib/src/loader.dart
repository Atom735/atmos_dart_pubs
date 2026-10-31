import 'dart:io';
import 'dart:typed_data';

import 'package:atmos_jsonc/atmos_jsonc.dart';

import 'bundled.dart';
import 'keybinding.dart';
import 'platform.dart';

/// Loads bundled / file keybinding dumps (JSONC).
///
/// ## ENG
/// Parses `keybindings.json` arrays. For Flutter assets see
/// `atmos_vsc_keybindings_flutter`.
///
/// ## RU
/// Парсит массивы `keybindings.json`. Flutter-ассеты — в
/// `atmos_vsc_keybindings_flutter`.
abstract final class VscKeybindingsLoader {
  /// Parses a keybindings JSONC string.
  static List<VscKeybinding> parse(String source) =>
      parseDecoded(jsoncDecode(source));

  /// Parses UTF-8 `keybindings.json` bytes.
  static List<VscKeybinding> parseUtf8(List<int> bytes) => parseDecoded(
        jsoncDecodeUtf8(bytes is Uint8List ? bytes : Uint8List.fromList(bytes)),
      );

  /// Parses an already-decoded JSON array.
  static List<VscKeybinding> parseDecoded(Object? decoded) {
    if (decoded is! List) {
      throw const FormatException(
        'keybindings.json root must be a JSON array',
      );
    }
    final out = <VscKeybinding>[];
    for (final item in decoded) {
      if (item is Map) {
        out.add(VscKeybinding.fromJson(item.cast<String, Object?>()));
      }
    }
    return List<VscKeybinding>.unmodifiable(out);
  }

  /// Loads from a [File].
  static List<VscKeybinding> loadFile(File file) =>
      parse(file.readAsStringSync());

  /// Loads from a filesystem [path].
  static List<VscKeybinding> loadPath(String path) => loadFile(File(path));

  /// Loads a bundled dump from a package checkout
  /// (`packages/atmos_vsc_keybindings/lib/assets/...`).
  ///
  /// [packageRoot] is the package directory (contains `lib/`).
  static List<VscKeybinding> loadBundled(
    VscBundledKeybindingSet set, {
    required String packageRoot,
  }) {
    final path = '$packageRoot/${set.packagePath}'.replaceAll(r'\', '/');
    return loadPath(path);
  }

  /// Loads bundled defaults for [platform].
  static List<VscKeybinding> loadBundledPlatform(
    VscKeyPlatform platform, {
    required String packageRoot,
  }) =>
      loadBundled(
        VscBundledKeybindings.forPlatform(platform),
        packageRoot: packageRoot,
      );
}
