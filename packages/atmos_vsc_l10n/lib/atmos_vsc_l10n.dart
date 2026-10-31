/// VS Code / Cursor style localization (`package.nls`, `%keys%`, `l10n.t`).
///
/// ## ENG
/// Pure Dart (no `dart:io`). File loaders:
/// `import 'package:atmos_vsc_l10n/atmos_vsc_l10n_io.dart';`
///
/// ## RU
/// Чистый Dart без `dart:io`. Файлы — через `atmos_vsc_l10n_io.dart`.
library atmos_vsc_l10n;

export 'src/bundle.dart';
export 'src/format.dart';
export 'src/l10n.dart';
export 'src/loader.dart';
export 'src/locale.dart';
export 'src/localized_string.dart';
export 'src/message.dart';
export 'src/nls.dart';
