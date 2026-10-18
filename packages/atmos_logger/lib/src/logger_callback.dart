import 'log_data.dart';
import 'logger.dart';

/// Логгер который вызывает функцию при указанном уровне сообщений
class LoggerCallback extends Logger {
  LoggerCallback(this.func, [Logger? subLogger]) : super(subLogger);

  final void Function(LogData data) func;

  @override
  void log(LogData data) {
    func(data);
    subLogger?.log(data);
  }
}
