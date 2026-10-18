import 'log_data.dart';
import 'logger.dart';

/// Логгер который добавляет к сообщению лога свое имя
class LoggerNamed extends Logger {
  LoggerNamed(this.name, [Logger? subLogger]) : super(subLogger);

  final String name;

  @override
  void log(LogData data) {
    subLogger?.log(
      data.copyWith(name: data.name.isEmpty ? name : '${data.name}.$name'),
    );
  }
}
