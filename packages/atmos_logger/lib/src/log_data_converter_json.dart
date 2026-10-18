import 'dart:convert';

import 'package:meta/meta.dart';

import 'log_data.dart';
import 'log_data_converter.dart';

class LogDataJsonCodec extends LogDataCodec<Map> {
  @literal
  const LogDataJsonCodec();
  @override
  LogDataJsonEncoder get encoder => const LogDataJsonEncoder();
  @override
  LogDataJsonDecoder get decoder => const LogDataJsonDecoder();
}

class LogDataJsonEncoder extends LogDataEncoder<Map> {
  @literal
  const LogDataJsonEncoder();

  @override
  Sink<LogData> startChunkedConversion(Sink<Map> sink) =>
      _LogDataJsonEncoderSink(sink, this);

  @override
  Map convert(LogData input) => {
        'time_stamp': input.time.toIso8601String(),
        'level': input.level,
        if (input.name.isNotEmpty) 'type': input.name,
        if (input.title.isNotEmpty) 'title': input.title,
        if (input.body.isNotEmpty) 'body': input.body,
      };
}

class _LogDataJsonEncoderSink extends ChunkedConversionSink<LogData> {
  _LogDataJsonEncoderSink(this.sink, this.encoder);

  final Sink<Map> sink;
  final LogDataJsonEncoder encoder;

  @override
  void add(LogData chunk) => sink.add(encoder.convert(chunk));

  @override
  void close() {}
}

class LogDataJsonDecoder extends LogDataDecoder<Map> {
  @literal
  const LogDataJsonDecoder();

  @override
  Sink<Map> startChunkedConversion(Sink<LogData> sink) =>
      _LogDataJsonDecoderSink(sink, this);

  @override
  LogData convert(Map input) => LogData(
        DateTime.parse(input['time_stamp'] as String),
        input['level'] as int,
        input['type'] as String? ?? '',
        input['title'] as String? ?? '',
        input['body'] as String? ?? '',
      );
}

class _LogDataJsonDecoderSink extends ChunkedConversionSink<Map> {
  _LogDataJsonDecoderSink(this.sink, this.decoder);

  final Sink<LogData> sink;
  final LogDataJsonDecoder decoder;

  @override
  void add(Map chunk) => sink.add(decoder.convert(chunk));

  @override
  void close() {}
}
