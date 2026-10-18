import 'package:meta/meta.dart';

import 'log_data.dart';
import 'log_data_converter_console.dart';
import 'logger.dart';

class LoggerPrint extends Logger {
  @literal
  const LoggerPrint([Logger? subLogger]) : super(subLogger);

  @override
  void log(LogData data) {
    // ignore: avoid_print
    print(const LogDataConsoleEncoder().convert(data));
    subLogger?.log(data);
  }
}
