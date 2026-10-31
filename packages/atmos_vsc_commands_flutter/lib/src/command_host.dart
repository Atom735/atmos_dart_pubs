import 'dart:async';

import 'package:atmos_vsc_commands/atmos_vsc_commands.dart';
import 'package:atmos_vsc_keybindings_flutter/atmos_vsc_keybindings_flutter.dart';
import 'package:flutter/widgets.dart';

import 'shortcuts.dart';

/// Optional observer after a keybinding match is dispatched.
typedef VscCommandHostListener = void Function(
  VscKeyMatch match,
  Object? result,
);

/// Wires [VscKeybindingsHost] → [VscCommandService.executeMatch].
///
/// ## ENG
/// Canonical keyboard path: engine resolves chords/`when`, then the
/// command service runs the handler. Share [VscCommandService.context]
/// with the engine (see [VscCommandService.createEngine]).
///
/// ## RU
/// Канон: engine → [VscCommandService.executeMatch]. Контекст делить
/// через [VscCommandService.createEngine].
class VscCommandHost extends StatelessWidget {
  /// Creates a command host.
  const VscCommandHost({
    super.key,
    required this.service,
    required this.engine,
    required this.child,
    this.autofocus = true,
    this.skipPrintableWhenTextInput = true,
    this.onDispatched,
    this.onError,
  });

  /// Command runtime hub.
  final VscCommandService service;

  /// Hotkey engine (should share [VscCommandService.context]).
  final VscKeybindingEngine engine;

  /// Subtree.
  final Widget child;

  /// Forwarded to [VscKeybindingsHost.autofocus].
  final bool autofocus;

  /// Forwarded to [VscKeybindingsHost.skipPrintableWhenTextInput].
  final bool skipPrintableWhenTextInput;

  /// Called after a successful executeMatch.
  final VscCommandHostListener? onDispatched;

  /// Called when execute throws (e.g. no handler / disabled).
  final void Function(VscKeyMatch match, Object error, StackTrace stack)?
      onError;

  @override
  Widget build(BuildContext context) {
    return VscKeybindingsHost(
      engine: engine,
      autofocus: autofocus,
      skipPrintableWhenTextInput: skipPrintableWhenTextInput,
      onCommand: _onCommand,
      child: child,
    );
  }

  void _onCommand(VscKeyMatch match) {
    try {
      final result = service.executeMatch(match);
      if (result is Future) {
        unawaited(
          result.then(
            (value) => onDispatched?.call(match, value),
            onError: (Object e, StackTrace st) => onError?.call(match, e, st),
          ),
        );
      } else {
        onDispatched?.call(match, result);
      }
    } on Object catch (e, st) {
      onError?.call(match, e, st);
    }
  }
}

/// [CallbackAction] that runs [VscCommandService.execute] for intents.
class VscCommandAction extends Action<VscCommandIntent> {
  /// Creates an action bound to [service].
  VscCommandAction(this.service, {this.source = 'shortcut'});

  /// Command hub.
  final VscCommandService service;

  /// Passed as invocation source.
  final String source;

  @override
  Object? invoke(VscCommandIntent intent) {
    return service.execute(
      intent.commandId,
      args: intent.args,
      source: source,
    );
  }

  @override
  bool isEnabled(VscCommandIntent intent) =>
      service.canExecute(intent.commandId);
}
