// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:meta/meta.dart';

import 'log_data.dart';
import 'log_data_converter_console_web.dart';
import 'log_level.dart';
import 'logger.dart';

class LoggerConsole extends Logger {
  @literal
  const LoggerConsole([Logger? subLogger]) : super(subLogger);

  @override
  void log(LogData data) {
    final msg = const LogDataConsoleWebEncoder().convert(data);
    switch (data.level) {
      case LogLevel.all:
      case LogLevel.trace:
        window.console.log(msg);
        break;
      case LogLevel.debug:
        window.console.debug(msg);
        break;
      case LogLevel.info:
        window.console.info(msg);
        break;
      case LogLevel.warn:
        window.console.warn(msg);
        break;
      case LogLevel.error:
      case LogLevel.fatal:
        window.console.error(msg);
        break;
      case LogLevel.off:
      default:
    }
    subLogger?.log(data);
  }
}
