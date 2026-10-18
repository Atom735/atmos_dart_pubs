import 'parser.dart';
import 'path.dart';

/// Parses [source] with a path [reviver] (direct tree path, no visitor).
///
/// ## ENG
/// Prefer `jsoncDecode(source, reviver: …)`. Kept as an explicit entry point.
///
/// ## RU
/// Предпочтительнее `jsoncDecode(source, reviver: …)`. Явная точка входа.
Object? jsoncDecodeWithReviver(String source, JsoncReviver reviver) =>
    JsoncParser(source, reviver: reviver).parse();
