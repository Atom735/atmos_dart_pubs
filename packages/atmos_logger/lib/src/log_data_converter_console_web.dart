import 'dart:convert';

import 'package:meta/meta.dart';

import 'log_data.dart';
import 'log_data_converter.dart';

class LogDataConsoleWebCodec extends LogDataCodec<String> {
  @literal
  const LogDataConsoleWebCodec();
  @override
  Converter<LogData, String> get encoder => const LogDataConsoleWebEncoder();
  @override
  Converter<String, LogData> get decoder => throw UnimplementedError();
}

class LogDataConsoleWebEncoder extends LogDataEncoder<String> {
  @literal
  const LogDataConsoleWebEncoder();

  @override
  Sink<LogData> startChunkedConversion(Sink<String> sink) =>
      LogDataEncoderSink(sink, this);

  @override
  String convert(LogData input) {
    final result = '(${input.name})\n${input.title}\n'
        '${input.body.isNotEmpty ? '$input\n' : ''}';
    if (result.length > 2048) {
      return '${result.substring(0, 2048)}...';
    }
    return result;
  }
}
