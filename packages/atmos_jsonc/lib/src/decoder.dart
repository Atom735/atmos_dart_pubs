import 'dart:convert';

import 'parser.dart';
import 'path.dart';

/// Decodes a JSONC [String] in one pass into a Dart value.
///
/// ## ENG
/// Optional [reviver] runs bottom-up with a full [JsoncPath] on the same
/// fast tree path (no visitor rebuild).
///
/// ## RU
/// Опциональный [reviver] — bottom-up с полным [JsoncPath] на том же
/// быстром tree-пути (без пересборки через visitor).
Object? jsoncDecode(String source, {JsoncReviver? reviver}) =>
    JsoncParser(source, reviver: reviver).parse();

/// Streaming JSONC decoder (`Converter` / chunked sink).
///
/// ## ENG
/// Chunks are concatenated; the document is parsed when the sink is closed
/// (or immediately via [convert]). Compatible with
/// `utf8.decoder.fuse(jsonc.decoder)`.
///
/// ## RU
/// Чанки склеиваются; документ парсится при закрытии sink
/// (или сразу через [convert]). Совместим с
/// `utf8.decoder.fuse(jsonc.decoder)`.
class JsoncDecoder extends Converter<String, Object?> {
  /// Creates a JSONC decoder.
  const JsoncDecoder({this.reviver});

  /// Optional path-aware reviver.
  final JsoncReviver? reviver;

  @override
  Object? convert(String input) => jsoncDecode(input, reviver: reviver);

  @override
  Sink<String> startChunkedConversion(Sink<Object?> sink) {
    return ChunkedConversionSink<String>.withCallback((chunks) {
      final text = chunks.length == 1 ? chunks.first : chunks.join();
      sink.add(jsoncDecode(text, reviver: reviver));
      sink.close();
    });
  }
}

/// JSONC codec (decode only — encode is plain [JsonEncoder]).
///
/// ## ENG
/// Use [decoder] for JSONC; [encoder] writes standard JSON (no comments).
///
/// ## RU
/// [decoder] — JSONC; [encoder] пишет обычный JSON без комментариев.
class JsoncCodec extends Codec<Object?, String> {
  /// Creates a JSONC codec.
  const JsoncCodec({this.reviver});

  /// Optional path-aware reviver for [decoder].
  final JsoncReviver? reviver;

  @override
  Converter<String, Object?> get decoder => JsoncDecoder(reviver: reviver);

  @override
  Converter<Object?, String> get encoder => const JsonEncoder();
}

/// Default JSONC codec instance (no reviver).
const JsoncCodec jsonc = JsoncCodec();
