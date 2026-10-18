import 'dart:io';

import 'log_data.dart';
import 'log_data_converter_log.dart';
import 'logger.dart';

class LoggerFile extends Logger {
  LoggerFile(File file, [Logger? subLogger])
      : _sink = file.openWrite(mode: FileMode.writeOnlyAppend),
        super(subLogger);
  LoggerFile.sink(this._sink, [Logger? subLogger]) : super(subLogger);

  final StringSink _sink;

  @override
  void log(LogData data) {
    _sink.write(const LogDataLogEncoder().convert(data));
    subLogger?.log(data);
  }

  @override
  Future<void> closeThis() =>
      _sink is IOSink ? (_sink as IOSink).close() : Future.value();
}
