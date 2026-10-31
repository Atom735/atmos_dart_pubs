/// Paths to color themes shipped under `lib/themes/`.
///
/// ## ENG
/// Files live in this package as `lib/themes/...`. For Flutter
/// `AssetBundle` loading, use `assetPath` (`packages/atmos_vsc_theme/...`)
/// and declare the same paths under `flutter: assets:` in the app/package.
/// For filesystem loading (`VscThemeIo.loadColorThemePath` from
/// `package:atmos_vsc_theme/atmos_vsc_theme_io.dart`), resolve against your
/// checkout (e.g. `packages/atmos_vsc_theme/lib/themes/...`).
///
/// ## RU
/// Файлы лежат в `lib/themes/...`. Для Flutter `AssetBundle` — пути
/// `assetPath`; для файловой загрузки — путь к `lib/themes/...` в checkout.
abstract final class VscBundledThemes {
  /// Flutter / AssetBundle prefix for files under `lib/themes/`.
  static const assetRoot = 'packages/atmos_vsc_theme/themes';

  /// Package-relative directory of theme JSON (under `lib/`).
  static const packageLibRoot = 'lib/themes';

  // --- VS Code theme-defaults ---

  /// Dark Modern (include chain: dark_modern → dark_plus → dark_vs).
  static const darkModern = VscBundledTheme('defaults/dark_modern.json');

  /// Dark+ (includes dark_vs).
  static const darkPlus = VscBundledTheme('defaults/dark_plus.json');

  /// Visual Studio Dark.
  static const darkVs = VscBundledTheme('defaults/dark_vs.json');

  /// Light Modern (include chain: light_modern → light_plus → light_vs).
  static const lightModern = VscBundledTheme('defaults/light_modern.json');

  /// Light+.
  static const lightPlus = VscBundledTheme('defaults/light_plus.json');

  /// Visual Studio Light.
  static const lightVs = VscBundledTheme('defaults/light_vs.json');

  /// High Contrast Dark.
  static const hcBlack = VscBundledTheme('defaults/hc_black.json');

  /// High Contrast Light.
  static const hcLight = VscBundledTheme('defaults/hc_light.json');

  /// VS Code 2026 Dark (includes dark_modern).
  static const dark2026 = VscBundledTheme('defaults/2026-dark.json');

  /// VS Code 2026 Light (includes light_modern).
  static const light2026 = VscBundledTheme('defaults/2026-light.json');

  // --- Cursor ---

  /// Cursor Dark.
  static const cursorDark = VscBundledTheme('cursor/cursor-dark-color-theme.json');

  /// Cursor Dark High Contrast.
  static const cursorDarkHc =
      VscBundledTheme('cursor/cursor-dark-hc-color-theme.json');

  /// Cursor Dark Midnight.
  static const cursorDarkMidnight =
      VscBundledTheme('cursor/cursor-dark-midnight-color-theme.json');

  /// Cursor Light.
  static const cursorLight =
      VscBundledTheme('cursor/cursor-light-color-theme.json');

  /// Cursor Light Colorblind.
  static const cursorLightColorblind =
      VscBundledTheme('cursor/cursor-light-colorblind-color-theme.json');

  // --- Other built-ins (from VS Code / Cursor extensions) ---

  /// Abyss.
  static const abyss = VscBundledTheme('abyss/abyss-color-theme.json');

  /// Kimbie Dark.
  static const kimbieDark =
      VscBundledTheme('kimbie-dark/kimbie-dark-color-theme.json');

  /// Monokai.
  static const monokai = VscBundledTheme('monokai/monokai-color-theme.json');

  /// Monokai Dimmed.
  static const monokaiDimmed =
      VscBundledTheme('monokai-dimmed/dimmed-monokai-color-theme.json');

  /// Quiet Light.
  static const quietLight =
      VscBundledTheme('quietlight/quietlight-color-theme.json');

  /// Red.
  static const red = VscBundledTheme('red/Red-color-theme.json');

  /// Solarized Dark.
  static const solarizedDark =
      VscBundledTheme('solarized-dark/solarized-dark-color-theme.json');

  /// Solarized Light.
  static const solarizedLight =
      VscBundledTheme('solarized-light/solarized-light-color-theme.json');

  /// Tomorrow Night Blue.
  static const tomorrowNightBlue = VscBundledTheme(
    'tomorrow-night-blue/tomorrow-night-blue-color-theme.json',
  );

  /// All known bundled themes (stable order).
  static const all = <VscBundledTheme>[
    darkModern,
    darkPlus,
    darkVs,
    lightModern,
    lightPlus,
    lightVs,
    hcBlack,
    hcLight,
    dark2026,
    light2026,
    cursorDark,
    cursorDarkHc,
    cursorDarkMidnight,
    cursorLight,
    cursorLightColorblind,
    abyss,
    kimbieDark,
    monokai,
    monokaiDimmed,
    quietLight,
    red,
    solarizedDark,
    solarizedLight,
    tomorrowNightBlue,
  ];
}

/// One bundled theme JSON under `lib/themes/`.
class VscBundledTheme {
  /// Creates a reference to [relativePath] under `lib/themes/`.
  const VscBundledTheme(this.relativePath);

  /// Path relative to `lib/themes/` (POSIX separators).
  final String relativePath;

  /// Flutter asset key (`packages/atmos_vsc_theme/themes/...`).
  String get assetPath => '${VscBundledThemes.assetRoot}/$relativePath';

  /// Path under the package root via `lib/themes/...`.
  String get packageLibPath =>
      '${VscBundledThemes.packageLibRoot}/$relativePath';
}
