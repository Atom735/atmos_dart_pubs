import 'dart:convert';

import 'package:meta/meta.dart';

import 'log_ansi_styles.dart';
import 'log_data.dart';
import 'log_data_converter.dart';

class LogDataConsoleAnsiCodec extends LogDataCodec<String> {
  @literal
  const LogDataConsoleAnsiCodec();
  @override
  Converter<LogData, String> get encoder => const LogDataConsoleAnsiEncoder();
  @override
  Converter<String, LogData> get decoder => throw UnimplementedError();
}

class LogDataConsoleAnsiEncoder extends LogDataEncoder<String> {
  @literal
  const LogDataConsoleAnsiEncoder();

  @override
  Sink<LogData> startChunkedConversion(Sink<String> sink) =>
      LogDataEncoderSink(sink, this);

  @override
  String convert(LogData input) {
    final result =
        '${LogAnsiStyles.wrapLevel(input)} [${input.time}] (${input.name})\n'
        ' ${LogAnsiStyles.wrapTitle(input)}\n'
        '${LogAnsiStyles.wrapBody(input)}';
    if (result.length > 2048) {
      return '${result.substring(0, 2048)}...';
    }
    return result;
  }
}
