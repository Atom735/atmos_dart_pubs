import 'platform.dart';

/// Paths to default keybinding dumps shipped under `lib/assets/`.
///
/// ## ENG
/// JSON comes from the git submodule
/// `lib/assets/vs-code-default-keybindings`
/// ([codebling/vs-code-default-keybindings](https://github.com/codebling/vs-code-default-keybindings)).
/// For Flutter AssetBundle loading use [VscBundledKeybindingSet.assetPath]
/// and declare paths under `flutter: assets:`
/// (see `atmos_vsc_keybindings_flutter`).
///
/// ## RU
/// JSON из git-субмодуля `lib/assets/vs-code-default-keybindings`.
/// Для Flutter — [VscBundledKeybindingSet.assetPath].
abstract final class VscBundledKeybindings {
  /// Submodule directory name under `lib/assets/`.
  static const dumpDir = 'vs-code-default-keybindings';

  /// Flutter / AssetBundle prefix for dump files.
  static const assetRoot =
      'packages/atmos_vsc_keybindings/assets/$dumpDir';

  /// Package-relative directory of the dump (under `lib/`).
  static const packageLibRoot = 'lib/assets/$dumpDir';

  /// VS Code version stamped in the dump headers (bump when submodule updates).
  static const vscodeVersion = '1.144.0';

  /// Windows defaults.
  static const windows = VscBundledKeybindingSet(VscKeyPlatform.windows);

  /// macOS defaults.
  static const macos = VscBundledKeybindingSet(VscKeyPlatform.macos);

  /// Linux defaults.
  static const linux = VscBundledKeybindingSet(VscKeyPlatform.linux);

  /// All OS dumps.
  static const all = <VscBundledKeybindingSet>[windows, macos, linux];

  /// Dump for [platform].
  static VscBundledKeybindingSet forPlatform(VscKeyPlatform platform) {
    switch (platform) {
      case VscKeyPlatform.windows:
        return windows;
      case VscKeyPlatform.macos:
        return macos;
      case VscKeyPlatform.linux:
        return linux;
    }
  }
}

/// One bundled OS keybinding dump.
class VscBundledKeybindingSet {
  /// Creates a reference to a bundled dump.
  const VscBundledKeybindingSet(this.platform);

  /// OS of this dump.
  final VscKeyPlatform platform;

  /// File name (`windows.keybindings.json`).
  String get fileName => platform.fileName;

  /// Path relative to `lib/`
  /// (`assets/vs-code-default-keybindings/windows.keybindings.json`).
  String get packageLibPath =>
      'assets/${VscBundledKeybindings.dumpDir}/$fileName';

  /// Flutter asset path
  /// (`packages/atmos_vsc_keybindings/assets/vs-code-default-keybindings/...`).
  String get assetPath => '${VscBundledKeybindings.assetRoot}/$fileName';

  /// Filesystem path relative to package root.
  String get packagePath => 'lib/$packageLibPath';
}
