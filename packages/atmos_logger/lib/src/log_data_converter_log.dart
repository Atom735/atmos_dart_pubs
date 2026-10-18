import 'dart:convert';

import 'package:meta/meta.dart';

import 'log_data.dart';
import 'log_data_converter.dart';
import 'log_level.dart';

/// NUL, 00 — null («пустой»).
const _cNUL = '\x00';

/// SOH	01	start of heading	начало «заголовка»
const _cSOH = '\x01';

/// STX	02	start of text	начало «текста»
const _cSTX = '\x02';

/// ETX	03	end of text	конец «текста»
const _cETX = '\x03';

/// EOT	04	end of transmission	конец передачи
const _cEOT = '\x04';

/// NUL, 00 — null («пустой»).
final _recNUL = RegExp.escape(_cNUL);

/// SOH	01	start of heading	начало «заголовка»
final _recSOH = RegExp.escape(_cSOH);

/// STX	02	start of text	начало «текста»
final _recSTX = RegExp.escape(_cSTX);

/// ETX	03	end of text	конец «текста»
final _recETX = RegExp.escape(_cETX);

/// EOT	04	end of transmission	конец передачи
final _recEOT = RegExp.escape(_cEOT);

final _recGroup = '[$_recNUL$_recSOH$_recSTX$_recETX$_recEOT]';

class LogDataLogCodec extends LogDataCodec<String> {
  @literal
  const LogDataLogCodec();
  @override
  LogDataLogEncoder get encoder => const LogDataLogEncoder();
  @override
  LogDataLogDecoder get decoder => const LogDataLogDecoder();
}

class LogDataLogEncoder extends LogDataEncoder<String> {
  @literal
  const LogDataLogEncoder();

  @override
  Sink<LogData> startChunkedConversion(Sink<String> sink) =>
      _LogDataLogEncoderSink(sink, this);

  static final _regexp = RegExp(_recGroup);
  static String _replacer(Match match) => '$_cNUL${match.group(0)!}';

  @override
  String convert(LogData input) => '$_cSOH${LogLevel.names[input.level]}'
      '[${input.time.toIso8601String()}]'
      '(${input.name})\n'
      '$_cSTX${input.title.replaceAllMapped(_regexp, _replacer)}$_cETX\n'
      '${input.body.isNotEmpty ? '$_cSTX'
          '${input.body.replaceAllMapped(_regexp, _replacer)}'
          '$_cETX\n' : ''}'
      '$_cEOT';
}

class _LogDataLogEncoderSink extends ChunkedConversionSink<LogData> {
  _LogDataLogEncoderSink(this.sink, this.encoder);

  final Sink<String> sink;
  final LogDataLogEncoder encoder;

  @override
  void add(LogData chunk) => sink.add(encoder.convert(chunk));

  @override
  void close() {}
}

class LogDataLogDecoder extends LogDataDecoder<String> {
  @literal
  const LogDataLogDecoder();

  @override
  Sink<String> startChunkedConversion(Sink<LogData> sink) =>
      _LogDataLogDecoderSink(sink, this);

  static final _regexp = RegExp('$_recNUL[$_recGroup]');
  static String _replacer(Match match) => match.group(0)![1];
  static final _regexpFull = RegExp('$_recSOH(.*?)\\[(.*?)\\]\\((.*?)\\)\\s*'
      '$_recSTX(.*?)$_recETX\\s*'
      '($_recSTX(.*?)$_recETX\\s*)?'
      '$_recEOT');

  static Match? matchFirst(String data) =>
      _regexpFull.firstMatch(data.replaceAllMapped(_regexp, _replacer));

  static LogData logDataFromMatch(Match match) => LogData(
        DateTime.parse(match.group(2)!),
        LogLevel.names.indexOf(match.group(1)!),
        match.group(3)!,
        match.group(4)!,
        match.group(5) ?? '',
      );

  @override
  LogData convert(String input) {
    final match = matchFirst(input);
    if (match == null) throw const FormatException();
    return logDataFromMatch(match);
  }
}

class _LogDataLogDecoderSink extends ChunkedConversionSink<String> {
  _LogDataLogDecoderSink(this.sink, this.decoder);

  final Sink<LogData> sink;
  final LogDataLogDecoder decoder;

  String buf = '';

  @override
  void add(String chunk) {
    buf += chunk;
    var match = LogDataLogDecoder.matchFirst(buf);
    while (match != null) {
      sink.add(LogDataLogDecoder.logDataFromMatch(match));
      buf = buf.substring(match.end);
      match = LogDataLogDecoder.matchFirst(buf);
    }
  }

  @override
  void close() {}
}
