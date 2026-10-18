import 'dart:convert';

import 'package:meta/meta.dart';

import 'log_data.dart';

abstract class LogDataCodec<T> extends Codec<LogData, T> {
  @literal
  const LogDataCodec();
}

abstract class LogDataEncoder<T> extends Converter<LogData, T> {
  @literal
  const LogDataEncoder();
}

abstract class LogDataDecoder<T> extends Converter<T, LogData> {
  @literal
  const LogDataDecoder();
}

class LogDataEncoderSink<T> extends ChunkedConversionSink<LogData> {
  LogDataEncoderSink(this.sink, this.encoder);

  final Sink<T> sink;
  final LogDataEncoder<T> encoder;

  @override
  void add(LogData chunk) => sink.add(encoder.convert(chunk));

  @override
  void close() {}
}
