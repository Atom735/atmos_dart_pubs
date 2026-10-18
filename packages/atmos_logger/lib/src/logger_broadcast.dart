import 'log_data.dart';
import 'logger.dart';

/// Логгер который пробрасывает лог по всем входящим логгерам
class LoggerBroadcast extends Logger {
  LoggerBroadcast(this.loggers, [Logger? subLogger]) : super(subLogger);

  final Iterable<Logger> loggers;

  @override
  void log(LogData data) {
    for (final logger in loggers) {
      logger.log(data);
    }
    subLogger?.log(data);
  }

  @override
  Future<void> closeThis() => Future.wait(loggers.map((e) => e.close()));
}
