import 'package:atmos_vsc_keybindings/atmos_vsc_keybindings.dart';
import 'package:flutter/services.dart';

/// Loads bundled default keybindings from a Flutter [AssetBundle].
///
/// ## ENG
/// Assets are declared in this package's `pubspec.yaml` under
/// `packages/atmos_vsc_keybindings/assets/...`.
///
/// ## RU
/// Ассеты объявлены в `pubspec.yaml` этого пакета.
abstract final class VscKeybindingsAssetLoader {
  /// Loads [set] via [bundle] (defaults to [rootBundle]).
  static Future<List<VscKeybinding>> load(
    VscBundledKeybindingSet set, {
    AssetBundle? bundle,
  }) {
    return loadAssetPath(set.assetPath, bundle: bundle);
  }

  /// Loads defaults for [platform].
  static Future<List<VscKeybinding>> loadPlatform(
    VscKeyPlatform platform, {
    AssetBundle? bundle,
  }) {
    return load(
      VscBundledKeybindings.forPlatform(platform),
      bundle: bundle,
    );
  }

  /// Loads an asset path such as
  /// `packages/atmos_vsc_keybindings/assets/vs-code-default-keybindings/windows.keybindings.json`.
  static Future<List<VscKeybinding>> loadAssetPath(
    String assetPath, {
    AssetBundle? bundle,
  }) async {
    final source = await (bundle ?? rootBundle).loadString(assetPath);
    return VscKeybindingsLoader.parse(source);
  }
}
