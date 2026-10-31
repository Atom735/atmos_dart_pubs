final _placeholder = RegExp(r'\{([^{}]+)\}');

/// Formats a VS Code-style message with `{0}` / `{name}` placeholders.
///
/// ## ENG
/// [indexed] fills `{0}`, `{1}`, … [named] fills `{name}`. Named wins when
/// both could match the same token (token is non-numeric → named only).
///
/// ## RU
/// [indexed] — `{0}`; [named] — `{name}`.
String vscFormatMessage(
  String template, {
  List<Object?> indexed = const [],
  Map<String, Object?> named = const {},
}) {
  if (indexed.isEmpty && named.isEmpty) return template;
  return template.replaceAllMapped(_placeholder, (match) {
    final token = match.group(1)!;
    final asIndex = int.tryParse(token);
    if (asIndex != null) {
      if (asIndex < 0 || asIndex >= indexed.length) return match.group(0)!;
      return indexed[asIndex]?.toString() ?? '';
    }
    if (named.containsKey(token)) {
      return named[token]?.toString() ?? '';
    }
    return match.group(0)!;
  });
}

/// Builds the VS Code `bundle.l10n` lookup key for [message] + [comment].
///
/// Comments are concatenated with **no** separator:
/// `Hello {0}` + `["c1","c2"]` → `Hello {0}/c1c2`.
String vscL10nBundleKey(String message, [List<String>? comment]) {
  if (comment == null || comment.isEmpty) return message;
  return '$message/${comment.join()}';
}

/// Pseudo-localization (VS Code `--locale=pseudo`):
/// wrap in `[]`, double vowels.
String vscPseudoLocalize(String input) {
  final buf = StringBuffer('[');
  for (final rune in input.runes) {
    final ch = String.fromCharCode(rune);
    buf.write(ch);
    if (_isVowel(ch)) buf.write(ch);
  }
  buf.write(']');
  return buf.toString();
}

bool _isVowel(String ch) {
  const vowels = 'aeiouAEIOUаеёиоуыэюяАЕЁИОУЫЭЮЯ';
  return vowels.contains(ch);
}
