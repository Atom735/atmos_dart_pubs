import 'package:meta/meta.dart';

import 'log_data.dart';
import 'log_level.dart';
import 'logger_named.dart';

/// Интерфейс логировщика
abstract class Logger {
  @literal
  const Logger([this.subLogger]);

  /// Обернутый логгер
  final Logger? subLogger;

  void log(LogData data) => subLogger?.log(data);

  /// Тестовый вывод данных
  @nonVirtual
  void test() {
    trace('Trace — вывод всего подряд. На тот случай, если Debug не позволяет'
        ' локализовать ошибку. В нем полезно отмечать вызовы разнообразных'
        ' блокирующих и асинхронных операций.');
    debug('Debug — журналирование моментов вызова «крупных» операций.'
        ' Старт/остановка потока, запрос пользователя и т.п.');
    info('Info — разовые операции, которые повторяются крайне редко,'
        ' но не регулярно. (загрузка конфига, плагина, запуск бэкапа)');
    warn('Warning — неожиданные параметры вызова, странный формат запроса,'
        ' использование дефолтных значений в замен не корректных.'
        ' Вообще все, что может свидетельствовать о не штатном использовании.');
    error('Error — повод для внимания разработчиков. Тут интересно'
        ' окружение конкретного места ошибки.');
    fatal('Fatal — тут и так понятно. Выводим все до чего можем'
        ' дотянуться, так как дальше приложение работать не будет.');
  }

  /// Закрывает цепочку логгеров
  @nonVirtual
  Future<void> close([int? depth]) async {
    await closeThis();
    final subLogger = this.subLogger;
    if (subLogger != null) {
      if (depth == null) {
        return subLogger.close();
      }
      if (depth > 1) {
        return subLogger.close(depth - 1);
      }
    }
  }

  /// Закрывает именно этот логгер
  Future<void> closeThis() async {}

  @nonVirtual
  void call(String msg,
          [int level = LogLevel.trace, String data = '', String name = '']) =>
      log(LogData(DateTime.now(), level, name, msg, data));

  /// Trace — вывод всего подряд. На тот случай, если Debug не позволяет
  /// локализовать ошибку. В нем полезно отмечать вызовы разнообразных
  /// блокирующих и асинхронных операций.
  @nonVirtual
  void trace(String msg, [String data = '', String name = '']) =>
      log(LogData(DateTime.now(), LogLevel.trace, name, msg, data));

  /// Debug — журналирование моментов вызова «крупных» операций.
  /// Старт/остановка потока, запрос пользователя и т.п.
  @nonVirtual
  void debug(String msg, [String data = '', String name = '']) =>
      log(LogData(DateTime.now(), LogLevel.debug, name, msg, data));

  /// Info — разовые операции, которые повторяются крайне редко,
  /// но не регулярно. (загрузка конфига, плагина, запуск бэкапа)
  @nonVirtual
  void info(String msg, [String data = '', String name = '']) =>
      log(LogData(DateTime.now(), LogLevel.info, name, msg, data));

  /// Warning — неожиданные параметры вызова, странный формат запроса,
  /// использование дефолтных значений в замен не корректных.
  /// Вообще все, что может свидетельствовать о не штатном использовании.
  @nonVirtual
  void warn(String msg, [String data = '', String name = '']) =>
      log(LogData(DateTime.now(), LogLevel.warn, name, msg, data));

  /// Error — повод для внимания разработчиков. Тут интересно
  /// окружение конкретного места ошибки.
  @nonVirtual
  void error(String msg, [String data = '', String name = '']) =>
      log(LogData(DateTime.now(), LogLevel.error, name, msg, data));

  /// Fatal — тут и так понятно. Выводим все до чего можем
  /// дотянуться, так как дальше приложение работать не будет.
  @nonVirtual
  void fatal(String msg, [String data = '', String name = '']) =>
      log(LogData(DateTime.now(), LogLevel.fatal, name, msg, data));

  LoggerNamed namedLogger(String name) => LoggerNamed(name, this);
}

class LoggerVoid extends Logger {
  @literal
  const LoggerVoid([Logger? subLogger]) : super(subLogger);
}
