import 'dart:convert';

import 'package:meta/meta.dart';

import 'log_data.dart';
import 'log_data_converter.dart';
import 'log_level.dart';

class LogDataConsoleCodec extends LogDataCodec<String> {
  @literal
  const LogDataConsoleCodec();
  @override
  Converter<LogData, String> get encoder => const LogDataConsoleEncoder();
  @override
  Converter<String, LogData> get decoder => throw UnimplementedError();
}

class LogDataConsoleEncoder extends LogDataEncoder<String> {
  @literal
  const LogDataConsoleEncoder();

  @override
  Sink<LogData> startChunkedConversion(Sink<String> sink) =>
      LogDataEncoderSink(sink, this);

  @override
  String convert(LogData input) {
    final result =
        '${LogLevel.names[input.level]} [${input.time}]  (${input.name})\n'
        '${input.title}\n'
        '${input.body.isNotEmpty ? '${input.body}\n' : ''}';
    if (result.length > 2048) {
      return '${result.substring(0, 2048)}...';
    }
    return result;
  }
}
