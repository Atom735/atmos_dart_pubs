import 'log_data.dart';
import 'logger.dart';

/// Logger that sets or nests the record [name].
///
/// Логгер, который задаёт или вкладывает имя записи [name].
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
