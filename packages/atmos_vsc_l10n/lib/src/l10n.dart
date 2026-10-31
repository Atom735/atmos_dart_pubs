import 'bundle.dart';
import 'format.dart';
import 'locale.dart';
import 'message.dart';

/// Listener notified when [VscL10n.locale] or [VscL10n.bundle] changes.
typedef VscL10nListener = void Function();

/// Runtime localization similar to `vscode.l10n.t`.
///
/// ## ENG
/// Looks up `message` / `message/comments` in the bound bundle, formats
/// `{0}` and `{name}` placeholders, optional pseudo-locale. Call
/// [addListener] to rebuild UI when [locale] changes.
///
/// ## RU
/// Lookup с учётом comment-ключа, `{0}`/`{name}`, pseudo-локаль.
class VscL10n {
  /// Creates an l10n helper bound to [bundle] and [locale].
  VscL10n({
    required VscNlsBundle bundle,
    VscLocale locale = VscLocale.defaultLocale,
  })  : _bundle = bundle,
        _locale = locale;

  VscNlsBundle _bundle;
  VscLocale _locale;
  final List<VscL10nListener> _listeners = <VscL10nListener>[];

  /// Keys that were requested but missing from the active locale chain
  /// (falls back to English / message still returned).
  final List<String> missingLookups = <String>[];

  /// Whether to record [missingLookups].
  bool trackMissing = false;

  /// Message tables (usually `bundle.l10n*.json`).
  VscNlsBundle get bundle => _bundle;

  set bundle(VscNlsBundle value) {
    if (identical(_bundle, value)) return;
    _bundle = value;
    _notify();
  }

  /// Active UI locale.
  VscLocale get locale => _locale;

  set locale(VscLocale value) {
    if (_locale == value) return;
    _locale = value;
    _notify();
  }

  /// Registers a change listener (locale / bundle).
  void addListener(VscL10nListener listener) => _listeners.add(listener);

  /// Removes a previously registered listener.
  void removeListener(VscL10nListener listener) => _listeners.remove(listener);

  void _notify() {
    for (final listener in List<VscL10nListener>.of(_listeners)) {
      listener();
    }
  }

  /// Translates [message] (positional + optional named args + comments).
  String t(
    String message, {
    List<Object?> args = const [],
    Map<String, Object?> namedArgs = const {},
    List<String>? comment,
    String? key,
  }) {
    final lookupKey = key ?? vscL10nBundleKey(message, comment);
    var template = _bundle.lookup(lookupKey, locale: _locale);
    if (template == null) {
      if (trackMissing) missingLookups.add(lookupKey);
      template = message;
    }
    if (_locale.isPseudo) {
      template = vscPseudoLocalize(template);
    }
    return vscFormatMessage(
      template,
      indexed: args,
      named: namedArgs,
    );
  }

  /// Positional-args shorthand: `tArgs('Hello {0}', ['Ada'])`.
  String tArgs(String message, List<Object?> args, {List<String>? comment}) =>
      t(message, args: args, comment: comment);

  /// Named-args shorthand: `tNamed('Hello {name}', {'name': 'Ada'})`.
  String tNamed(
    String message,
    Map<String, Object?> namedArgs, {
    List<String>? comment,
  }) =>
      t(message, namedArgs: namedArgs, comment: comment);

  /// Options-object form (parity with `vscode.l10n.t({ message, … })`).
  String tMessage(VscL10nMessage info) => t(
        info.message,
        args: info.args ?? const [],
        namedArgs: info.namedArgs ?? const {},
        comment: info.comment,
      );
}
