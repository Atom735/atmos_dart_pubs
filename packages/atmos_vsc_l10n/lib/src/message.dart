/// Options object for `VscL10n.tMessage` (parity with `vscode.l10n.t({…})`).
class VscL10nMessage {
  /// Creates a localizable message descriptor.
  const VscL10nMessage({
    required this.message,
    this.args,
    this.namedArgs,
    this.comment,
  });

  /// Source / English message (also default lookup key).
  final String message;

  /// Indexed `{0}` arguments.
  final List<Object?>? args;

  /// Named `{name}` arguments.
  final Map<String, Object?>? namedArgs;

  /// Translator comments (affects bundle lookup key).
  final List<String>? comment;
}
