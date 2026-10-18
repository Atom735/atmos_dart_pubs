/// Streaming JSONC decoder (comments, trailing commas, single-pass parse).
///
/// ## ENG
/// Use `jsoncDecode` / `JsoncDecoder` for [String] trees, or
/// `jsoncDecodeUtf8` / `JsoncUtf8Decoder` for UTF-8 bytes (no full document
/// string). Path `reviver`, `jsoncBind` / `JsoncReader` for typed mapping.
///
/// ## RU
/// `jsoncDecode` / `JsoncDecoder` — дерево из [String];
/// `jsoncDecodeUtf8` / `JsoncUtf8Decoder` — из UTF-8 байтов без полной
/// строки документа. Path-`reviver`, `jsoncBind` / `JsoncReader` — typed.
library atmos_jsonc;

export 'src/decoder.dart';
export 'src/decoder_utf8.dart';
export 'src/parser.dart';
export 'src/parser_utf8.dart';
export 'src/path.dart';
export 'src/reader.dart';
export 'src/reviver_builder.dart' show jsoncDecodeWithReviver;
export 'src/scanner.dart';
export 'src/scanner_utf8.dart';
export 'src/strip.dart';
export 'src/visitor.dart';
