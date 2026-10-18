import 'log_data.dart';
import 'logger.dart';

/// Логгер который вызывает функцию при указанном уровне сообщений
class LoggerFilter extends Logger {
  LoggerFilter(this.func, [Logger? subLogger]) : super(subLogger);

  final bool Function(LogData data) func;

  @override
  void log(LogData data) {
    if (func(data)) {
      subLogger?.log(data);
    }
  }
}
