import 'log_data.dart';
import 'logger.dart';

/// Forwards a record to [subLogger] only when [func] returns `true`.
///
/// Передаёт запись в [subLogger], только если [func] вернул `true`.
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
