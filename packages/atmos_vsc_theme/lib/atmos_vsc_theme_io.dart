/// Filesystem entrypoint for `atmos_vsc_theme`.
///
/// ## ENG
/// Re-exports the core API and adds `VscThemeIo` (`File` / path / bytes).
/// Requires `dart:io`. Web and other platforms without `dart:io` should
/// import `package:atmos_vsc_theme/atmos_vsc_theme.dart` instead.
///
/// ## RU
/// Повторно экспортирует ядро и добавляет `VscThemeIo`
/// (`File` / путь / байты). Нужен `dart:io`. Web и другие платформы без
/// `dart:io` импортируют `package:atmos_vsc_theme/atmos_vsc_theme.dart`.
library atmos_vsc_theme_io;

export 'atmos_vsc_theme.dart';
export 'src/loader_io.dart';
