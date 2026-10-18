import 'package:meta/meta.dart';

import 'log_data.dart';
import 'logger.dart';

class LoggerConsole extends Logger {
  @literal
  const LoggerConsole([Logger? subLogger]) : super(subLogger);

  @override
  void log(LogData data) => throw UnimplementedError();
}
