import 'key_parse.dart';
import 'key_stroke.dart';
import 'keybinding.dart';
import 'platform.dart';
import 'when.dart';

/// Result of resolving a key press to a command.
class VscKeyMatch {
  /// Creates a match.
  const VscKeyMatch({
    required this.commandId,
    required this.binding,
    this.args,
  });

  /// Command to run.
  final String commandId;

  /// Source rule.
  final VscKeybinding binding;

  /// Optional args from the binding.
  final Object? args;
}

/// Pure-Dart VS Code-style hotkey resolver (chords + when + layers).
///
/// ## ENG
/// Feed [handleKey] with [VscKeyEvent]s. Multi-step chords keep state until
/// [chordTimeout] or [cancelChord]. Later bindings in [bindings] win over
/// earlier ones (pass defaults first, user overrides last).
///
/// ## RU
/// Передавайте события в [handleKey]. Аккорды держат состояние до таймаута
/// или [cancelChord]. Более поздние правила в [bindings] сильнее (сначала
/// defaults, потом user).
class VscKeybindingEngine {
  /// Creates an engine over a resolved [bindings] list.
  VscKeybindingEngine({
    required List<VscKeybinding> bindings,
    this.platform = VscKeyPlatform.windows,
    this.chordTimeout = const Duration(milliseconds: 1000),
    Map<String, Object?>? context,
    DateTime Function()? clock,
  })  : _bindings = List<VscKeybinding>.unmodifiable(bindings),
        context = context ?? <String, Object?>{},
        _clock = clock ?? DateTime.now {
    _rebuildIndex();
  }

  /// Builds an engine from default + optional user rules.
  ///
  /// Removals (`-commandId`) drop matching default rules for the same key.
  factory VscKeybindingEngine.merge({
    required List<VscKeybinding> defaults,
    List<VscKeybinding> user = const [],
    VscKeyPlatform platform = VscKeyPlatform.windows,
    Duration chordTimeout = const Duration(milliseconds: 1000),
    Map<String, Object?>? context,
    DateTime Function()? clock,
  }) {
    return VscKeybindingEngine(
      bindings: mergeBindings(defaults, user, platform: platform),
      platform: platform,
      chordTimeout: chordTimeout,
      context: context,
      clock: clock,
    );
  }

  final List<VscKeybinding> _bindings;
  final DateTime Function() _clock;

  /// Active when-clause context (mutable).
  final Map<String, Object?> context;

  /// OS used for `mac`/`win`/`linux` key overrides on contribution rules.
  final VscKeyPlatform platform;

  /// Max wait between chord steps.
  final Duration chordTimeout;

  /// Indexed rules (last wins): stroke-key → list of candidates.
  late Map<String, List<_IndexedBinding>> _byFirstStroke;

  List<VscKeyStroke>? _chordPrefix;
  DateTime? _chordStartedAt;

  /// Resolved rules in engine order (defaults…user).
  List<VscKeybinding> get bindings => _bindings;

  /// Whether a multi-step chord is awaiting the next key.
  bool get inChord => _chordPrefix != null;

  /// Current chord prefix strokes, or `null`.
  List<VscKeyStroke>? get chordPrefix =>
      _chordPrefix == null ? null : List.unmodifiable(_chordPrefix!);

  /// Clears chord state.
  void cancelChord() {
    _chordPrefix = null;
    _chordStartedAt = null;
  }

  /// Merges [defaults] with [user] (removals applied).
  static List<VscKeybinding> mergeBindings(
    List<VscKeybinding> defaults,
    List<VscKeybinding> user, {
    VscKeyPlatform platform = VscKeyPlatform.windows,
  }) {
    final out = List<VscKeybinding>.from(defaults);
    for (final rule in user) {
      if (rule.isRemoval) {
        final key = rule.keyForPlatform(platform.id);
        out.removeWhere(
          (b) =>
              !b.isRemoval &&
              b.commandId == rule.commandId &&
              b.keyForPlatform(platform.id) == key,
        );
        continue;
      }
      if (rule.command.isEmpty) {
        final key = rule.keyForPlatform(platform.id);
        out.removeWhere((b) => b.keyForPlatform(platform.id) == key);
        continue;
      }
      out.add(rule);
    }
    return List<VscKeybinding>.unmodifiable(out);
  }

  /// Handles one key press; returns a command match or `null`.
  VscKeyMatch? handleKey(VscKeyEvent event) {
    _expireChordIfNeeded();

    if (_chordPrefix != null) {
      final next = [..._chordPrefix!, event];
      final match = _lookup(next);
      if (match != null) {
        cancelChord();
        return match;
      }
      // Wrong second key: cancel chord and try as fresh start.
      cancelChord();
    }

    final single = _lookup([event]);
    if (single != null) return single;

    // Start chord if any binding begins with this stroke.
    final key = event.toKeyString();
    final candidates = _byFirstStroke[key];
    if (candidates != null &&
        candidates.any((c) => c.strokes.length > 1 && _whenOk(c.binding))) {
      _chordPrefix = [event];
      _chordStartedAt = _clock();
    }
    return null;
  }

  void _expireChordIfNeeded() {
    if (_chordPrefix == null || _chordStartedAt == null) return;
    if (_clock().difference(_chordStartedAt!) > chordTimeout) {
      cancelChord();
    }
  }

  VscKeyMatch? _lookup(List<VscKeyStroke> strokes) {
    final key = strokes.first.toKeyString();
    final candidates = _byFirstStroke[key];
    if (candidates == null) return null;

    // Later rules win: scan from end.
    for (var i = candidates.length - 1; i >= 0; i--) {
      final c = candidates[i];
      if (c.strokes.length != strokes.length) continue;
      if (!_strokesEqual(c.strokes, strokes)) continue;
      if (!_whenOk(c.binding)) continue;
      return VscKeyMatch(
        commandId: c.binding.commandId,
        binding: c.binding,
        args: c.binding.args,
      );
    }
    return null;
  }

  bool _whenOk(VscKeybinding binding) =>
      VscWhenEvaluator.evaluate(binding.when, context);

  void _rebuildIndex() {
    final map = <String, List<_IndexedBinding>>{};
    for (final binding in _bindings) {
      if (binding.isRemoval || binding.command.isEmpty) continue;
      final keyStr = binding.keyForPlatform(platform.id);
      List<VscKeyStroke> strokes;
      try {
        strokes = VscKeyStrokeParser.parse(keyStr);
      } on FormatException {
        continue;
      }
      final first = strokes.first.toKeyString();
      map.putIfAbsent(first, () => <_IndexedBinding>[]).add(
            _IndexedBinding(binding: binding, strokes: strokes),
          );
    }
    _byFirstStroke = map;
  }

  static bool _strokesEqual(List<VscKeyStroke> a, List<VscKeyStroke> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class _IndexedBinding {
  _IndexedBinding({required this.binding, required this.strokes});

  final VscKeybinding binding;
  final List<VscKeyStroke> strokes;
}
