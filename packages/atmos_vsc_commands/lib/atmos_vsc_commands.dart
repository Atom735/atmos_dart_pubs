/// Command hub + VS Code / Cursor contribution parsing.
///
/// ## ENG
/// Pure Dart — no Flutter. `VscCommandService` is the runtime entry for
/// user actions; keybinding resolve lives in `atmos_vsc_keybindings`
/// (re-exported). Wire Host → engine match →
/// `VscCommandService.executeMatch`. Localized strings come from
/// `atmos_vsc_l10n`.
///
/// ## RU
/// Чистый Dart без Flutter. `VscCommandService` — runtime-хаб действий;
/// хоткеи — в `atmos_vsc_keybindings` (реэкспорт). Host → match →
/// `VscCommandService.executeMatch`. Локализация — `atmos_vsc_l10n`.
library atmos_vsc_commands;

export 'package:atmos_jsonc/atmos_jsonc.dart' show jsoncDecode, stripJsonc;
export 'package:atmos_vsc_keybindings/atmos_vsc_keybindings.dart'
    show
        VscBundledKeybindingSet,
        VscBundledKeybindings,
        VscKeyMatch,
        VscKeyPlatform,
        VscKeyStroke,
        VscKeyStrokeParser,
        VscKeybinding,
        VscKeybindingEngine,
        VscKeybindingsLoader,
        VscSkippedBinding,
        VscWhenEvaluator;
export 'package:atmos_vsc_l10n/atmos_vsc_l10n.dart'
    show
        VscL10n,
        VscLocale,
        VscLocalizedString,
        VscNls,
        VscNlsBundle,
        VscNlsLoader,
        VscNlsTable;

export 'src/command.dart';
export 'src/contributions.dart';
export 'src/loader.dart';
export 'src/service.dart';
