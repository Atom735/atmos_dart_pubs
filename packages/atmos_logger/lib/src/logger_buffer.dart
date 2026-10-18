import 'log_data.dart';
import 'logger.dart';

class LoggerBuffer extends Logger {
  LoggerBuffer([List<LogData>? buffer, Logger? subLogger])
      : buffer = buffer ?? [],
        super(subLogger);

  final List<LogData> buffer;

  @override
  void log(LogData data) {
    buffer.add(data);
    subLogger?.log(data);
  }
}
