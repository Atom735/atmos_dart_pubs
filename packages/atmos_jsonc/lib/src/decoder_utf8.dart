import 'dart:convert';
import 'dart:typed_data';

import 'parser_utf8.dart';
import 'path.dart';

/// Decodes JSONC from UTF-8 bytes in one pass (no full document [String]).
///
/// ## ENG
/// Prefer this over `utf8.decode` + `jsoncDecode` for large ASCII/UTF-8 files.
///
/// ## RU
/// Лучше, чем `utf8.decode` + `jsoncDecode`, для больших ASCII/UTF-8 файлов.
Object? jsoncDecodeUtf8(
  List<int> bytes, {
  JsoncReviver? reviver,
}) {
  final data = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
  return JsoncUtf8Parser(data, reviver: reviver).parse();
}

/// UTF-8 JSONC decoder (`Converter<List<int>, Object?>`).
///
/// ## ENG
/// Use with file/socket streams: `file.openRead().transform(jsoncUtf8.decoder)`.
/// Chunks are concatenated; the document is parsed on sink close.
///
/// ## RU
/// Для потоков: `file.openRead().transform(jsoncUtf8.decoder)`.
/// Чанки склеиваются; документ парсится при закрытии sink.
class JsoncUtf8Decoder extends Converter<List<int>, Object?> {
  /// Creates a UTF-8 JSONC decoder.
  const JsoncUtf8Decoder({this.reviver});

  /// Optional path-aware reviver.
  final JsoncReviver? reviver;

  @override
  Object? convert(List<int> input) => jsoncDecodeUtf8(input, reviver: reviver);

  @override
  ByteConversionSink startChunkedConversion(Sink<Object?> sink) {
    return _JsoncUtf8DecoderSink(sink, reviver);
  }
}

class _JsoncUtf8DecoderSink extends ByteConversionSinkBase {
  _JsoncUtf8DecoderSink(this._sink, this._reviver);

  final Sink<Object?> _sink;
  final JsoncReviver? _reviver;
  final BytesBuilder _buffer = BytesBuilder(copy: false);
  var _closed = false;

  @override
  void add(List<int> chunk) {
    if (_closed) {
      throw StateError('JSONC UTF-8 sink is closed');
    }
    if (chunk.isNotEmpty) {
      _buffer.add(chunk);
    }
  }

  @override
  void close() {
    if (_closed) return;
    _closed = true;
    final bytes = _buffer.takeBytes();
    _sink.add(jsoncDecodeUtf8(bytes, reviver: _reviver));
    _sink.close();
  }
}

/// JSONC codec over UTF-8 bytes (decode only — encode is UTF-8 JSON).
///
/// ## ENG
/// [decoder] is [JsoncUtf8Decoder]; [encoder] writes standard JSON as UTF-8.
///
/// ## RU
/// [decoder] — [JsoncUtf8Decoder]; [encoder] пишет обычный JSON в UTF-8.
class JsoncUtf8Codec extends Codec<Object?, List<int>> {
  /// Creates a UTF-8 JSONC codec.
  const JsoncUtf8Codec({this.reviver});

  /// Optional path-aware reviver for [decoder].
  final JsoncReviver? reviver;

  @override
  Converter<List<int>, Object?> get decoder =>
      JsoncUtf8Decoder(reviver: reviver);

  @override
  Converter<Object?, List<int>> get encoder => JsonUtf8Encoder();
}

/// Default UTF-8 JSONC codec instance (no reviver).
const JsoncUtf8Codec jsoncUtf8 = JsoncUtf8Codec();
