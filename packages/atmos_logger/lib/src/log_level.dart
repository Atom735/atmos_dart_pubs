/// Уровни лоигрования
abstract class LogLevel {
  static const all = 0;
  static const trace = 1;
  static const debug = 2;
  static const info = 3;
  static const warn = 4;
  static const error = 5;
  static const fatal = 6;
  static const off = 7;

  static const names = [
    'ALL  ',
    'TRACE',
    'DEBUG',
    'INFO ',
    'WARN ',
    'ERROR',
    'FATAL',
    'OFF  ',
  ];
}
