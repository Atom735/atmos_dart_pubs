import 'dart:io';

import 'package:meta/meta.dart';

import 'log_data.dart';
import 'log_data_converter_console_ansi.dart';
import 'logger.dart';

class LoggerConsole extends Logger {
  @literal
  const LoggerConsole([Logger? subLogger]) : super(subLogger);

  @override
  void log(LogData data) {
    stdout.writeln(const LogDataConsoleAnsiEncoder().convert(data));
    subLogger?.log(data);
  }
}
