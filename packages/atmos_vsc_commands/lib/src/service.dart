import 'dart:async';

import 'package:atmos_vsc_keybindings/atmos_vsc_keybindings.dart';

import 'command.dart';
import 'contributions.dart';

/// Handler for a registered command.
///
/// ## ENG
/// Return value is optional (palette / scripting can use it later).
///
/// ## RU
/// Возвращаемое значение опционально.
typedef VscCommandHandler = FutureOr<Object?> Function(
  VscCommandInvocation invocation,
);

/// One command run request.
class VscCommandInvocation {
  /// Creates an invocation.
  const VscCommandInvocation({
    required this.commandId,
    required this.service,
    this.args,
    this.metadata,
    this.source,
  });

  /// Command id being executed.
  final String commandId;

  /// Owning service (shared [VscCommandService.context]).
  final VscCommandService service;

  /// Optional args from keybinding / caller.
  final Object? args;

  /// Declared contribution metadata, if known.
  final VscCommand? metadata;

  /// Optional source tag (`keybinding`, `palette`, …).
  final String? source;
}

/// Failure while resolving or running a command.
class VscCommandException implements Exception {
  /// Creates an exception.
  const VscCommandException(this.commandId, this.message);

  /// Related command id.
  final String commandId;

  /// Human-readable reason.
  final String message;

  @override
  String toString() => 'VscCommandException($commandId): $message';
}

/// Runtime hub: metadata + handlers + shared when-context.
///
/// ## ENG
/// All user interaction should funnel through [execute] /
/// [executeMatch]. Share [context] with [VscKeybindingEngine] so
/// keybinding `when` and command `enablement` stay in sync.
///
/// ## RU
/// Весь пользовательский ввод — через [execute] / [executeMatch].
/// Делите [context] с [VscKeybindingEngine].
class VscCommandService {
  /// Creates an empty command service.
  VscCommandService({Map<String, Object?>? context})
      : context = context ?? <String, Object?>{};

  final Map<String, VscCommand> _metadata = {};
  final Map<String, VscCommandHandler> _handlers = {};

  /// Shared when / enablement context (mutable).
  final Map<String, Object?> context;

  /// Declared commands (contribution metadata).
  Iterable<VscCommand> get commands => _metadata.values;

  /// Registered handler ids.
  Iterable<String> get handlerIds => _handlers.keys;

  /// Metadata for [commandId], if registered.
  VscCommand? metadata(String commandId) => _metadata[commandId];

  /// Whether a handler is registered for [commandId].
  bool isRegistered(String commandId) => _handlers.containsKey(commandId);

  /// Registers contribution metadata (overwrites same ids).
  void registerMetadata(Iterable<VscCommand> commands) {
    for (final command in commands) {
      _metadata[command.command] = command;
    }
  }

  /// Registers commands (+ optional keybindings ignored here) from
  /// [contrib]. Handlers are optional and keyed by command id.
  void registerContributions(
    VscCommandContributions contrib, {
    Map<String, VscCommandHandler>? handlers,
  }) {
    registerMetadata(contrib.commands);
    handlers?.forEach(register);
  }

  /// Registers [handler] for [commandId]. Optional [metadata] stored too.
  void register(
    String commandId,
    VscCommandHandler handler, {
    VscCommand? metadata,
  }) {
    if (commandId.isEmpty) {
      throw ArgumentError.value(commandId, 'commandId', 'must not be empty');
    }
    _handlers[commandId] = handler;
    if (metadata != null) {
      _metadata[commandId] = metadata;
    }
  }

  /// Removes handler (metadata kept unless [forgetMetadata] is true).
  void unregister(String commandId, {bool forgetMetadata = false}) {
    _handlers.remove(commandId);
    if (forgetMetadata) {
      _metadata.remove(commandId);
    }
  }

  /// Clears handlers and optionally metadata.
  void clear({bool metadata = true}) {
    _handlers.clear();
    if (metadata) {
      _metadata.clear();
    }
  }

  /// Whether [commandId] passes enablement (missing metadata → true).
  bool isEnabled(String commandId) {
    final meta = _metadata[commandId];
    if (meta == null) return true;
    return VscWhenEvaluator.evaluate(meta.enablement, context);
  }

  /// Handler registered and enablement satisfied.
  bool canExecute(String commandId) =>
      isRegistered(commandId) && isEnabled(commandId);

  /// Commands that are enabled (for palette filtering).
  List<VscCommand> enabledCommands() {
    return _metadata.values.where((c) => isEnabled(c.command)).toList();
  }

  /// Runs [commandId] if [canExecute]; otherwise throws [VscCommandException].
  FutureOr<Object?> execute(
    String commandId, {
    Object? args,
    String? source,
  }) {
    final handler = _handlers[commandId];
    if (handler == null) {
      throw VscCommandException(commandId, 'No handler registered');
    }
    if (!isEnabled(commandId)) {
      throw VscCommandException(commandId, 'Command is disabled');
    }
    return handler(
      VscCommandInvocation(
        commandId: commandId,
        service: this,
        args: args,
        metadata: _metadata[commandId],
        source: source,
      ),
    );
  }

  /// Dispatches a keybinding [match] (`source: keybinding`).
  FutureOr<Object?> executeMatch(VscKeyMatch match) => execute(
        match.commandId,
        args: match.args,
        source: 'keybinding',
      );

  /// Builds an engine that shares this [context].
  VscKeybindingEngine createEngine({
    required List<VscKeybinding> defaults,
    List<VscKeybinding> user = const [],
    VscKeyPlatform platform = VscKeyPlatform.windows,
    Duration chordTimeout = const Duration(milliseconds: 1000),
    DateTime Function()? clock,
  }) {
    return VscKeybindingEngine.merge(
      defaults: defaults,
      user: user,
      platform: platform,
      chordTimeout: chordTimeout,
      context: context,
      clock: clock,
    );
  }
}
