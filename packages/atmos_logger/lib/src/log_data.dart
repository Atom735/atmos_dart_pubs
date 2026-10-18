/// Single log record.
///
/// Одна запись лога.
class LogData {
  const factory LogData(
    DateTime time,
    int level,
    String type,
    String title, [
    String body,
  ]) = LogData._;

  const LogData._(
    this.time,
    this.level,
    this.name,
    this.title, [
    this.body = '',
  ]);

  /// Timestamp of the log entry.
  ///
  /// Метка времени лога.
  final DateTime time;

  /// Severity level (see `LogLevel`).
  ///
  /// Уровень сообщения (см. `LogLevel`).
  final int level;

  /// Logger name that produced the message.
  ///
  /// Имя логгера, отправившего сообщение.
  final String name;

  /// Short message / title.
  ///
  /// Заголовок сообщения.
  final String title;

  /// Optional detailed payload.
  ///
  /// Подробные данные сообщения.
  final String body;

  LogData copyWith({
    DateTime? time,
    int? level,
    String? name,
    String? title,
    String? body,
  }) =>
      LogData(
        time ?? this.time,
        level ?? this.level,
        name ?? this.name,
        title ?? this.title,
        body ?? this.body,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LogData &&
        other.time == time &&
        other.level == level &&
        other.name == name &&
        other.title == title &&
        other.body == body;
  }

  @override
  int get hashCode => Object.hash(time, level, name, title, body);
}
