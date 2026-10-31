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

  /// Windows negative dump (unbind OS defaults).
  static const windowsNegative = VscBundledKeybindingSet(
    VscKeyPlatform.windows,
    negative: true,
  );

  /// macOS negative dump.
  static const macosNegative = VscBundledKeybindingSet(
    VscKeyPlatform.macos,
    negative: true,
  );

  /// Linux negative dump.
  static const linuxNegative = VscBundledKeybindingSet(
    VscKeyPlatform.linux,
    negative: true,
  );

  /// All OS default dumps.
  static const all = <VscBundledKeybindingSet>[windows, macos, linux];

  /// All OS negative dumps.
  static const allNegative = <VscBundledKeybindingSet>[
    windowsNegative,
    macosNegative,
    linuxNegative,
  ];

  /// Dump for [platform].
  static VscBundledKeybindingSet forPlatform(
    VscKeyPlatform platform, {
    bool negative = false,
  }) {
    switch (platform) {
      case VscKeyPlatform.windows:
        return negative ? windowsNegative : windows;
      case VscKeyPlatform.macos:
        return negative ? macosNegative : macos;
      case VscKeyPlatform.linux:
        return negative ? linuxNegative : linux;
    }
  }
}

/// One bundled OS keybinding dump.
class VscBundledKeybindingSet {
  /// Creates a reference to a bundled dump.
  const VscBundledKeybindingSet(
    this.platform, {
    this.negative = false,
  });

  /// OS of this dump.
  final VscKeyPlatform platform;

  /// Whether this is a `*.negative.keybindings.json` unbind dump.
  final bool negative;

  /// File name (`windows.keybindings.json`).
  String get fileName =>
      negative ? platform.negativeFileName : platform.fileName;

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
